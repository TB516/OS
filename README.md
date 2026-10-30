# Personal OS

A GNOME 51 desktop built on freedesktop-sdk 26.08. The system image uses bootc, systemd-boot and Btrfs. Desktop applications come primarily from Flathub.

An x86-64-v3 CPU is required, including all AMD Ryzen CPUs and Intel Haswell Core processors or newer. See the [CPU requirements](docs/building.md#requirements) for model exceptions and VM setup.

The OS includes native Ghostty, Docker with Compose and Buildx, Podman, Distrobox, Tailscale, and QEMU/libvirt. Bazaar installs as a Flatpak after the first boot with an internet connection.

For development tools, [mise](https://mise.jdx.dev/getting-started.html) installs in your user account automatically after login with an internet connection. Open a new terminal once installation finishes. It updates independently through `mise self-update`; `mise upgrade` updates the tools it manages.

The image builds and boots to GNOME in a VM. Desktop apps, containers and persistence across reboot have been tested. Installer releases are available, but their installation path still needs VM testing. See the [installer guide](docs/installer-plan.md) for creating a release and preparing a USB drive.

Secure Boot has passed VM testing using Dakota's signing key. See the [Secure Boot guide](docs/secure-boot.md) for enrollment and remaining hardware checks.

To inspect or build it with the project's BuildStream container:

```sh
just graph
just build
just export
```

Every build includes the full OS. `just export` writes its OCI layout to `build/image`. See the [build guide](docs/building.md) for requirements, image naming and publishing, [VM notes](docs/vm.md) for opening the local test disk, and [validation notes](docs/validation.md) for what has been checked and what remains.
