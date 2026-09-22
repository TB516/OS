kind: manual
description: Keep GNU strip available to Flatpak Builder

depends:
- gnome.bst:freedesktop-sdk.bst:components/binutils.bst

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  strip-binaries: ''

public:
  bst:
    # Upstream classifies all binutils files as devel.
    overlap-whitelist:
    - /usr/bin/strip
    - '%{libdir}/libbfd-*.so'
    - '%{libdir}/libsframe.so.[0-9]*'

config:
  install-commands:
  - install -Dm755 /usr/bin/strip "%{install-root}/usr/bin/strip"
  - |
    install -d "%{install-root}%{libdir}"
    cp -a %{libdir}/libbfd-*.so %{libdir}/libsframe.so.[0-9]* "%{install-root}%{libdir}/"
