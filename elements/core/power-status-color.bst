kind: manual
description: Power Status Color with GNOME 51 enabled in its metadata

build-depends:
- dakota.bst:bluefin/shell-extensions/power-status-color.bst
- dakota.bst:core/sandbox-tools.bst
- gnome.bst:freedesktop-sdk.bst:components/jq.bst

runtime-depends:
- gnome.bst:core/gnome-shell.bst

variables:
  strip-binaries: ""
  extension-dir: '%{datadir}/gnome-shell/extensions/power-status-color@local'

config:
  install-commands:
  - |
    install -d "%{install-root}%{extension-dir}"
    cp -a %{extension-dir}/. "%{install-root}%{extension-dir}/"
    # The pinned metadata stops at GNOME 50. Keep version validation enabled
    # globally and extend only this extension's supported versions.
    jq '."shell-version" |= (. + ["51"] | unique)' \
      %{extension-dir}/metadata.json > "%{install-root}%{extension-dir}/metadata.json"
