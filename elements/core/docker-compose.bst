kind: manual
description: Docker Compose from its pinned official binary image, used by podman compose

sources:
- kind: docker
  registry-url: 'docker:'
  image: docker/compose-bin
  architecture: amd64
  os: linux
  # renovate: datasource=docker depName=docker.io/docker/compose-bin
  track: v5.8.0
  ref: sha256:2b1984a73f63ed92cf4ca659c592ae666c14877a0b9fbdfca586a3ab5488d226
  directory: image

build-depends:
- dakota.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  # podman compose checks this plugin path itself, so Compose stays off PATH.
  - install -Dm755 -t "%{install-root}/usr/libexec/docker/cli-plugins" image/docker-compose
