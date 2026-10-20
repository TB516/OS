kind: junction

sources:
- kind: git_repo
  url: github:projectbluefin/dakota.git
  # renovate: datasource=git-refs depName=projectbluefin/dakota packageName=https://github.com/projectbluefin/dakota.git
  track: testing
  ref: 95ff6c060392d2c3b05c82d057b1e9e5adf59eb8
- kind: patch
  path: patches/dakota/personal-os-secure-boot.patch

config:
  options:
    arch: '%{arch}'
    x86_64_v3: false
    gaming: false
    # Sign only upstream; consume the published signatures here.
    secure_boot_signing: false
  overrides:
    # Share GNOME's dependency graph for the borrowed Dakota recipes.
    gnome-build-meta.bst: gnome.bst
    freedesktop-sdk.bst: gnome.bst:freedesktop-sdk.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
