# Dependency updates and publishing

`renovate.yml` runs daily or manually and opens update PRs. `build.yml` runs only on pushes to `main`, including merged PRs. It builds the OS, runs `bootc container lint`, and publishes `ghcr.io/tb516/os:latest` and a `sha-<commit>` tag. Neither workflow runs on PR events.

The build uses standard GitHub-hosted Ubuntu runners and upstream BuildStream caches, without preserving local artifacts between runs. Its first GitHub run still needs to establish whether the runner has enough disk space and time.

Publication uses Red Hat's `push-to-registry` Action. It reuses the image already imported into Podman for bootc validation, then publishes the commit tag and `latest`. The workflow's `IMAGE_NAME` is `tb516/os`; keep it aligned with `include/image.yml` if the repository moves. Renovate tracks the publishing Action's pinned revision.

## Setup

Create a fine-grained GitHub token restricted to `TB516/OS`, with read/write access to Contents, Pull requests, Issues and Workflows. Store it as the Actions secret `RENOVATE_TOKEN` and renew it before expiry. Renovate uses Issues for its dashboard and Workflows to update pinned Actions. Image publication uses GitHub's built-in workflow token.

Renovate is free and runs through its official Action. The updater needs no BuildStream container or Docker socket. After first publication, check GHCR package visibility before using the image for public installs. The installer must explicitly configure the image as its update origin.

## Adding dependencies

For a GitHub release archive, put this comment immediately before its URL:

```yaml
- kind: tar
  # renovate: datasource=github-release-attachments depName=OWNER/REPO version=v1.2.3
  url: github:OWNER/REPO/releases/download/v1.2.3/app-v1.2.3-linux-x64.tar.gz
  ref: INITIAL_ARCHIVE_SHA256
```

The same rule supports `kind: remote` and any recipe under `elements/`. Keep the comment's version identical to the version text in the URL. Renovate updates the version and checksum together by matching the pinned release asset. No script entry is needed. Different release APIs or naming conventions may require another rule.

VS Code uses Microsoft's stable-release API and SHA256 with a versioned tar URL. GNOME and Dakota track their existing Git branches. Container images and Actions are also tracked; nested component versions remain owned by their upstream junctions.

## Two exceptions

`.github/renovate-sync.mjs` runs before Renovate commits Docker Engine or GNOME updates. It hashes Docker Engine's archive from Docker's download server and copies the two shared plugin recipes from the selected GNOME commit. Compose, Buildx, mise and Helium use Renovate's release-attachment support directly. This hook uses Node's built-in modules and needs no installed packages.

Review GNOME/Dakota compatibility and local integration assumptions before merging. Review `files/vscode` when updating VS Code. The build starts after merging, so an update PR does not establish that the new OS builds or boots.
