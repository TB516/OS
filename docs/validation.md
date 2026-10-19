# Bring-up status

## Signed boot integration, October 18, 2026

- Dakota recipes are pinned to merged Secure Boot commit `e59afbe788e441fc1fad560c01fa4dbc267d60d8`. The boot payload independently uses the production `testing` image at revision `95ff6c060392d2c3b05c82d057b1e9e5adf59eb8`, amd64 digest `sha256:4697e6606ae5c23b58e24c2001654af60a614d977d23d37cc9358baa17d103a7`.
- The signed import and full OS image build pass. The import verifies kernel and EFI signatures against Dakota's certificate, requires module signatures and checks kernel security capabilities. No kernel compilation or private signing elements are involved. Bootc container lint reports 13 passed checks and one skipped check.
- Exported and installed OS manifest `sha256:b879cb1bb871fa2e85e585ceb7275ee7296a3c60fe0570f813b43f7e819ba164`, using Linux 7.2.9. All 4,345 modules, the kernel, EFI binaries and certificate match the imported artifact byte for byte. All 426 modules included in our generated initramfs retain their original bytes; the final image contains that same initramfs. Dakota's certificate SHA-256 is `b261aa6adf2702563105b6db8234729e4f7a384a7b5e7f5e32c46c8153b0d7c`.
- Installed onto a disposable 48 GiB disk using a helper VM. Booted through QEMU's Secure Boot capable OVMF firmware with SMM, a persistent software TPM 2.0 and an emulated Intel IOMMU. Ran Dakota's enrollment command, approved its certificate in MokManager, then enabled firmware Secure Boot with Microsoft's UEFI certificates. Dakota's key is in MOK, not the firmware trust database.
- The enforced boot reaches GNOME Initial Setup with no failed services. `bootctl` reports Secure Boot enabled and the current loader under `EFI/dakota`. Dakota's checker reports eight passes and two waits for Epic recognizing the Dakota key. TPM PCRs 9 and 12 are nonzero; lockdown is integrity, kexec is disabled, BPF LSM is active and virtual IOMMU translation is enabled. This is a conventional kernel/initramfs boot, not a measured UKI.
- A signed `dummy` module loads successfully. Removing its signature makes insertion fail with `Key was rejected by service`; the kernel records `Loading of unsigned module is rejected`.
- The enabled maintenance service restores a deliberately stale Dakota EFI bootloader and a missing fwupd shim copy to the image's bytes. The fallback shim also matches. A one-shot direct boot of `EFI/systemd/systemd-bootx64.efi` bypassing shim fails with firmware `Access Denied`, then the normal shim chain boots successfully again.
- The installer completes with exit zero despite the same fs-verity corruption diagnostic recorded during Docker testing. The installed image boots successfully afterward; that diagnostic remains unresolved. GNOME Initial Setup's session also reaches its shutdown timeout on the first normal reboot.
- Dependency-graph resolution, edited YAML/TOML parsing, shell syntax and whitespace checks pass. Evidence and the powered-off VM remain under ignored `build/secureboot`. No host firmware, boot entries, installed OS or disk encryption state was changed.
- OS update/rollback under Secure Boot, actual fwupd capsule execution, hardware TPM/IOMMU state, TPM-encrypted disk unlock and EAC/game acceptance remain untested. [Secure Boot bring-up](secure-boot.md) describes the remaining checks. A VM and Dakota's diagnostic cannot establish Epic's key acceptance.

## Docker image import, October 18, 2026

