kind: junction

sources:
- kind: git_repo
  url: gnome:gnome-build-meta.git
  # renovate: datasource=git-refs depName=GNOME/gnome-build-meta packageName=https://gitlab.gnome.org/GNOME/gnome-build-meta.git
  track: gnome-51
  ref: be7cb317ee21d45197ba5139c77317f171e20c38
- kind: patch
  path: patches/gnome/firewalld-iptables.patch
# Dakota redirects its GNOME junction here, so carry its Shell fix here too.
- kind: patch
  path: patches/gnome/gnome-shell-portable-unzip-flags.patch

config:
  options:
    arch: '%{arch}'
    channel: stable
    x86_64_v3: false
    recc: passthrough
  overrides:
    # Share Dakota's cached regular kernel across the image and initramfs.
    freedesktop-sdk.bst:components/linux.bst: dakota.bst:core/linux-fdsdk.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
    core/meta-gnome-core-apps.bst: core/apps.bst
    oci/integration/os-release.bst: core/os-release.bst
    # Upstream signing needs private build keys; use Dakota's unsigned copier.
    gnomeos/initramfs/signed-modules.bst: dakota.bst:bluefin/unsigned-modules.bst
