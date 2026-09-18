# Building the OS image

## Requirements

The supplied commands use Podman and just. Publishing also needs skopeo and registry credentials. The BuildStream runner uses a freedesktop-sdk builder container, pinned by digest in `include/builder-image.txt`. It runs rootless with FUSE and the permissions required for BuildStream's nested sandboxes.

Obtain the builder image before running these commands, or set `BST_IMAGE` to an already installed compatible image. The runner never pulls a container automatically or installs host tools.

For a native BuildStream installation with its source-plugin prerequisites, use:

```sh
bst --config buildstream.conf show oci/image.bst
```

BuildStream 2.6 or later is required. Validation used 2.7 in the builder container. Native installations also need source-plugin tools such as `git` and `patch`.

The OS uses the baseline x86_64 target. x86-64-v3 is disabled in both the GNOME and Dakota junctions to match their normal upstream builds and improve artifact-cache reuse. GNOME passes this option through to freedesktop-sdk.

Artifact reuse still requires matching source revisions, recipes and build dependencies. Local image configuration and components whose inputs differ from upstream need rebuilding. BuildStream retains completed artifacts for later runs.

## Image settings

Edit `include/image.yml` before building a publishable image:

```yaml
variables:
  image-ref: ghcr.io/YOUR_ACCOUNT/YOUR_IMAGE:latest
  image-name: Personal OS
  image-id: personal-os
  image-version: '51.0'
  go-arch: amd64
```

Use a lowercase GHCR account and repository. The checked-in reference is `ghcr.io/tb516/os:latest`. The name, ID and version feed `os-release`; the reference becomes the OCI index annotation. The eventual installer must also pass the intended reference as the installed system's tracking origin. An OCI annotation alone does not configure that origin.

## Commands

```sh
# Resolve every build and runtime dependency.
just graph

# Inspect the software that actually enters the image.
just contents

# Build and export the full OS image.
just build
just export
```

The OCI layout is exported to `build/image`. Export refuses to replace an existing directory. Move an old export aside before making another one.

BuildStream stores sources and artifacts in the normal user cache. Both public caches are read-only. `buildstream.conf` makes those caches available to junction projects too. The first full build may require substantial downloads and compilation. Graph inspection does not compile components, but it may download the pinned junction sources needed to load their definitions.

The GitHub build workflow uses the same upstream caches. It starts fresh on each run and does not save local artifacts to GitHub Actions caches. It limits compilation to one element at a time with four jobs and skips storing build trees to reduce runner resource use. Build output remains available in the workflow logs.

After logging in to GHCR, publish an exported image with the same reference configured for that build:

```sh
skopeo login ghcr.io
just publish ghcr.io/YOUR_ACCOUNT/YOUR_IMAGE:latest
```

The GitHub build workflow publishes on pushes to `main`. See [automation](automation.md) for dependency update PRs and repository setup. The commands above also support local publication.

## Dependency ownership

See [design history](plan.md) for the composition decisions and remaining milestones.

| Input | Pinned revision |
| --- | --- |
| GNOME `gnome-51` | `a50b8c9de35f51c6a646c8178cde3c2c176725b6`, tag `51.0` |
| freedesktop-sdk | `db97cce32cecadc7a3e98f06d557ebfa6ba9ad46`, tag `freedesktop-sdk-26.08.0` |
| Dakota `testing` | `53191a4787fee1fc44b0447cfd90290b042ae3b5` |

GNOME owns the nested freedesktop-sdk junction, its patch queue, and its component overrides. Both of Dakota's base junctions redirect into that graph. Dakota and GNOME also share the top-level plugin junctions. The freedesktop-sdk project's internal plugins retain their upstream isolation.

Do not run broad source tracking during bring-up. Review GNOME, freedesktop-sdk and Dakota together when updating these pins. Normal builds use the committed refs, not the tips of the tracking branches.

Local stacks own the session, native application selection, boot configuration and image assembly. Files and Disks are native applications in the OS. The runtime omits GNOME Software, native Papers and Sushi, Tour, GNOME user documentation, and Dakota's aggregate configuration. Papers still appears in the full build graph because the thumbnailer recipe extracts files from its build artifact.

Settings, initial setup and the SDK platform use their upstream recipes. Parental controls and the Yelp Help viewer remain included to avoid maintaining custom recipes for these optional components.

