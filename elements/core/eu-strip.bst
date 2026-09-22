kind: manual
description: Keep elfutils tools available to Flatpak Builder

depends:
- gnome.bst:freedesktop-sdk.bst:components/elfutils.bst

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  strip-binaries: ''

public:
  bst:
    # Upstream puts elfutils command-line tools in the excluded devel domain.
    overlap-whitelist:
    - /usr/bin/eu-strip
    - /usr/bin/eu-elfcompress

config:
  install-commands:
  - install -Dm755 /usr/bin/eu-strip "%{install-root}/usr/bin/eu-strip"
  - install -Dm755 /usr/bin/eu-elfcompress "%{install-root}/usr/bin/eu-elfcompress"
