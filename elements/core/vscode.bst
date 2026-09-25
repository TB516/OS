kind: manual
description: Microsoft Visual Studio Code with native desktop integration

sources:
- kind: tar
  # renovate: datasource=custom.vscode depName=microsoft/vscode version=1.139.1
  url: vscode:1.139.1/linux-x64/stable
  ref: 0c9cbcea070e9a0fc62de5c78fee01a80f8e32f78ada664d9731f6c517503b7e
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
