# Validation status

Changes are checked with a local build and, when they affect the running system, a fresh install in the disposable VM described in [VM notes](vm.md). Detailed results for each change are in its pull request.

## Verified in VMs

- The image builds, passes `bootc container lint`, installs with bootc's composefs backend, Btrfs and systemd-boot, and boots through UEFI into GNOME with no failed services.
- GNOME Initial Setup creates a conventional account. Password login and changes in `/etc`, `/var` and the home directory survive a reboot.
- Secure Boot enrollment, enforced boot, unsigned-module rejection and EFI refresh work. See [Secure Boot bring-up](secure-boot.md).
- NetworkManager and resolved provide networking. Docker with Compose and Buildx works alongside firewalld, as do rootless Podman and Distrobox.
- Libvirt's default network starts with dnsmasq, and a KVM guest boots through libvirt. Tailscale starts and waits for enrollment.
- Flatpak preinstallation installs the default apps and respects removals. Sushi renders previews from Files.
- GNOME Shell extensions install from extensions.gnome.org.
- The compromised eMudhra test hosts fail TLS verification through OpenSSL, GnuTLS and Python, while normal HTTPS works.
- PipeWire and WirePlumber expose the virtual audio device.

## Known issues

- Installation and later reads of some image objects have logged fs-verity `FILE CORRUPTED` diagnostics, although the data read back matches the image. The cause is unknown.
- The initramfs warns about groups missing from its reduced account database, and tmpfiles warns about symlinked home paths and the read-only root. Neither leaves failed services.
- GNOME Initial Setup's session can reach its shutdown timeout on the first reboot.

## Remaining checks

- Publish successive images and verify fetching, staging, rebooting into an update and rolling back, including with Secure Boot enabled.
- Install through the installer ISO, including account creation, update origin and offline media. See [installer releases](installer-plan.md).
- Test accelerated graphics, audible output, physical hardware, firmware capsule updates, TPM disk unlock and EAC. See [Secure Boot bring-up](secure-boot.md).
- Test Tailscale enrollment, a full libvirt guest installation, browser credential storage and application data across an OS update.
- Test Bazaar Companion's menu actions and Gradia Capture's screenshot annotations.
- Test Flatpak retries after an offline first boot, preinstall changes across an OS update, and Sushi previews on removable drives and network mounts.
- Measure Chunkah's layer reuse and CI cost, and verify a fresh chunked-image installation and upgrade in a VM. CI-published chunked images already boot on the host.
