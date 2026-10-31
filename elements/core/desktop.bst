kind: stack
description: GNOME desktop and host services

depends:
- core/apps.bst
- dakota.bst:gnome-build-meta.bst:core/meta-gnome-core-os-services.bst
- core/session.bst
- dakota.bst:gnome-build-meta.bst:sdk-platform.bst
- dakota.bst:gnome-build-meta.bst:core/systemd-presets.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/preset-all.bst
- dakota.bst:gnome-build-meta.bst:core-deps/xdg-desktop-portal-gnome.bst
- dakota.bst:gnome-build-meta.bst:core-deps/xdg-desktop-portal-gtk.bst
- dakota.bst:gnome-build-meta.bst:core-deps/flatpak.bst
- dakota.bst:gnome-build-meta.bst:core-deps/fwupd.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/flathub-config.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/journald-config.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/nm-connectivity-config.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/wpa-supplicant-config.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/plymouth-gnome-theme.bst
- dakota.bst:gnome-build-meta.bst:freedesktop-sdk-extra.bst:components/spice-vdagent.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/alsa-ucm-conf.bst
- dakota.bst:gnome-build-meta.bst:freedesktop-sdk-extra.bst:components/nss-mdns.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/ld-config.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/modprobe-config.bst
- dakota.bst:gnome-build-meta.bst:freedesktop-sdk-extra.bst:components/zram-generator.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/fprintd.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/iio-sensor-proxy.bst
- dakota.bst:gnome-build-meta.bst:gnomeos-deps/firewalld.bst
- dakota.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst
- dakota.bst:freedesktop-sdk.bst:vm/mesa-default.bst
- dakota.bst:freedesktop-sdk.bst:components/pipewire-daemon.bst
- dakota.bst:freedesktop-sdk.bst:components/wireplumber.bst
- dakota.bst:freedesktop-sdk.bst:components/linux-firmware.bst
- dakota.bst:freedesktop-sdk.bst:components/sof-firmware.bst
- dakota.bst:freedesktop-sdk.bst:components/wireless-regdb-bin.bst
- dakota.bst:freedesktop-sdk.bst:components/bash-config.bst
- dakota.bst:freedesktop-sdk.bst:components/bash-completion.bst
- dakota.bst:freedesktop-sdk.bst:components/iproute2.bst
- dakota.bst:freedesktop-sdk.bst:components/iputils.bst
- dakota.bst:freedesktop-sdk.bst:components/nano.bst
- dakota.bst:freedesktop-sdk.bst:components/rsync.bst

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
- dakota.bst:gnome-build-meta.bst:freedesktop-sdk-extra.bst:components/distrobox.bst
- dakota.bst:gnome-build-meta.bst:freedesktop-sdk-extra.bst:components/wl-clipboard.bst
- dakota.bst:freedesktop-sdk.bst:components/podman.bst
- dakota.bst:freedesktop-sdk.bst:components/containers-common.bst
- dakota.bst:freedesktop-sdk.bst:components/flatpak-builder.bst
- dakota.bst:freedesktop-sdk.bst:components/patch.bst
- dakota.bst:freedesktop-sdk.bst:components/ovmf-maybe.bst
- dakota.bst:freedesktop-sdk.bst:components/git.bst
- dakota.bst:freedesktop-sdk.bst:components/curl.bst
