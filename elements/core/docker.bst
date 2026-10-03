kind: manual
description: Docker Engine, CLI, Compose and Buildx from pinned upstream binaries

sources:
- kind: tar
  # renovate: datasource=github-tags depName=moby/moby extractVersion=^docker-v(?<version>[0-9.]+)$ version=29.8.2
  url: docker:docker-29.8.2.tgz
  ref: 995d1ef289677f74fd58d8d2c35727b6a4ee389c69db8638a3e42d0487aa5b0f
- kind: remote
  # renovate: datasource=github-release-attachments depName=docker/compose version=v5.6.0
  url: github:docker/compose/releases/download/v5.6.0/docker-compose-linux-x86_64
  ref: 40343e21ca777173e69cff5dbafeb37c6f81f3b0d57d9e597f036e95eb63e76a
  filename: docker-compose
- kind: remote
  # renovate: datasource=github-release-attachments depName=docker/buildx version=v0.37.2
  url: github:docker/buildx/releases/download/v0.37.2/buildx-v0.37.2.linux-amd64
  ref: 982ca20490b45ed1ec8d99795974d3d874a358f75938c9c237305010e6b7e548
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
