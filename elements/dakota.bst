kind: junction

sources:
- kind: git_repo
  url: github:projectbluefin/dakota.git
  # renovate: datasource=custom.dakota-build depName=projectbluefin/dakota
  track: testing
  ref: 7bb35dec73790f04940e66f10f7c528030fe3708
- kind: patch
  path: patches/dakota/personal-os-secure-boot.patch
- kind: patch
  path: patches/dakota/firewalld-iptables.patch
- kind: patch
  path: patches/dakota/initramfs-firmware.patch

config:
  options:
    arch: '%{arch}'
    x86_64_v3: true
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
