kind: manual
description: Docker Engine, CLI, Compose and Buildx from the pinned official Docker image

sources:
- kind: docker
  registry-url: 'docker:'
  image: library/docker
  architecture: amd64
  os: linux
  # renovate: datasource=docker depName=docker.io/library/docker
  track: 29.9.2-dind
  ref: sha256:eb37f58646a901dc7727cf448cae36daaefaba79de33b5058dab79aa4c04aefb
  directory: image
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
  - install -Dm755 -t "%{install-root}/usr/bin" image/usr/local/bin/docker image/usr/local/bin/dockerd
  # Keep Docker's bundled runtime helpers private so Podman's runtime stays
  # independent. Only the Docker service adds this directory to its PATH.
  # dockerd uses its embedded containerd, as in the official image.
  - |
    install -Dm755 -t "%{install-root}/usr/libexec/docker" \
      image/usr/local/bin/containerd-shim-runc-v2 image/usr/local/bin/ctr \
      image/usr/local/bin/runc image/usr/local/bin/docker-init image/usr/local/bin/docker-proxy
  - |
    install -Dm755 -t "%{install-root}/usr/libexec/docker/cli-plugins" \
      image/usr/local/libexec/docker/cli-plugins/docker-compose \
      image/usr/local/libexec/docker/cli-plugins/docker-buildx
  - cp -a config/. "%{install-root}/"
