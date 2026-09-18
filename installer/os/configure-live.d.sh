#!/usr/bin/bash
set -eu

# Dakota provides the installer launcher; only its display name is local.
sed -i 's/^Name=Dakota Installer$/Name=Install Personal OS/; s/^Icon=dakota$/Icon=drive-harddisk/' \
    /usr/share/applications/org.bootcinstaller.Installer.desktop
