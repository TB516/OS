kind: manual
description: Image-managed mise executable, without personal tool configuration

sources:
- kind: tar
  url: github:jdx/mise/releases/download/v2026.9.3/mise-v2026.9.3-linux-x64.tar.gz
  ref: 72de46e58238e3ae860e449adb9a35f4aba53679621c214dec03d68955fa4de8

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

runtime-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- gnome.bst:freedesktop-sdk.bst:components/ca-certificates.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm755 bin/mise "%{install-root}/usr/bin/mise"
  - install -Dm644 LICENSE "%{install-root}/usr/share/licenses/mise/LICENSE"
