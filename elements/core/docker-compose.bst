kind: manual
description: Docker Compose from its pinned official binary image, used by podman compose

sources:
- kind: docker
  registry-url: 'docker:'
  image: docker/compose-bin
  architecture: amd64
  os: linux
  # renovate: datasource=docker depName=docker.io/docker/compose-bin
  track: v5.7.0
  ref: sha256:c34e6c54a19b3ac03edc915dd6115880c491a36fce89e0679962e5db6f36e81a
  directory: image

build-depends:
- dakota.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  # podman compose checks this plugin path itself, so Compose stays off PATH.
  - install -Dm755 -t "%{install-root}/usr/libexec/docker/cli-plugins" image/docker-compose