Dakota supplies Ghostty, xdg-terminal-exec, Tailscale, virtualization, the thumbnailer, the unsigned kernel-module copier, and three small network/audio/disk integration fixes. Its gaming kernel, swap changes and Homebrew stack are not selected.

The kernel is Dakota's regular freedesktop-sdk-derived kernel, selected at the GNOME junction so the image, modules and initramfs share it. The pinned Dakota testing recipe supplies Linux 7.2.6 with additional hardware drivers and built-in Zstd compression. GNOME's zram configuration stays in place. GNOME supplies bootc 1.16.6; this definition does not take Dakota's 1.16.12 override without a demonstrated need. The initial image has no Secure Boot signing setup.

The selected kernel's artifact key matches Dakota's pinned build and was successfully pulled from Bluefin's cache. The previous GNOME kernel missed upstream caches because its module-certificate inputs differed from GNOME CI. Reusing Dakota's artifact avoids that compilation without a project-owned cache. Future pin changes can still cause cache misses.

Docker Engine 29.8.1, Compose 5.5.1 and Buildx 0.37.1 use official binary releases pinned by SHA-256. Docker's containerd/runc helpers live under `/usr/libexec/docker`. Only its service adds that directory to PATH. The mise binary lives in each user's home directory and is not part of the image or Renovate's dependencies.

`mise-bootstrap.service` runs at user login and uses the official `https://mise.run` installer to install mise into `~/.local/bin/mise`. The installer selects the release and verifies its download. System accounts are excluded. An existing file at that path skips installation; failures retry every 15 minutes while the user manager is running. A successful installation is left alone on subsequent logins. Removing the binary makes it eligible for installation again; use `systemctl --user mask --now mise-bootstrap.service` to opt out first.

The image supplies Bash activation through `/etc/profile.d/mise.sh` and adds mise and its shims to the desktop session's PATH through `environment.d`. Open a new terminal after installation finishes. Other shells need their own mise activation configuration. To inspect or retry installation, use `journalctl --user -u mise-bootstrap.service` or `systemctl --user restart mise-bootstrap.service`. No tools are installed automatically, and subsequent mise and tool upgrades remain user-managed.

`10-xdg.conf` in `/usr/lib/environment.d` sets the standard XDG base directory defaults for user services and desktop applications. `/etc/profile.d/10-xdg.sh` supplies the same defaults to SSH and text-console login shells. Both fill unset or empty values and preserve existing overrides, including Flatpak search paths. The home defaults are `~/.config`, `~/.local/share`, `~/.local/state` and `~/.cache`; system search defaults are `/etc/xdg` and `/usr/local/share:/usr/share`. These files run before the corresponding mise configuration. `XDG_RUNTIME_DIR` remains session-managed. To override desktop defaults, use a later file such as `~/.config/environment.d/90-local.conf`, then log out and back in. Custom shell overrides belong in the user's shell startup files; environment.d overrides do not automatically carry over to SSH. Non-interactive SSH commands may not read `/etc/profile`.

Helium 0.17.1.1 and Microsoft Visual Studio Code 1.138.0 are native image applications installed from official Linux tar archives. Helium lives under `/usr/lib/helium`, with its upstream wrapper exposed as `helium`. VS Code lives under `/usr/share/code`, with its upstream CLI exposed as `code`. The small files under `files/vscode` retain Microsoft's desktop launchers, URL handling, workspace MIME metadata, AppStream metadata and shell completions from the pinned release; review these against upstream's `resources/linux` and `resources/completions` when updating. Both archives are pinned by SHA-256; VS Code uses Microsoft's versioned tar download URL. Their libraries come from the shared GNOME/freedesktop-sdk graph. Browser and Electron sandboxing remain enabled.

These applications update with the OS image. Renovate proposes source URL and checksum changes; merging into `main` triggers a build and publication. Deploy the new image to update installed applications. User profiles and VS Code extensions stay in the user's home directory. Desktop integration and application bundles live under `/usr`; `/opt` is reserved for writable state on this OS.

## Desktop behavior

Ghostty is the preferred terminal, including Ctrl+Alt+T. The build installs its resources through Dakota's full Ghostty recipe. A local filter preserves that cached artifact and permits its bundled `terminfo/g/ghostty` entry to replace ncurses' copy. It repeats Ghostty's runtime dependencies because BuildStream filters do not inherit them; review that short list when updating Dakota. The local configuration adds terminal selection, GNOME defaults and an editable dconf shortcut. It imposes no prompt, font or shell framework.

