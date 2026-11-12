# Validation status

Changes are checked with a local build and, when they affect the running system, a fresh install in the disposable VM described in [VM notes](vm.md). Detailed results for each change are in its pull request.

## Verified in VMs

- The image builds, passes `bootc container lint`, installs with bootc's composefs backend, Btrfs and systemd-boot, and boots through UEFI into GNOME with no failed services.
- GNOME Initial Setup creates a conventional account. Password login and changes in `/etc`, `/var` and the home directory survive a reboot.
- Secure Boot enrollment, enforced boot, unsigned-module rejection and EFI refresh work. See [Secure Boot](secure-boot.md).
- NetworkManager and resolved provide networking. Docker with Compose and Buildx works alongside firewalld, as do rootless Podman and Distrobox.
- Libvirt's default network starts with dnsmasq, and a KVM guest boots through libvirt. Tailscale starts and waits for enrollment.
- Flatpak preinstallation installs the default apps and respects removals. Sushi renders previews from Files.
- GNOME Shell extensions install from extensions.gnome.org.
- The compromised eMudhra test hosts fail TLS verification through OpenSSL, GnuTLS and Python, while normal HTTPS works.
- PipeWire and WirePlumber expose the virtual audio device.

## Verified on hardware

Personal OS runs as a daily desktop on an AMD Ryzen 9000 system with a Radeon RX 7800 XT.

- An earlier installer ISO release installed it, with GNOME Initial Setup creating the account. It tracks the published registry image for updates.
- It boots through the enrolled shim chain with Secure Boot enforced and integrity lockdown. TPM 2.0 is present, and the AMD IOMMU runs in translated mode.
- Updates fetched from the published registry image stage and boot with Secure Boot still enabled.
- Accelerated graphics work on the amdgpu driver, and audio plays through HDMI and a USB headset.

## Known issues

- Installation and later reads of some image objects have logged fs-verity `FILE CORRUPTED` diagnostics, although the data read back matches the image. The cause is unknown.
- The initramfs warns about groups missing from its reduced account database. These messages do not leave failed services.
- GNOME Initial Setup's session can reach its shutdown timeout on the first reboot.

## Remaining checks

- Roll back to the previous deployment with Secure Boot enabled, through `bootc rollback` or the boot menu.
- Install through a current installer ISO, including offline installation and the live installer under Secure Boot. See [installer releases](installer.md).
- Apply a firmware capsule update through fwupd. EFI refresh and the fwupd shim path have been checked.
- Test EAC's host service with an actual protected game once Linux v2 support is available. Hardware and VM checks cannot establish Epic's acceptance. See [Secure Boot](secure-boot.md#eac-requirements-and-review-gates).
- Test Tailscale enrollment, a full libvirt guest installation, browser credential storage and application data across an OS update.
- Test Bazaar Companion's menu actions and Gradia Capture's screenshot annotations.
- Test Flatpak retries after an offline first boot, preinstall changes across an OS update, and Sushi previews on removable drives and network mounts.
- Measure Chunkah's layer reuse and CI cost across two builds with a small update.
