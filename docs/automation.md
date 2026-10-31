# Dependency updates and publishing

`renovate.yml` runs daily or manually and opens update PRs. `build.yml` runs only on pushes to `main`, including merged PRs. It builds the OS, runs `bootc container lint`, and publishes `ghcr.io/tb516/os:latest`, a `sha-<commit>` tag and a `YYYYMMDD.N` version tag. `installer.yml` runs only when manually dispatched and publishes an installer prerelease. `validate.yml` resolves the dependency graph on PRs that change build inputs; it does not build the OS.

The version uses the UTC date when the build starts. `N` is one more than the largest matching version tag already published to GHCR, so the first published image on September 21, 2026 is `20260921.1`. Failed and cancelled builds do not reserve a number. A rerun only advances the counter if its previous attempt published the version tag. CI writes this version into the image before BuildStream starts. It appears in `os-release`, the OCI metadata and the boot image selector as, for example, `Personal OS 20260921.1`.

The build uses standard GitHub-hosted Ubuntu runners and upstream BuildStream caches, without preserving local artifacts between runs.

Publication uses Red Hat's `push-to-registry` Action. It reuses the image already imported into Podman for bootc validation, then publishes the version, commit and `latest` tags. The workflow's `IMAGE_NAME` is `tb516/os`; keep it aligned with `include/image.yml` if the repository moves. Renovate tracks the publishing Action's pinned revision.

## Setup

Installed systems enable `bootc-fetch-apply-updates.timer`. The upstream schedule checks after one hour of uptime and eight hours after the previous run, with up to two hours of randomized delay. Local drop-ins select the composefs boot condition and run `bootc upgrade --quiet`, staging updates for the next user-initiated reboot. They do not reboot automatically. This requires a working registry update origin; end-to-end updating still needs validation after publication.

Create a fine-grained GitHub token restricted to `TB516/OS`, with read/write access to Contents, Pull requests, Issues and Workflows. Store it as the Actions secret `RENOVATE_TOKEN` and renew it before expiry. Renovate uses Issues for its dashboard and Workflows to update pinned Actions. Image publication uses GitHub's built-in workflow token.

Renovate is free and runs through its official Action. The updater needs no BuildStream container or Docker socket. Keep the GHCR package public so installed systems can fetch updates without credentials. The installer configures `ghcr.io/tb516/os:latest` as its update origin.

## Image signing

Installed systems only accept updates from `ghcr.io/tb516/os` that carry a valid signature from this project's key. Other images, such as Bluefin or Dakota, are unaffected and can still be rebased to.

The build workflow publishes with `redhat-actions/push-to-registry`, which has Podman sign the image during the push using the `COSIGN_PRIVATE_KEY` Actions secret. Podman stores the signature next to the image in GHCR as a `sha256-<digest>.sig` tag. A cosign step then checks that signature against the public key shipped in the image, so a secret that doesn't match fails the build. The key has no password, because the password would sit in the same secrets store.

`/etc/containers/policy.json` requires that signature for this repository, using the public key at `/etc/pki/containers/personal-os.pub`. `/etc/containers/registries.d/personal-os.yaml` tells bootc and Podman where the signatures are stored. bootc checks the signature with the key from the currently running image before accepting an update, and refuses unsigned images or images signed with another key.

If signing fails, the build fails. Any tag published without a valid signature is rejected by installed systems, which keep their current image until a later build signs successfully. In an emergency, a system can accept unsigned updates again by removing the `ghcr.io/tb516/os` entry from its local `/etc/containers/policy.json`.

To replace the key:

1. Add the new public key next to `personal-os.pub` in `files/system/etc/pki/containers`, change the policy's `keyPath` to a `keyPaths` list with both files, and publish. This image is still signed with the old key, and installed systems that boot it trust either key.
2. Replace the `COSIGN_PRIVATE_KEY` secret with the new private key, point the build workflow's verification step at the new public key, and publish.
3. In a later image, remove the old key file and its `keyPaths` entry. A listed key file that is missing makes verification fail.

A system that skipped the step 1 image only trusts the old key. Move it to that image's version tag and reboot, for example `sudo bootc switch --apply ghcr.io/tb516/os:20261022.1`. Once it runs that image, `sudo bootc switch ghcr.io/tb516/os:latest` works again.

## Adding dependencies

Docker's Engine, CLI, Compose and Buildx update together through the official Docker image. Its BuildStream source uses this annotation:

```yaml
  # renovate: datasource=docker depName=docker.io/library/docker
  track: <version>-dind
  ref: sha256:<linux/amd64 manifest digest>
```

Keep the full version and `-dind` suffix. Renovate updates the tag and digest together and preserves the architecture of the existing Linux amd64 manifest pin. BuildStream's Docker source expects a platform manifest rather than a multi-platform index.

The shared BuildStream plugin junctions have their own release tags and commit pins, managed directly by Renovate. They no longer follow GNOME's plugin recipes. The Docker source carries a small compatibility patch shared with other OCI imports, covering HTTP content types, Zstd layers and `sha256:` refs. Review that patch when updating the plugin release.

The Dakota recipe pin follows Dakota's `testing` branch, but only to commits whose Dakota CI build succeeded, so their artifacts are already in the Bluefin cache. A Renovate custom datasource reads the newest `build.yml` push run on `testing` and offers its commit only if that run succeeded. Dakota skips the build for a push when a newer push is already queued, so older successful runs are not trusted. While the newest build is still running or has failed, Renovate reports a lookup warning and leaves the pin alone. GNOME and freedesktop-sdk move with Dakota. Container images and Actions are also tracked; nested component versions remain owned by their upstream junctions. Dependency updates need no checksum or recipe synchronization script.

The kernel image in `elements/core/dakota-boot.bst` independently follows Dakota's `testing` channel with an exact amd64 manifest digest. Kernel, modules, signed EFI binaries and signing certificate come from the same image; the Dakota recipe pin does not have to match its source revision.

## Kernel update reports

After Renovate finishes, the same workflow imports `scripts/kernel-report.ts` as an ES module through `actions/github-script`, which supplies its runtime and authenticated GitHub client. It refreshes one comment on each open Renovate PR that changes the kernel image. Other updates use Renovate's normal release notes and comparison links. The report reads image metadata and attached SBOMs; it does not build or download image filesystem layers.

Kernel updates show image build timestamps, Dakota source revisions, kernel source versions and changes to the kernel's recorded patch/configuration inputs. The SBOM can arrive after image publication. Missing metadata is reported and retried on the next daily or manual Renovate run. Matching source inputs do not establish that compiled files or signatures are identical.

The report uses the workflow's existing `RENOVATE_TOKEN`. It includes the PR revision and skips publishing if that revision changed during generation. Existing comments are updated only when their content changes. A temporary fetch failure preserves an existing successful report for the same PR revision.

Review Dakota updates and local integration assumptions before merging. The build starts after merging, so an update PR does not establish that the new OS builds or boots.
