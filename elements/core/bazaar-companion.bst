kind: manual
description: Bazaar Companion adapted for GNOME 51

build-depends:
- dakota.bst:bluefin/shell-extensions/bazaar-companion.bst
- dakota.bst:core/sandbox-tools.bst
- gnome.bst:freedesktop-sdk.bst:components/jq.bst

runtime-depends:
- gnome.bst:core/gnome-shell.bst
- gnome.bst:core-deps/flatpak.bst

variables:
  strip-binaries: ""
  extension-dir: '%{datadir}/gnome-shell/extensions/bazaar-integration@kolunmi.github.io'

config:
  install-commands:
  - |
    install -d "%{install-root}%{extension-dir}"
    cp -a %{extension-dir}/. "%{install-root}%{extension-dir}/"
    # GNOME 51 removed St.BoxLayout.vertical in favor of orientation.
    sed -i \
      -e 's/vertical: true/orientation: Clutter.Orientation.VERTICAL/g' \
      -e 's/vertical: false/orientation: Clutter.Orientation.HORIZONTAL/g' \
      "%{install-root}%{extension-dir}/removeDialog.js"
    # The pinned extension lists 49 and 50; GNOME 51 retains its AppMenu APIs.
    # Scope the compatibility adjustment to this extension.
    jq '."shell-version" |= (. + ["51"] | unique)' \
      %{extension-dir}/metadata.json > "%{install-root}%{extension-dir}/metadata.json"
