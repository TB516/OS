# Dependency updates and publishing

`renovate.yml` runs daily or manually and opens update PRs. `build.yml` runs only on pushes to `main`, including merged PRs. It builds the OS, runs `bootc container lint`, and publishes `ghcr.io/tb516/os:latest`, a `sha-<commit>` tag and a `YYYYMMDD.N` version tag. `installer.yml` runs only when manually dispatched and publishes an installer prerelease. None runs on PR events.

The version uses the UTC date when the build starts. `N` is one more than the largest matching version tag already published to GHCR, so the first published image on September 21, 2026 is `20260921.1`. Failed and cancelled builds do not reserve a number. A rerun only advances the counter if its previous attempt published the version tag. CI writes this version into the image before BuildStream starts. It appears in `os-release`, the OCI metadata and the boot image selector as, for example, `Personal OS 20260921.1`.

The build uses standard GitHub-hosted Ubuntu runners and upstream BuildStream caches, without preserving local artifacts between runs. Its first GitHub run still needs to establish whether the runner has enough disk space and time.

Publication uses Red Hat's `push-to-registry` Action. It reuses the image already imported into Podman for bootc validation, then publishes the version, commit and `latest` tags. The workflow's `IMAGE_NAME` is `tb516/os`; keep it aligned with `include/image.yml` if the repository moves. Renovate tracks the publishing Action's pinned revision.

## Setup

Installed systems enable `bootc-fetch-apply-updates.timer`. The upstream schedule checks after one hour of uptime and eight hours after the previous run, with up to two hours of randomized delay. Local drop-ins select the composefs boot condition and run `bootc upgrade --quiet`, staging updates for the next user-initiated reboot. They do not reboot automatically. This requires a working registry update origin; end-to-end updating still needs validation after publication.

Create a fine-grained GitHub token restricted to `TB516/OS`, with read/write access to Contents, Pull requests, Issues and Workflows. Store it as the Actions secret `RENOVATE_TOKEN` and renew it before expiry. Renovate uses Issues for its dashboard and Workflows to update pinned Actions. Image publication uses GitHub's built-in workflow token.

Renovate is free and runs through its official Action. The updater needs no BuildStream container or Docker socket. After first publication, check GHCR package visibility before using the image for public installs. The installer must explicitly configure the image as its update origin.

## Adding dependencies

Docker's Engine, CLI, Compose and Buildx update together through the official Docker image. Its BuildStream source uses this annotation:

```yaml
  # renovate: datasource=docker depName=docker.io/library/docker
  track: 29.9.1-dind
  ref: sha256:d18cae6d97a9ebf10a017859d3cdf728de0f2efc465364ba0bab6e2c9a87ccdc
```

Keep the full version and `-dind` suffix. Renovate updates the tag and digest together and preserves the architecture of the existing Linux amd64 manifest pin. BuildStream's Docker source expects a platform manifest rather than a multi-platform index.

The shared BuildStream plugin junctions have their own release tags and commit pins, managed directly by Renovate. They no longer follow GNOME's plugin recipes. The Docker source carries a small compatibility patch shared with other OCI imports, covering HTTP content types, Zstd layers and `sha256:` refs. Review that patch when updating the plugin release.

GNOME and Dakota track their existing Git branches. Container images and Actions are also tracked; nested component versions remain owned by their upstream junctions. Dependency updates need no checksum or recipe synchronization script.

Review GNOME/Dakota compatibility and local integration assumptions before merging. The build starts after merging, so an update PR does not establish that the new OS builds or boots.