Docker starts as a system service. Use `sudo docker` initially. Adding an account to the `docker` group is a separate local choice that grants control of the root daemon. Distrobox uses its upstream autodetection, which prefers the included Podman, and runs rootless by default for regular users. No image-level Distrobox configuration overrides that choice. Docker remains available independently with Compose and Buildx.

Tailscale starts without enrollment. Run `sudo tailscale up` after installing. Its machine state belongs in writable `/var`, never in the image definition.

Libvirt uses socket activation and Dakota's dedicated QEMU account settings. The image includes UEFI guest firmware. No VM GUI frontend is preinstalled.

At each boot, `flatpak-preinstall.service` runs `flatpak preinstall --system --noninteractive` after the network-online target. It reads `files/system/usr/share/flatpak/preinstall.d/personal-os.preinstall` and uses the Flathub remote declaration supplied by GNOME. Failed attempts retry every 15 minutes, including when the machine starts offline; the service stops retrying after success.

Flatpak tracks preinstalled apps itself and respects manual uninstalls. Changes to the declarations take effect on the next run, including removal of previously managed apps that are no longer declared. There is no separate installation marker or shell installer. Each Flatpak declares its own runtime. Bazaar can manage subsequent Flatpak updates. To retry immediately, run `sudo systemctl restart flatpak-preinstall.service`.

The default Flatpaks are Bazaar, Mission Center and Sushi (`org.gnome.NautilusPreviewer`). Sushi exports the D-Bus service used by Files for spacebar previews. Its current Flathub build grants read access to the home directory; previews on removable drives or network mounts may need additional permissions. Verify preview activation, navigation and file access in the VM before considering this integration complete.

The current update path is manual:

```sh
sudo bootc status
sudo bootc upgrade
# Reboot when ready to use the staged deployment.
sudo bootc rollback
flatpak update
```

The definition enables background bootc updates with a service override that stages them for the next user-initiated reboot. GNOME sysupdate units remain disabled. It also disables homed's main, activation and first-boot services for conventional account creation. The first-boot service must be disabled explicitly because its `Also=` setting can re-enable homed when presets are applied. OS updates do not manage a user's mise executable or tools.

## Boot and installation

The OCI recipe carries the kernel, initramfs, bootc integration, systemd boot files and Btrfs tools. It prepares users, service presets, library caches and image metadata before packaging.

The pinned freedesktop-sdk OCI builder copies its layer before closing the tar archive. The local image command wraps layer creation to close the archive before upstream hashes and copies it. Without the closing blocks, bootc's composefs importer fails with `Unexpected EOF in splitstream` at the final directory. Remove this workaround when the pinned builder closes the tar before hashing it.

Image assembly also creates `/dev`, `/proc` and `/sys` explicitly. BuildStream's virtual filesystem mounts do not supply artifact directories, and systemd cannot switch to an immutable root that lacks these mount points.

The install defaults select `bootloader = "systemd"` and Btrfs. Dakota's current default is XFS, which is why this small configuration is local. A bootc installation must explicitly select `--composefs-backend`; the inherited OSTree `prepare-root.conf` is not a substitute for that option.

A temporary installer VM has installed the image onto a virtual disk, which boots through UEFI into GNOME. `just vm` opens that local test disk. See [VM notes](vm.md) for the installation method and [validation notes](validation.md) for results and remaining checks. An end-user installer, published update origin and update/rollback testing remain to be implemented.

## Upstream references

- [GNOME build metadata at the selected revision](https://gitlab.gnome.org/GNOME/gnome-build-meta/-/tree/a50b8c9de35f51c6a646c8178cde3c2c176725b6)
- [Dakota at the selected revision](https://github.com/projectbluefin/dakota/tree/53191a4787fee1fc44b0447cfd90290b042ae3b5)
- [Docker binary installation](https://docs.docker.com/engine/install/binaries/)
- [mise installation](https://mise.jdx.dev/installing-mise.html)
- [Helium Linux releases](https://github.com/imputnet/helium-linux/releases)
- [Visual Studio Code on Linux](https://code.visualstudio.com/docs/setup/linux)

The image assembly follows the GNOME and Dakota recipes at those revisions. The plugin junction declarations come from GNOME build metadata. Upstream components retain their own licenses.
