# Design history and roadmap

This records the initial project decisions from September 2026 and the work they inform. The BuildStream definitions describe the current software selection; [validation notes](validation.md) record what has actually been tested.

## Scope

Build a GNOME desktop as an immutable bootc OCI image. The repository owns image composition, system services, application defaults and deployment configuration. User accounts' settings, development tool selections and secrets remain outside the image.

The initial base is GNOME 51 and freedesktop-sdk 26.08, using baseline x86_64. Deployment targets composefs, systemd-boot and Btrfs with conventional local accounts.

x86-64-v3 was tried during bring-up, then disabled because upstream GNOME and Dakota CI use the baseline target. Reusing upstream artifacts takes priority over CPU-specific compilation, especially for future hosted CI builds.

Dakota tracks `testing` with a fixed commit. The initial `next` pin was replaced after confirming that the borrowed components were identical on `testing`; the rolling branch was unnecessary for the pinned GNOME 51 base.

## Composition decisions

- Keep one shared GNOME/freedesktop-sdk graph. Pin compatible upstream revisions and review them together when updating.
- Own the final composition locally. Reuse individual Dakota elements through a junction without importing `bluefin/deps.bst` or `bluefin/common.bst`.
- Use public artifact and source caches read-only. Preserve upstream recipes where possible, but let image requirements determine composition.
- Build one complete OS image. The initial split into two editions was removed to keep builds and validation focused on the system that will be used.
- Use upstream kernel, graphics, firmware and memory defaults. Add overrides only for a demonstrated requirement.

## Desktop decisions

GNOME supplies the desktop session and host integration. Flatpak is the normal GUI application format, with Bazaar as the store and an explicit default application list. Files and Disks are native applications. PDF thumbnails come from a separate extraction of Papers; the full Papers application is not required. Sushi is selected as a default Flatpak because its native recipe pulls Papers back into the runtime.

Helium and Microsoft Visual Studio Code are also native image applications, chosen for their host integration outside Flatpak. Their official binary releases are pinned and updated with the OS.

Use Flatpak's built-in `.preinstall` declarations and a boot service, following Dakota's approach. The default set includes the app store, system monitor, file previews, GNOME extension management, GNOME tweaks, Flatpak permission management and journal viewing. Flatpak owns installation state and respects manual removals; changes to the default selection do not require maintaining a custom installer or completion marker.

Keep parental controls and Help as supplied by upstream. An initial attempt to exclude them required modifying three GNOME recipes; maintaining those changes was not worth the smaller application selection. GNOME user documentation remains excluded through the local session list. Keep sharing services, remote desktop, accessibility and color management.

Ghostty is image-managed and supplies the preferred terminal integration. Distrobox supplies mutable development environments using its upstream preference for Podman. Docker remains available separately with its CLI, Compose and Buildx. mise installs automatically at user login and updates independently of the OS. This replaces the original image-managed mise choice because of its frequent releases.

Tailscale and QEMU/libvirt belong in the image because they need host services. Selected Dakota elements also provide resolver integration, the composefs disk-visibility rule and the PC-speaker audio rule.

The initial implementation keeps bootc install defaults local to select Btrfs. It retains GNOME's bootc version and zram defaults. Exact pins and recipe ownership are documented in the [build guide](building.md).

## Deployment decisions

OS updates should stage a complete bootc deployment without forcing a reboot. Direct bootc commands must remain usable, and an update-and-rollback cycle must be tested. Flatpak updates are independent of OS updates.

Adapt Dakota's installer when the image is ready for installation. The installer must select this project's image and update origin, use the composefs backend with Btrfs and systemd-boot, and create conventional local accounts. Offline media must embed the matching OCI payload.

## Remaining milestones

1. Set up reviewed dependency-update PRs and CI builds with artifact caching, then publish images to GHCR.
2. Publish successive image versions and demonstrate staged updates and rollback without automatic reboots.
3. Adapt the installer and verify a fresh installation, its update origin, and a subsequent update-and-rollback cycle.
4. Complete hardware and external-integration acceptance, including accelerated graphics, audible output, Tailscale enrollment and running libvirt guests.

The full image builds, installs and boots through systemd-boot into a GNOME Wayland session. Initial setup, native apps, default Flatpaks, PDF previews, container networking and persistence across reboot have passed VM checks. Keep exact results and limits in the validation notes rather than treating this roadmap as evidence of completion.
