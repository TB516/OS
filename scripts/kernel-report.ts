import type { getOctokit, context as actionContext } from '@actions/github';
import type { warning } from '@actions/core';

type ScriptInputs = {
  github: ReturnType<typeof getOctokit>;
  context: typeof actionContext;
  core: { warning: typeof warning };
};

/** Add kernel version and source-input comparisons to Renovate PRs. */
export default async function report({ github, context, core }: ScriptInputs) {
  const repo = context.repo;
  const kernelPath = 'elements/core/dakota-boot.bst';
  const marker = '<!-- personal-os-kernel-report -->';
  const sourceUrl = 'https://github.com/projectbluefin/dakota';
  const registryUrl = 'https://ghcr.io/v2/projectbluefin/dakota';
  let tokenRequest: Promise<{ token: string }> | undefined;

  async function getJson(url: string, headers: Record<string, string> = {}) {
    const response = await fetch(url, { headers, signal: AbortSignal.timeout(30_000) });

    if (!response.ok) {
      throw new Error(`${url} returned HTTP ${response.status}`);
    }

    return response.json();
  }

  async function registry(path: string) {
    // Share one token request between the old and new image reads.
    tokenRequest ??= getJson('https://ghcr.io/token?scope=repository:projectbluefin/dakota:pull');
    const { token } = await tokenRequest;

    return getJson(`${registryUrl}/${path}`, {
      Authorization: `Bearer ${token}`,
      Accept: 'application/vnd.oci.image.manifest.v1+json, application/vnd.oci.image.index.v1+json',
    });
  }

  async function inventory(digest: string) {
    // GHCR exposes these SBOM attachments through OCI's referrers-tag fallback.
    const index = await registry(`manifests/${digest.replace(':', '-')}`);
    const attachment = index.manifests.find(
      item => item.artifactType === 'application/vnd.spdx+json',
    );

    if (!attachment) {
      throw new Error('SBOM not published yet');
    }

    const manifest = await registry(`manifests/${attachment.digest}`);

    if (manifest.subject?.digest !== digest) {
      throw new Error('SBOM identifies a different image');
    }

    const sbom = await registry(`blobs/${manifest.layers[0].digest}`);
    const inputs = new Map<string, string>();
    let version: string | undefined;

    for (const pkg of sbom.packages) {
      const isKernel = pkg.externalRefs?.some(
        ref => ref.referenceType === 'bst-element'
          && ref.referenceLocator === 'core/linux-fdsdk.bst',
      );

      if (!isKernel || !pkg.versionInfo) continue;

      if (pkg.sourceInfo === 'git_repo') {
        version = pkg.versionInfo;
      }

      inputs.set(`${pkg.sourceInfo}:${pkg.downloadLocation}`, pkg.versionInfo);
    }

    if (!version) {
      throw new Error('SBOM has no Dakota kernel source version');
    }

    const image = await registry(`manifests/${digest}`);
    const config = await registry(`blobs/${image.config.digest}`);
    const labels = config.config.Labels;

    return {
      version,
      inputs,
      built: labels['org.opencontainers.image.created'],
      revision: labels['org.opencontainers.image.revision'],
    };
  }

  function comparison(
    before: Awaited<ReturnType<typeof inventory>>,
    after: Awaited<ReturnType<typeof inventory>>,
  ) {
    const lines = [
      `- Kernel: \`${before.version}\` → \`${after.version}\`.`,
      `- Built: \`${before.built}\` → \`${after.built}\`.`,
    ];

    if (!before.revision || !after.revision) {
      lines.push('- Dakota source revision unavailable.');
    } else if (before.revision === after.revision) {
      lines.push(`- Dakota source unchanged: \`${after.revision.slice(0, 12)}\`.`);
    } else {
      const comparisonUrl = `${sourceUrl}/compare/${before.revision}...${after.revision}`;
      lines.push(`- [Dakota source changes](${comparisonUrl}).`);
    }

    const allInputs = new Set([...before.inputs.keys(), ...after.inputs.keys()]);
    const changedInputs = [...allInputs].sort().filter(
      key => before.inputs.get(key) !== after.inputs.get(key),
    );

    if (changedInputs.length === 0) {
      lines.push('- Recorded kernel source, patches and configuration inputs unchanged.');
    } else {
      lines.push('', 'Changed kernel inputs:', '');

      for (const input of changedInputs) {
        const oldVersion = before.inputs.get(input) ?? 'absent';
        const newVersion = after.inputs.get(input) ?? 'absent';
        lines.push(`- \`${input}\`: \`${oldVersion}\` → \`${newVersion}\`.`);
      }
    }

    if (before.version !== after.version && /^\d+\.\d+\.\d+$/.test(after.version)) {
      const major = after.version.split('.')[0];
      const changelogUrl = `https://cdn.kernel.org/pub/linux/kernel/v${major}.x/ChangeLog-${after.version}`;

      lines.push(
        '',
        `[Target kernel changelog](${changelogUrl}). Intermediate releases may also contain changes.`,
      );
    }

    lines.push(
      '',
      'SBOM data describes source inputs; matching inputs do not prove identical binaries or signatures.',
    );

    return lines.join('\n');
  }

  async function imageDigest(ref: string) {
    const { data } = await github.rest.repos.getContent({ ...repo, path: kernelPath, ref });

    if (Array.isArray(data) || data.type !== 'file') {
      throw new Error('Kernel recipe is not a file');
    }

    const contents = Buffer.from(data.content, 'base64').toString('utf8');
    const digest = contents.match(/^  ref: (sha256:[a-f0-9]{64})$/m)?.[1];

    if (!digest) {
      throw new Error('Dakota image digest not found');
    }

    return digest;
  }

  const pulls = await github.paginate(github.rest.pulls.list, { ...repo, state: 'open' });
  const { data: user } = await github.rest.users.getAuthenticated();

  for (const pull of pulls) {
    if (!pull.head.ref.startsWith('renovate/')) continue;
    if (pull.head.repo?.full_name !== `${repo.owner}/${repo.repo}`) continue;

    const pullRequest = { ...repo, pull_number: pull.number };
    const files = await github.paginate(github.rest.pulls.listFiles, pullRequest);

    if (!files.some(file => file.filename === kernelPath)) continue;

    const issue = { ...repo, issue_number: pull.number };
    const comments = await github.paginate(github.rest.issues.listComments, issue);
    const existing = comments.find(
      comment => comment.user?.login === user.login && comment.body?.startsWith(marker),
    );
    const revision = `For PR revision \`${pull.head.sha.slice(0, 12)}\`.`;
    const sections = [
      marker,
      '## Kernel update',
      revision,
    ];

    try {
      const digests = await Promise.all([pull.base.sha, pull.head.sha].map(imageDigest));

      if (digests[0] === digests[1]) continue;

      const [before, after] = await Promise.all(digests.map(inventory));
      sections.push(comparison(before, after));
    } catch (error) {
      core.warning(`Kernel report for PR #${pull.number}: ${String(error)}`);

      // Keep a successful report when a refresh fails for the same revision.
      if (existing?.body?.includes(revision) && existing.body.includes('- Kernel:')) continue;

      sections.push(
        'Kernel inventory unavailable; the next Renovate run will retry. SBOM publication can lag the image.',
      );
    }

    const body = sections.join('\n\n');
    const { data: current } = await github.rest.pulls.get(pullRequest);

    if (current.state !== 'open' || current.head.sha !== pull.head.sha) continue;

    if (!existing) {
      await github.rest.issues.createComment({ ...issue, body });
      continue;
    }

    if (existing.body === body) continue;

    await github.rest.issues.updateComment({ ...repo, comment_id: existing.id, body });
  }
}
