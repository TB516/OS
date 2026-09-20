kind: stack
description: GNOME session, settings, accessibility and desktop resources

# GNOME 51's shell stack also includes Tour and Sushi. Sushi pulls in the
# native Papers GUI, so keep the session selection explicit here.
depends:
- gnome.bst:core/gdm.bst
- gnome.bst:core/gnome-backgrounds.bst
- gnome.bst:core/gnome-bluetooth.bst
- gnome.bst:core/gnome-color-manager.bst
- gnome.bst:core/gnome-control-center.bst
- gnome.bst:core/gnome-desktop.bst
- gnome.bst:core/gnome-initial-setup.bst
- gnome.bst:core/gnome-menus.bst
- gnome.bst:core/gnome-remote-desktop.bst
- gnome.bst:core/gnome-session.bst
- gnome.bst:core/gnome-settings-daemon.bst
- gnome.bst:core/gnome-shell.bst
- gnome.bst:core/gnome-user-share.bst
- gnome.bst:core/gvfs-daemon.bst
- gnome.bst:core/mutter.bst
- gnome.bst:core/orca.bst
- gnome.bst:core/rygel.bst
- gnome.bst:core/tecla.bst
- gnome.bst:sdk/adwaita-icon-theme.bst
- gnome.bst:sdk/glib-networking.bst
- gnome.bst:sdk/gsettings-desktop-schemas.bst

# Reuse Dakota's individually pinned extensions without its aggregate defaults.
- dakota.bst:bluefin/shell-extensions/dash-to-dock.bst
- dakota.bst:bluefin/shell-extensions/app-indicators.bst
- dakota.bst:bluefin/shell-extensions/custom-command-menu.bst
