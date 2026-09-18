kind: junction

sources:
- kind: git_repo
  url: github:projectbluefin/dakota.git
  # renovate: datasource=git-refs depName=projectbluefin/dakota packageName=https://github.com/projectbluefin/dakota.git
  track: testing
  ref: 53191a4787fee1fc44b0447cfd90290b042ae3b5

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
