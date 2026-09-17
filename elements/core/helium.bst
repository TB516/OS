kind: manual
description: Native Helium browser from its pinned official Linux release

sources:
- kind: tar
  url: github:imputnet/helium-linux/releases/download/0.17.1.1/helium-0.17.1.1-x86_64_linux.tar.xz
  ref: 686d3bd83330669d7da8036648c5a251562b3963b624da19d5e9f568ddd65930

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
