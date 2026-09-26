kind: stack

depends:
- core/desktop.bst
- core/config.bst
- core/os-release.bst
- gnome.bst:gnomeos/initramfs/signed-modules.bst
- gnome.bst:oci/initramfs/image.bst
- gnome.bst:gnomeos-deps/bootc.bst
- gnome.bst:oci/integration/bootc-config.bst
- gnome.bst:oci/integration/lvm2-enable-activation.bst
- gnome.bst:freedesktop-sdk.bst:components/btrfs-progs.bst
- gnome.bst:freedesktop-sdk.bst:vm/config/useradd-default.bst
- gnome.bst:freedesktop-sdk.bst:vm/config/sudo.bst

public:
  bst:
    integration-commands:
    # bootc owns deployment state; these directories must start empty.
    - rm -rf /boot /run /ostree /home /root /opt /mnt /srv /usr/local /var
    - mkdir -p /boot /run /var/home /var/opt /var/mnt /var/srv /var/usrlocal
    - install -d -m0700 /var/roothome
    - install -d -m1777 /var/tmp
    # bootc 1.16.6 container lint still requires this symlink for composefs images.
    - ln -sT sysroot/ostree /ostree
    - ln -sT var/home /home
    - ln -sT var/roothome /root
    - ln -sT var/opt /opt
    - ln -sT var/mnt /mnt
    - ln -sT var/srv /srv
    - ln -sT ../var/usrlocal /usr/local
    - truncate -s 0 /etc/machine-id
