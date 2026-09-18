# Personal OS

A GNOME 51 desktop built on freedesktop-sdk 26.08. The system image uses bootc, systemd-boot and Btrfs. Desktop applications come primarily from Flathub.

The OS includes native Helium and Visual Studio Code, Ghostty, Docker with Compose and Buildx, Podman, Distrobox, Tailscale, and QEMU/libvirt. Bazaar installs as a Flatpak after the first boot with an internet connection.

For development tools, install [mise in your user account](https://mise.jdx.dev/getting-started.html) once after setting up the OS. It updates independently through `mise self-update`; `mise upgrade` updates the tools it manages.

The image builds and boots to GNOME in a VM. Desktop apps, containers and persistence across reboot have been tested. An installer release workflow is prepared, but the installer has not yet been built or tested. See the [installer guide](docs/installer-plan.md) for creating a release and preparing a USB drive.

To inspect or build it with the project's BuildStream container:

```sh
just graph
just build
just export
```

Every build includes the full OS. `just export` writes its OCI layout to `build/image`. See the [build guide](docs/building.md) for requirements, image naming and publishing, [VM notes](docs/vm.md) for opening the local test disk, and [validation notes](docs/validation.md) for what has been checked and what remains.
