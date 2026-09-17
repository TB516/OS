kind: script
description: Single-layer bootc OCI image for VM bring-up

build-depends:
- gnome.bst:freedesktop-sdk.bst:components/fakecap.bst
- gnome.bst:freedesktop-sdk.bst:components/oci-builder.bst
- gnome.bst:freedesktop-sdk.bst:components/glib.bst
- gnome.bst:core-deps/dconf.bst
- gnome.bst:freedesktop-sdk.bst:vm/prepare-image.bst
- oci/init-scripts.bst
- filename: oci/filesystem.bst
  config:
    location: /layer

environment:
  LD_PRELOAD: /usr/libexec/fakecap/fakecap.so
  FAKECAP_DB: /fakecap

variables:
  sysroot-seed: 7bb43b67-8ccb-4fb3-bff0-b3a3e13dc180

config:
  commands:
  - mkdir /fakecap
  - |
    prepare-image.sh --sysroot /layer --initscripts /initial_scripts \
      --seed "%{sysroot-seed}" --noroot --noboot >/dev/null
  - systemd-sysusers --root /layer
  # BuildStream's sandbox mounts do not become artifact directories. The
  # immutable root needs these mount points before systemd can switch to it.
  - mkdir -p /layer/dev /layer/proc /layer/sys
  # Compose artifacts normalize directory modes; restore these before OCI
  # packaging, where they become part of the deployed filesystem.
  - chmod 0700 /layer/var/roothome
  - chmod 1777 /layer/var/tmp
  - glib-compile-schemas /layer/usr/share/glib-2.0/schemas
  # bootc accepts /etc in the image; /usr/etc is created during deployment.
  - |
    if [ -d /layer/usr/etc ]; then
      mkdir -p /layer/etc
      cp -a /layer/usr/etc/. /layer/etc/
      rm -rf /layer/usr/etc
    fi
  - |
    if [ -d /layer/etc/dconf/db ]; then
      dconf update /layer/etc/dconf/db
    fi
  - ldconfig -r /layer -f /layer/etc/ld.so.conf
  - |
    cd "%{install-root}"
    # The pinned oci-builder hashes/copies its tar before closing it. Finish
    # the tar first so composefs can read the last entry during installation.
    # Remove this wrapper once upstream closes the tar before hashing it.
    python3 -c '
    from oci_builder import cmd, image_builder

    create_layer = image_builder.create_layer

    def create_finished_layer(output, upper, lowers):
        create_layer(output, upper, lowers)
        output.close()

    image_builder.create_layer = create_finished_layer
    cmd.main()
    ' <<EOF
    mode: oci
    gzip: disabled
    images:
    - os: linux
      architecture: "%{go-arch}"
      layer: /layer
      config:
        Labels:
          'org.opencontainers.image.title': '%{image-name}'
          'org.opencontainers.image.version': '%{image-version}'
          'containers.bootc': '1'
      index-annotations:
        'org.opencontainers.image.ref.name': '%{image-ref}'
    EOF
