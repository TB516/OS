import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';

// Renovate handles other hashes itself. These two sources need extra work.
const changed = execFileSync('git', ['diff', '--name-only', 'HEAD', '--', 'elements/'], { encoding: 'utf8' }).split('\n');

async function download(url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`${response.status}: ${url}`);
  return response;
}

if (changed.includes('elements/core/docker.bst')) {
  const path = 'elements/core/docker.bst';
  const recipe = await readFile(path, 'utf8');
  const [source, archive] = recipe.match(/url: docker:(\S+)\n  ref: [a-f0-9]{64}/);
  const response = await download(`https://download.docker.com/linux/static/stable/x86_64/${archive}`);
  const hash = createHash('sha256');
  for await (const chunk of response.body) hash.update(chunk);
  await writeFile(path, recipe.replace(source, `url: docker:${archive}\n  ref: ${hash.digest('hex')}`));
}

// Our shared plugin overrides must follow the selected GNOME revision.
if (changed.includes('elements/gnome.bst')) {
  const recipe = await readFile('elements/gnome.bst', 'utf8');
  const [, commit] = recipe.match(/^  ref: (?:.*-g)?([a-f0-9]{40})$/m);
  for (const name of ['buildstream-plugins', 'buildstream-plugins-community']) {
    const path = `elements/plugins/${name}.bst`;
    const response = await download(`https://gitlab.gnome.org/GNOME/gnome-build-meta/-/raw/${commit}/${path}`);
    await writeFile(path, await response.text());
  }
}