- Started from local `main` at `142d756`, independently of the kernel worktree. Reused its shared plugin prerequisite: BuildStream plugins 2.8.0, direct release/commit pins for both plugin junctions, and the same OCI compatibility patch. No kernel recipe or source pins changed.
- BuildStream fetched the Linux amd64 manifest of `docker.io/library/docker:29.9.1-dind` at `sha256:d18cae6d97a9ebf10a017859d3cdf728de0f2efc465364ba0bab6e2c9a87ccdc` and built the Docker element. The full OS image build passed in 2m48s with nine build tasks using the existing cache. All selected Docker files survived the image exclusions with identical bytes and permissions.
- Installed OS manifest `sha256:9b948f219686c98cc18ef3bfda289daedda641047279e64030d7ce691d9eddfd` onto a fresh disposable 48 GiB disk. It booted through UEFI/systemd-boot with Linux 7.2.9 and a read-only composefs root requiring verity. The other checkout and host Docker state were untouched.
- Docker starts with the unchanged systemd service and daemon configuration while firewalld is active. Engine/CLI report 29.9.1, Compose 5.6.0, and Buildx 0.38.0. The daemon reports embedded containerd 2.4.2; there is no standalone containerd binary or process. Runtime helpers remain private under `/usr/libexec/docker`.
- Docker containers passed DNS and outbound HTTPS, custom bridge service-name lookup, `--init`, and HTTP through guest-localhost port 18080. Compose brought up a service, executed a command, and served HTTP on port 18081. Buildx built and loaded an image with an executed `RUN` step; running that image returned the expected output.
- A separate regular user ran rootless Podman using `/usr/bin/crun`, with DNS and outbound HTTPS. Its running container remained usable across `systemctl restart docker`. Both Docker and Compose services recovered their published ports after that restart, and fresh Docker containers still passed DNS and HTTPS. Test workloads were removed afterward.
- Renovate 44.164.4 strict configuration validation passed. Its actual regex extraction, live Docker datasource lookup, and replacement logic preserved the amd64 manifest pin and changed the tag/digest together using `29.9.0-dind` as a test input. The extra live plugin lookup hit GitHub's unauthenticated API rate limit; both plugin commit pins were independently verified against their Git release tags.

Before opening the PR, rebooted the installed disk and reran the corrected full test script end-to-end. It exited with status 0, including an uncached Buildx build, Docker/Compose published ports after daemon restart, and the rootless Podman checks. Docker and firewalld remained active; that boot had no fs-verity corruption messages during the runtime checks. The complete output is retained as `build/docker-import/pr-test-results.log`.

Evidence, temporary test scripts, and the powered-off VM are retained under ignored `build/docker-import`. The first test attempts exposed two fixture assumptions, Alpine lacking `httpd` and the OS lacking `runuser`. The successful checks used the official BusyBox image for HTTP and systemd to run Podman as the regular user. No OS packaging adjustment was needed for those fixtures.

The installer and a later read of stored image objects logged fs-verity `FILE CORRUPTED` diagnostics. The affected objects map to the unchanged QEMU binary, Rusticl and SVT-AV1 libraries, and kernel `vmlinux`. Reads returned hashes matching the composed image, and the Docker runtime checks passed, but the diagnostics remain unexplained. This was not a clean-log VM run. Existing Docker data migration, a cold CI build, non-amd64 platforms, and an OS update/rollback were not tested.

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

This section records the image tested then. Helium and VS Code have since been removed; their checks below do not apply to the current image.

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

The first standard-runner CI build passed on September 18, 2026 and published the original kernel baseline to GHCR. It took 2h03m, pulling 695 artifacts and building 20; Linux 7.2.2 compilation took 77 minutes. The workflow uses upstream caches without preserving local artifacts between runs. The signed OCI kernel import has passed local build and VM checks; its first CI build will run after merge.

- Publish successive images and verify fetching, staging, rebooting into an update and rolling back. The current `localhost/personal-os:dev` origin is a placeholder, and automatic apply/reboot remains disabled.
- Adapt an end-user installer and test its account provisioning, origin selection and offline media. The temporary VM installer is not a distributable installer.
- Test accelerated graphics and real audio output, hardware support, Secure Boot enrollment on physical hardware and an actual libvirt guest. This run used software graphics and a discarded audio backend.
- Test Tailscale enrollment, browser credential storage and login callbacks, and application data across an OS update.
- Test Flatpak retries after a fresh offline boot, changes to preinstall declarations across an OS update, and Sushi previews on removable drives and network mounts.

These checks were not inferred from successful builds or VM startup.
