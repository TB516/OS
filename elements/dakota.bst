kind: junction

sources:
- kind: git_repo
  url: github:projectbluefin/dakota.git
  # renovate: datasource=git-refs depName=projectbluefin/dakota packageName=https://github.com/projectbluefin/dakota.git
  track: testing
  ref: e59afbe788e441fc1fad560c01fa4dbc267d60d8
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
