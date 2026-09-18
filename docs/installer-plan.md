# Installer direction

Research only; no ISO has been built or tested for this project.

Reuse [Dakota's ISO project](https://github.com/projectbluefin/dakota-iso/tree/f5fbf99bbc843167522eec9078ede12308a16848), reviewed at commit `f5fbf99bbc843167522eec9078ede12308a16848`. Its `just iso-sd-boot <variant>` path builds a UEFI live environment and embeds an offline image for the graphical bootc installer. It supports systemd-boot and composefs, matching this OS's tested installation path.

Keep the upstream implementation separate and add project configuration when building the first ISO:

- Select the live image using the variant's `registry`, `live_target` and `tag` files. Select the installed payload with `payload_ref`.
- Supply the corresponding `live/src/<live-target>/` installer configuration. Set `base_imgref` and `nvidia_imgref` to our single image, `ghcr.io/tb516/os:latest`; the latter name is an upstream convention for the offline source, not a requirement to add an NVIDIA edition.
- Provide `images.json` and a minimal `recipe.json` for this OS, with systemd-boot, composefs and Btrfs. Remove Dakota's image choices and branding. Changing `payload_ref` alone leaves Dakota defaults in the installer.
- Make the installed update origin explicitly point to our published image. An embedded local image reference must not become the update origin.

Before hardware installation, test live boot, disk installation, first-user creation, boot without the ISO and an update from GHCR in a fresh VM. The upstream builder adjusts the offline payload's install configuration and repackages it, so the existing direct bootc VM test does not establish that this ISO path works unchanged. Secure Boot signing is not configured for this OS.

Build one ISO locally after image publication works. Keep future OS updates on bootc; an ISO build on every commit is unnecessary. Automatic update timing remains a separate decision.
