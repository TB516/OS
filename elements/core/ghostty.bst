kind: filter
description: Ghostty with its bundled terminal description

build-depends:
- dakota.bst:bluefin/ghostty.bst

# A filter does not inherit the parent artifact's runtime dependencies.
runtime-depends:
- gnome.bst:sdk/gtk.bst
- gnome.bst:sdk/libadwaita.bst
- dakota.bst:bluefin/gtk4-layer-shell.bst
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  include-orphans: true
  pass-integration: true

public:
  bst:
    # ncurses also ships this entry. Prefer the one bundled with Ghostty.
    overlap-whitelist:
    - /usr/share/terminfo/g/ghostty
