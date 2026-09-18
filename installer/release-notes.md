Experimental x86_64 UEFI installer. Installation and upgrades must still be tested in a VM before treating this as a verified hardware installer. Secure Boot must be disabled.

Download every `personal-os.iso.part-*` file and both checksum files into an empty directory. GitHub limits individual downloads to less than 2 GiB, so join the parts before flashing:

```sh
sha256sum -c PARTS-SHA256SUMS
cat personal-os.iso.part-* > personal-os.iso
sha256sum -c SHA256SUMS
```

Both checksum checks must pass. Restore `personal-os.iso` onto a USB drive using GNOME Disks' **Restore Disk Image** option. This erases the selected USB drive. Boot it in UEFI mode and open **Install Personal OS**. Installation erases the disk selected in the installer.

The OS payload is included for offline installation. After installation, create your account through GNOME Initial Setup. With an internet connection, the installed system stages updates from `ghcr.io/tb516/os:latest` for your next reboot. `image-digest.txt` identifies the source image used for this ISO.
