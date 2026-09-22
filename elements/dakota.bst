kind: junction

sources:
- kind: git_repo
  url: github:projectbluefin/dakota.git
  # renovate: datasource=git-refs depName=projectbluefin/dakota packageName=https://github.com/projectbluefin/dakota.git
  track: testing
  ref: 4a3b9251cd6112215f79875d312d0e35a2d6d2f5

config:
  options:
    arch: '%{arch}'
    x86_64_v3: false
    gaming: false
  overrides:
    # Share GNOME's dependency graph; gnome.bst selects Dakota's regular kernel.
    gnome-build-meta.bst: gnome.bst
    freedesktop-sdk.bst: gnome.bst:freedesktop-sdk.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
