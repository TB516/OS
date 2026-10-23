kind: junction

sources:
- kind: git_repo
  url: github:projectbluefin/dakota.git
  # renovate: datasource=custom.dakota-build depName=projectbluefin/dakota
  track: testing
  ref: f1e147b5ce8b9ab60bc63a1aa91150a2781779a1
- kind: patch
  path: patches/dakota/personal-os-secure-boot.patch
- kind: patch
  path: patches/dakota/firewalld-iptables.patch

config:
  options:
    arch: '%{arch}'
    x86_64_v3: false
    gaming: false
    # Sign only upstream; consume the published signatures here.
    secure_boot_signing: false
  overrides:
    gnome-build-meta.bst:core/meta-gnome-core-apps.bst: core/apps.bst
    gnome-build-meta.bst:oci/integration/os-release.bst: core/os-release.bst
    # Share the published kernel/modules between the OS and its initramfs.
    gnome-build-meta.bst:gnomeos/initramfs/signed-modules.bst: core/dakota-boot.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
