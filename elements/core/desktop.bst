kind: stack
description: GNOME desktop and host services for the first bootable image

depends:
- core/apps.bst
- gnome.bst:core/meta-gnome-core-os-services.bst
- core/session.bst
- gnome.bst:sdk-platform.bst
- gnome.bst:core/systemd-presets.bst
- gnome.bst:gnomeos-deps/preset-all.bst
- gnome.bst:core-deps/xdg-desktop-portal-gnome.bst
- gnome.bst:core-deps/xdg-desktop-portal-gtk.bst
- gnome.bst:core-deps/flatpak.bst
- gnome.bst:core-deps/fwupd.bst
- gnome.bst:gnomeos-deps/flathub-config.bst
- gnome.bst:gnomeos-deps/journald-config.bst
- gnome.bst:gnomeos-deps/nm-connectivity-config.bst
- gnome.bst:gnomeos-deps/wpa-supplicant-config.bst
- gnome.bst:gnomeos-deps/plymouth-gnome-theme.bst
- gnome.bst:gnomeos-deps/spice-vdagent.bst
- gnome.bst:gnomeos-deps/alsa-ucm-conf.bst
- gnome.bst:gnomeos-deps/nss-mdns.bst
- gnome.bst:gnomeos-deps/ld-config.bst
- gnome.bst:gnomeos-deps/modprobe-config.bst
- gnome.bst:gnomeos-deps/zram-generator.bst
- gnome.bst:gnomeos-deps/fprintd.bst
- gnome.bst:gnomeos-deps/iio-sensor-proxy.bst
- gnome.bst:gnomeos-deps/firewalld.bst
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst
- gnome.bst:freedesktop-sdk.bst:vm/mesa-default.bst
- gnome.bst:freedesktop-sdk.bst:components/pipewire-daemon.bst
- gnome.bst:freedesktop-sdk.bst:components/wireplumber.bst
- gnome.bst:freedesktop-sdk.bst:components/linux-firmware.bst
- gnome.bst:freedesktop-sdk.bst:components/sof-firmware.bst
- gnome.bst:freedesktop-sdk.bst:components/wireless-regdb-bin.bst
- gnome.bst:freedesktop-sdk.bst:components/bash-config.bst
- gnome.bst:freedesktop-sdk.bst:components/bash-completion.bst
- gnome.bst:freedesktop-sdk.bst:components/iproute2.bst
- gnome.bst:freedesktop-sdk.bst:components/iputils.bst
- gnome.bst:freedesktop-sdk.bst:components/nano.bst
- gnome.bst:freedesktop-sdk.bst:components/rsync.bst

# Small integration fixes are consumed directly from the pinned Dakota graph.
- dakota.bst:bluefin/network.bst
- dakota.bst:bluefin/composefs-loop-udisks-ignore.bst
- dakota.bst:bluefin/wireplumber-pcsp.bst

# Terminal, development tools and services.
- core/appstream-cli.bst
- core/eu-strip.bst
- core/strip.bst
- core/docker.bst
- core/ghostty.bst
- dakota.bst:bluefin/xdg-terminal-exec.bst
- dakota.bst:bluefin/tailscale.bst
- dakota.bst:bluefin/virtualization.bst
- gnome.bst:gnomeos-deps/distrobox.bst
- gnome.bst:gnomeos-deps/wl-clipboard.bst
- gnome.bst:freedesktop-sdk.bst:components/podman.bst
- gnome.bst:freedesktop-sdk.bst:components/containers-common.bst
- gnome.bst:freedesktop-sdk.bst:components/flatpak-builder.bst
- gnome.bst:freedesktop-sdk.bst:components/patch.bst
- gnome.bst:freedesktop-sdk.bst:components/ovmf-maybe.bst
- gnome.bst:freedesktop-sdk.bst:components/git.bst
- gnome.bst:freedesktop-sdk.bst:components/curl.bst
