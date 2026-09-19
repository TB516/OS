kind: manual
description: Keep appstreamcli in the runtime image

depends:
- gnome.bst:freedesktop-sdk.bst:components/appstream.bst

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  strip-binaries: ''

public:
  bst:
    # Reclassify this upstream binary as runtime without replacing its build.
    overlap-whitelist:
    - /usr/bin/appstreamcli

config:
  install-commands:
  # Upstream classifies its binaries as devel, which our image excludes.
  - install -Dm755 /usr/bin/appstreamcli "%{install-root}/usr/bin/appstreamcli"
