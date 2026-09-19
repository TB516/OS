kind: manual
description: Native Helium browser from its pinned official Linux release

sources:
- kind: tar
  # renovate: datasource=github-release-attachments depName=imputnet/helium-linux version=0.17.2.1
  url: github:imputnet/helium-linux/releases/download/0.17.2.1/helium-0.17.2.1-x86_64_linux.tar.xz
  ref: 2a639df54e3d05f413cfbb4622a4d1a68584b31da5a7aaf58ee3cd83c7c3e299

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

runtime-depends:
- gnome.bst:sdk/gtk+-3.bst
- gnome.bst:sdk/libsecret.bst
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst
- gnome.bst:freedesktop-sdk.bst:vm/mesa-default.bst
- gnome.bst:freedesktop-sdk.bst:components/alsa-lib.bst
- gnome.bst:freedesktop-sdk.bst:components/ca-certificates.bst
- gnome.bst:freedesktop-sdk.bst:components/desktop-file-utils.bst
- gnome.bst:freedesktop-sdk.bst:components/nss.bst
- gnome.bst:freedesktop-sdk.bst:components/xorg-lib-xrandr.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  # /opt belongs to writable state on this OS. Keep the bundle under /usr.
  - mkdir -p "%{install-root}/usr/lib/helium" "%{install-root}/usr/bin"
  - cp -a . "%{install-root}/usr/lib/helium/"
  - ln -s ../lib/helium/helium-wrapper "%{install-root}/usr/bin/helium"
  - install -Dm644 helium.desktop "%{install-root}/usr/share/applications/helium.desktop"
  - install -Dm644 product_logo_256.png "%{install-root}/usr/share/icons/hicolor/256x256/apps/helium.png"
