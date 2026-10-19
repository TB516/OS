kind: manual
description: Kernel and matching modules from Dakota's published regular image

sources:
- kind: docker
  url: ghcr:projectbluefin/dakota
  # renovate: datasource=docker depName=ghcr.io/projectbluefin/dakota
  track: testing
  ref: sha256:bd5b60fa1afe62fcfc6ca6607c95af5fa66a622aae0ba5566cdacc099f73fa13
  architecture: amd64
  os: linux

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  # Stripping after signing would invalidate module signatures.
  strip-binaries: ''

config:
  install-commands:
  - |
    set -- usr/lib/modules/*
    test "$#" -eq 1
    test -f "$1/vmlinuz"
    test -f "$1/modules.dep"
    install -d "%{install-root}/usr/lib/modules"
    cp -a "$1" "%{install-root}/usr/lib/modules/"
    # Build our own initramfs from these modules and this OS's userspace.
    rm -f "%{install-root}/$1/initramfs.img"
