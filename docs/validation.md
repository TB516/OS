# Bring-up status

## Docker and firewalld, September 20, 2026

- Booted the fresh-install disk from `build/kernel-vm` with a disposable QEMU snapshot. Its image digest is `sha256:348f165c7cb4e167e262716410d176e2cd7c9855f1c6a077ea834227aff1b80c`, with Linux 7.2.6 and Docker 29.8.1. No Dakota rebase was involved.
- Docker initially started, but restarting it with firewalld running reproduced `failed to create NAT chain DOCKER: COMMAND_FAILED: INVALID_IPV`. The installed firewalld configuration pointed its IPv4/IPv6 iptables commands at `/bin/false`.
- Applied a prototype path correction to a temporary copy of the configuration and bind-mounted it over the original inside the VM. After restarting firewalld, Docker started and passed another restart. Container DNS, outbound HTTPS and a port published on guest localhost all passed.
- Replaced that prototype with a GNOME recipe patch adding iptables as a build and runtime dependency of firewalld. Its configure step now has the tools available for path discovery; image assembly no longer edits Python files. The patched dependency graph resolves successfully.
- The patched firewalld package built successfully. Its build commands took 6 seconds, BuildStream completed the package job in 8 seconds, and a warm-cache invocation took 14 seconds end to end. The resulting artifact records `/usr/bin/iptables`, `/usr/bin/iptables-restore`, `/usr/bin/ip6tables` and `/usr/bin/ip6tables-restore`.
- Warming the otherwise incomplete local build-dependency cache took about six minutes, dominated by GCC and gRPC artifact downloads. A clean CI runner may see similar network overhead, though some dependencies can overlap the normal full-image graph. A rebuilt-image boot test remains outstanding.
- Evidence is under `build/docker-vm-check`. The test used a runtime bind mount, not a rebuilt image; full image rebuild and boot validation remain outstanding. The original VM disk was unchanged.

## Dakota kernel switch, September 18, 2026

- Selected Dakota testing's regular Linux 7.2.6 kernel through one GNOME junction override. The full graph uses the same kernel for the image, modules and initramfs. Baseline x86_64 and GNOME's zram setup remain selected.
- Pulled kernel artifact `bluefin/core-linux-fdsdk/c2ca442ed88de40fae172d753e9e619c57b23db6a451c1b25a0db19800bb67ca` from Bluefin's cache. It matches the unmodified pinned Dakota project's key; no kernel compilation was needed.
- Full local image build passed in 2m19s with eight build tasks and no failures, using existing local artifacts. This is not a cold CI timing. The exported image at `build/kernel-image` passed bootc lint with 13 checks passed and one skipped.
- Installed the new image into a fresh 48 GiB virtual disk and booted it through UEFI/systemd-boot without a directly supplied kernel. `uname -r` reports `7.2.6`; the graphical target and GDM are active, and no system units failed. Zram is active and the background bootc update timer is enabled.
- VM evidence and its disk are under `build/kernel-vm`. The helper install uses the local test origin `localhost/personal-os:dev`; it does not validate registry updates or the ISO installer.

## Original baseline validation

Checked on September 17, 2026, using BuildStream 2.7 in the pinned builder container and a QEMU/KVM VM.

The full baseline x86_64 image builds, installs through bootc and boots through UEFI/systemd-boot into GNOME. Initial setup creates a conventional account, and password login and writable state survive a reboot. This is local VM acceptance, not a published release or hardware certification.

## Image and build checks

- `just build`, OCI checkout and `just validate` pass. The exported image is at `build/image`, with the same image loaded into rootless Podman as `localhost/personal-os:dev`.
- Tested manifest: `sha256:902f4478a0050616264ee84372ab02d37e6946765c09ad834a9199422d468c1a`. Its uncompressed layer is about 9.29 GiB. It retains the amd64 platform and `containers.bootc=1` label.
- The image's own `bootc container lint` reports 13 checks passed, one skipped and no warnings in a disposable container with networking disabled and a read-only root.
- Kernel 7.2.2 and its matching initramfs are present. Writable-state symlinks, directory modes, OS identity, an empty image machine ID, service presets, compiled schemas and application MIME/desktop integration were checked.
- Helium, mise and VS Code execute as a non-root user. The native executables and VS Code's Node modules resolve their shared libraries. VS Code uses its official tar archive, with no Debian-package extraction.
- The graph resolves without duplicate-junction or missing-element errors. x86-64-v3 is disabled. The baseline build pulled 506 upstream artifacts; the kernel required a local build because its module-certificate inputs differ from upstream CI.
- Switching Dakota from the original `next` pin to the selected `testing` pin did not change the borrowed recipes or resolved artifact keys.
- Shell syntax, YAML, bootc TOML, Docker JSON, desktop files, local systemd units and GSettings overrides were checked. The complete image is rebuilt after recipe changes.

