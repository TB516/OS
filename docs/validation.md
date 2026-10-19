# Bring-up status

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

## Dakota OCI kernel import, October 18, 2026

- Imported the regular amd64 Dakota image at `sha256:bd5b60fa1afe62fcfc6ca6607c95af5fa66a622aae0ba5566cdacc099f73fa13`, published from source commit `bd5d9137bcbc0d9508698172767fcf33a8265572`. The recipe junction retains main's `5fe625712433e902124eedf5ec2c82880dbcaddc` pin, which differs from that image revision only in a Prow workflow.
- The pinned BuildStream docker plugin fetched all 120 OCI/zstd layers with the local format-compatibility patch. Compressed layer downloads total about 3.73 GB. The extracted artifact is about 638 MiB and contains only `/usr/lib/modules/7.2.9`, including 4,345 compressed modules, with Dakota's initramfs removed.
- The kernel import built without compiling Linux. GNOME's OCI initramfs built from the imported modules. Unpacking it confirmed that its Btrfs module is byte-for-byte identical to the imported module. The initramfs SHA-256 is `7902cfa7491dd5d74c429e552e54d55ef3d5c61a760eec435c18645e623cedb8`.
- Simplified the import to track the image's `testing` channel independently through Renovate's Docker datasource. Removed the registry-sync hook and the unused GNOME kernel-build override, and restored the original Dakota recipe pin. All resolved artifact keys still match the VM-tested image, and a follow-up full-image build passed from cache.
- Moved the shared plugin junctions to release tags pinned by Git commit, managed directly by Renovate. The official plugins now use 2.8.0; the community plugins retain 2.3.1. Removed GNOME's plugin-copying hook. The smaller downloader patch adds seven lines and removes five, and its executable Python AST matches the previously tested downloader exactly. All 978 artifact keys are unchanged, project validation passes, and the full image build succeeds from cache. Renovate 44.164.4 resolved both repositories' release commits and successfully updated/re-extracted disposable recipes, including a community-plugin update to 2.4.0. The checked-in community version remains 2.3.1. A disposable Git fixture with a deliberately incorrect Docker archive checksum exercised the remaining helper; it restored the exact pinned checksum without changing the other sources.
- Compared the full graph with an untouched checkout of `main`: 969 existing artifact keys are unchanged. Only eight existing keys changed, all in initramfs and final-image assembly; the new import replaces the unsigned-module copier.
- Project validation, shell and Node syntax checks, JSON parsing and diff whitespace checks passed. Renovate 44.164.4 validated the configuration, extracted the kernel dependency, resolved the live `testing` tag to its amd64 digest and successfully rewrote/re-extracted a disposable copy. BuildStream's source tracking also returned that digest with the standard prefix. The checked-in pin remains the VM-tested image.
- The full OCI image built successfully with no failed tasks. Its manifest is `sha256:099f23c97c06c708776ee23d1606eed50e6b7cc75e15d1d1f35352c9f202c944`. The image passed `bootc container lint` with 13 checks passed and one skipped. A temporary local configuration gave Bluefin's cache priority after stalled downloads; the checked-in cache settings are unchanged.
- Installed that image onto a fresh 48 GiB virtual disk using bootc, composefs, Btrfs and systemd-boot. The installer completed successfully. The installed disk booted through UEFI without a directly supplied kernel or helper root, reached GNOME initial setup, and reported Linux 7.2.9. GDM and the graphical target were active with no failed system units. The booted kernel SHA-256 matches the imported file.
- A guest reboot changed the boot ID, retained a marker in `/var/tmp`, and returned to Linux 7.2.9 with GDM and the graphical target active and no failed system units. The kernel hash and Btrfs module version still matched after reboot.
- The VM uses the local test origin `localhost/personal-os:dev`. It does not validate registry updates, the ISO installer or Secure Boot enforcement.
- Evidence is under the ignored `build/oci-kernel` directory. The current image is unsigned; Secure Boot enrollment, signed EFI binaries, enforced boot and update/rollback validation await integration with Dakota's merged signing work. EAC acceptance has not been tested.

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

The first standard-runner CI build passed on September 18, 2026 and published the original kernel baseline to GHCR. It took 2h03m, pulling 695 artifacts and building 20; Linux 7.2.2 compilation took 77 minutes. The workflow uses upstream caches without preserving local artifacts between runs. The Dakota kernel switch has been checked locally but has not yet run in CI.

- Publish successive images and verify fetching, staging, rebooting into an update and rolling back. The current `localhost/personal-os:dev` origin is a placeholder, and automatic apply/reboot remains disabled.
- Adapt an end-user installer and test its account provisioning, origin selection and offline media. The temporary VM installer is not a distributable installer.
- Test accelerated graphics and real audio output, hardware support, Secure Boot signing and an actual libvirt guest. This run used software graphics and a discarded audio backend.
- Test Tailscale enrollment, browser credential storage, VS Code extensions and login callbacks, and application data across an OS update.
- Test Flatpak retries after a fresh offline boot, changes to preinstall declarations across an OS update, and Sushi previews on removable drives and network mounts.

These checks were not inferred from successful builds or VM startup.
