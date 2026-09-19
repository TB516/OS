# Installer releases

The workflow is prepared but has not run on GitHub. No installer ISO has been booted or installed in a VM yet.

## Create an installer

1. Push the project to GitHub and let **Build OS** publish `ghcr.io/tb516/os:latest`. Make the GHCR package public so installed systems can fetch updates without credentials.
2. Open **Actions → Build installer ISO → Run workflow**, using `main`.
3. Download the resulting installer prerelease from **Releases**. Follow its instructions to join the numbered ISO parts, verify the checksums and restore the ISO to a USB drive with GNOME Disks.

The workflow runs on a standard Ubuntu GitHub runner. It installs its tools on that disposable runner and does not preserve a build cache. Disk space and build time still need confirmation on the first run. No extra secret is needed; image pulls and release uploads use the workflow token.

Each invocation creates a separate prerelease named `installer-<run-id>-<attempt>`. Files are split into 1900 MiB parts because GitHub release assets must be smaller than 2 GiB. `SHA256SUMS` checks the reconstructed ISO, `PARTS-SHA256SUMS` checks the downloads, and `image-digest.txt` records the published source image.

## Implementation

The workflow checks out a pinned revision of [Dakota's ISO builder](https://github.com/projectbluefin/dakota-iso). Renovate tracks that revision. We reuse its live Containerfile, squashfs builder and UEFI ISO assembler without copying those implementations into this project.

`installer/os/` supplies the image catalog, installer recipe and launcher name. The workflow supplies both upstream image-reference files using our single image; upstream's `nvidia_imgref` name does not imply a second OS edition. `installer/flatpaks` lists the same default apps as the OS preinstall configuration and must stay aligned with it.

The live environment and offline payload use the pulled `latest` image. Installation selects systemd-boot, composefs and Btrfs, with GNOME Initial Setup creating the first account. Installed systems track `ghcr.io/tb516/os:latest` for subsequent updates. Rebuilding the ISO on each OS update is unnecessary.

## Validation still needed

Test live boot, graphical installation, first-user creation, boot without the ISO and an update from GHCR in a fresh VM before hardware installation. The upstream builder adjusts install configuration and repackages the offline payload, so the existing direct bootc VM test does not validate this installer path. Secure Boot signing is not configured.
