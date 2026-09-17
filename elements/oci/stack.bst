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
    - rm -rf /boot /run /home /root /opt /mnt /srv /var
    - mkdir -p /boot /run /sysroot/ostree /var/home /var/opt /var/mnt /var/srv /var/usrlocal
    - install -d -m0700 /var/roothome
    - install -d -m1777 /var/tmp
    - ln -s sysroot/ostree /ostree
    - ln -s var/home /home
    - ln -s var/roothome /root
    - ln -s var/opt /opt
    - ln -s var/mnt /mnt
    - ln -s var/srv /srv
    - rm -rf /usr/local
    - ln -s ../var/usrlocal /usr/local
    - truncate -s 0 /etc/machine-id
