kind: manual
description: Docker Engine, CLI, Compose and Buildx from pinned upstream binaries

sources:
- kind: tar
  # renovate: datasource=github-tags depName=moby/moby extractVersion=^docker-v(?<version>[0-9.]+)$ version=29.8.1
  url: docker:docker-29.8.1.tgz
  ref: d8db66739d2e28d4933786d73e918d9be643a67fbd835db1bf740d650a259e70
- kind: remote
  # renovate: datasource=github-release-attachments depName=docker/compose version=v5.5.1
  url: github:docker/compose/releases/download/v5.5.1/docker-compose-linux-x86_64
  ref: db1889184726840f75c4f9c001048430d4f25b3be3cb084d3ddd762bc0aed576
  filename: docker-compose
- kind: remote
  # renovate: datasource=github-release-attachments depName=docker/buildx version=v0.37.1
  url: github:docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-amd64
  ref: 9447199cdb435f25880548343c128a4b6650e8891ee598905d8d29d39a8e359b
  filename: docker-buildx
- kind: local
  path: files/docker
  directory: config

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

runtime-depends:
- gnome.bst:freedesktop-sdk.bst:components/iptables.bst
- gnome.bst:freedesktop-sdk.bst:components/kmod.bst
- gnome.bst:freedesktop-sdk.bst:components/procps.bst
- gnome.bst:freedesktop-sdk.bst:components/ca-certificates.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm755 -t "%{install-root}/usr/bin" docker dockerd
  # Keep Docker's bundled runtime helpers private so Podman's runtime stays
  # independent. Only the Docker service adds this directory to its PATH.
  - |
    install -Dm755 -t "%{install-root}/usr/libexec/docker" \
      containerd containerd-shim-runc-v2 ctr runc docker-init docker-proxy
  - install -Dm755 -t "%{install-root}/usr/libexec/docker/cli-plugins" docker-compose docker-buildx
  - cp -a config/. "%{install-root}/"
