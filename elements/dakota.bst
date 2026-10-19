kind: junction

sources:
- kind: git_repo
  url: github:projectbluefin/dakota.git
  # renovate: datasource=git-refs depName=projectbluefin/dakota packageName=https://github.com/projectbluefin/dakota.git
  track: testing
  ref: 5fe625712433e902124eedf5ec2c82880dbcaddc

config:
  options:
    arch: '%{arch}'
    x86_64_v3: false
    gaming: false
  overrides:
    # Share GNOME's dependency graph for the borrowed Dakota recipes.
    gnome-build-meta.bst: gnome.bst
    freedesktop-sdk.bst: gnome.bst:freedesktop-sdk.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
