kind: stack
description: GNOME session, settings, accessibility and desktop resources

# GNOME 51's shell stack also includes Tour and Sushi. Sushi pulls in the
# native Papers GUI, so keep the session selection explicit here.
depends:
- dakota.bst:gnome-build-meta.bst:core/gdm.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-backgrounds.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-bluetooth.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-color-manager.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-control-center.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-desktop.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-initial-setup.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-menus.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-remote-desktop.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-session.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-settings-daemon.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-shell.bst
- dakota.bst:gnome-build-meta.bst:core/gnome-user-share.bst
- dakota.bst:gnome-build-meta.bst:core/gvfs-daemon.bst
- dakota.bst:gnome-build-meta.bst:core/mutter.bst
- dakota.bst:gnome-build-meta.bst:core/orca.bst
- dakota.bst:gnome-build-meta.bst:core/rygel.bst
- dakota.bst:gnome-build-meta.bst:core/tecla.bst
- dakota.bst:gnome-build-meta.bst:sdk/adwaita-icon-theme.bst
- dakota.bst:gnome-build-meta.bst:sdk/glib-networking.bst
- dakota.bst:gnome-build-meta.bst:sdk/gsettings-desktop-schemas.bst

# Reuse Dakota's individually pinned extensions without its aggregate defaults.
- dakota.bst:bluefin/shell-extensions/dash-to-dock.bst
- dakota.bst:bluefin/shell-extensions/app-indicators.bst
- dakota.bst:bluefin/shell-extensions/custom-command-menu.bst
- core/bazaar-companion.bst
- core/gradia-capture.bst
