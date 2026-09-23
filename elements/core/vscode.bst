kind: manual
description: Microsoft Visual Studio Code with native desktop integration

sources:
- kind: tar
  # renovate: datasource=custom.vscode depName=microsoft/vscode version=1.139.0
  url: vscode:1.139.0/linux-x64/stable
  ref: ef18461d14d658255917ea978cdccb20576f797af8d9f6062e6ac5afa9f5ec51
  directory: vscode
- kind: local
  path: files/vscode
  directory: integration

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

runtime-depends:
- gnome.bst:sdk/gtk+-3.bst
- gnome.bst:sdk/libsecret.bst
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst
- gnome.bst:freedesktop-sdk.bst:vm/mesa-default.bst
- gnome.bst:freedesktop-sdk.bst:components/alsa-lib.bst
- gnome.bst:freedesktop-sdk.bst:components/ca-certificates.bst
- gnome.bst:freedesktop-sdk.bst:components/curl.bst
- gnome.bst:freedesktop-sdk.bst:components/desktop-file-utils.bst
- gnome.bst:freedesktop-sdk.bst:components/nss.bst
- gnome.bst:freedesktop-sdk.bst:components/shared-mime-info.bst
- gnome.bst:freedesktop-sdk.bst:components/xorg-lib-xkbfile.bst
- gnome.bst:freedesktop-sdk.bst:components/xorg-lib-xrandr.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - mkdir -p "%{install-root}/usr/share/code" "%{install-root}/usr/bin"
  - cp -a vscode/. "%{install-root}/usr/share/code/"
  - cp -a integration/. "%{install-root}/"
  - install -Dm644 vscode/resources/app/resources/linux/code.png "%{install-root}/usr/share/pixmaps/vscode.png"
  - ln -s ../share/code/bin/code "%{install-root}/usr/bin/code"