## VM checks that passed

- Installed from the exported OCI directory onto a fresh 48 GiB virtual disk using bootc's composefs backend, Btrfs and systemd-boot. The installer reported completion.
- Booted the installed disk through UEFI without a directly supplied kernel or helper root. `bootc status` reports the expected manifest, composefs deployment and systemd bootloader, with missing verity disallowed.
- Reached GNOME initial setup, created the `tester` administrator account without homed, entered a Wayland desktop, rebooted and logged in with its password.
- The root is a read-only composefs overlay. `/etc` and `/var` are writable Btrfs state. Test files in `/etc`, `/var` and the user's home, the machine ID and Helium/VS Code profile directories survived reboot.
- No failed system or user services remained after reboot and login. Homed and automatic bootc apply/reboot updates remain disabled.
- NetworkManager obtains network configuration, resolved works, and guest/container DNS and HTTPS requests succeed.
- Helium displays an HTTPS page. VS Code opens from GNOME and its integrated Bash terminal creates a file that survives reboot. Neither application needs a `--no-sandbox` launch option.
- Ghostty opens with its bundled resources and shell integration. Files, Disks and Settings open successfully.
- Files generates a PDF thumbnail. Pressing space opens that PDF through the Sushi Flatpak and renders its contents.
- Flatpak preinstallation installs Bazaar, Mission Center and Sushi. Bazaar loads the Flathub catalog and Mission Center opens. Uninstalling Mission Center and rerunning `flatpak preinstall` leaves it removed; it was then manually reinstalled for the retained test VM.
- Docker starts and runs a container with working DNS and HTTPS. Rootless Podman runs a separate container with working DNS and HTTPS under the account created by initial setup. Its subordinate UID/GID ranges are present.
- Distrobox creates and enters an Alpine container as the regular user using Podman.
- Tailscale starts and reports that it is logged out, as expected before enrollment. Libvirt socket activation works and `virsh -c qemu:///system list --all` succeeds. `/dev/kvm` is available in the guest.
- PipeWire and WirePlumber expose the virtual audio card, sink and source.

Screenshots and logs are retained locally under the ignored `build/vm` directory. See [VM notes](vm.md) for opening the disk and the installation method.

The PDF thumbnail check above predates removal of the thumbnailer dependency. Sushi remains installed for spacebar previews, but the current image does not provide PDF thumbnails.

## Fixes discovered during validation

- The Ghostty/ncurses terminfo overlap is handled by a local filter that permits only the bundled Ghostty terminfo replacement. Other overlaps remain fatal.
- `systemd-homed-firstboot.service` needed its own disable preset because its `Also=` setting could otherwise re-enable homed.
- The pinned OCI builder copied and hashed its tar before closing it. Podman accepted the resulting archive, but bootc's composefs importer failed at the final entry with `Unexpected EOF in splitstream`. The local packaging command closes the tar before upstream hashes and copies it. Installation then succeeds.
- The OCI root lacked `/sys`, which prevented systemd from switching out of the initramfs. Image assembly now explicitly creates `/dev`, `/proc` and `/sys`; a fresh installation then boots successfully.

The boot journal still has upstream initramfs warnings about groups absent from its reduced account database and tmpfiles messages about symlinked home paths and the read-only root. The corresponding accounts exist in the real root, and these messages do not leave failed services. They remain cleanup work rather than unreported clean-log checks.

## Remaining acceptance work

The first standard-runner CI build passed on September 18, 2026 and published the original kernel baseline to GHCR. It took 2h03m, pulling 695 artifacts and building 20; Linux 7.2.2 compilation took 77 minutes. The workflow uses upstream caches without preserving local artifacts between runs. The Dakota kernel switch has been checked locally but has not yet run in CI.

- Publish successive images and verify fetching, staging, rebooting into an update and rolling back. The current `localhost/personal-os:dev` origin is a placeholder, and automatic apply/reboot remains disabled.
- Adapt an end-user installer and test its account provisioning, origin selection and offline media. The temporary VM installer is not a distributable installer.
- Test accelerated graphics and real audio output, hardware support, Secure Boot signing and an actual libvirt guest. This run used software graphics and a discarded audio backend.
- Test Tailscale enrollment, browser credential storage, VS Code extensions and login callbacks, and application data across an OS update.
- Test Flatpak retries after a fresh offline boot, changes to preinstall declarations across an OS update, and Sushi previews on removable drives and network mounts.

These checks were not inferred from successful builds or VM startup.
