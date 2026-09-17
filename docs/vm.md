# Local VM testing

The installed test disk lives at `build/vm/os.raw`. Open it with:

```sh
just vm
```

This needs an existing QEMU installation with KVM access and its GTK display backend. `VM_DISPLAY=none just vm` runs without a window. The runner uses four virtual CPUs, 8 GiB RAM, a virtio display and user-mode networking. It boots the disk's own kernel through UEFI and systemd-boot.

Log in as `tester` with no password. Passwordless login is configured on this local test disk. Shut down through GNOME before starting another QEMU process against the same disk.

The VM directory is ignored by Git and is not included in a fresh checkout. `just vm` opens an already installed disk; it does not build or install the OS. Re-exporting `build/image` also does not update this disk.

## Installation method used for bring-up

Installation used a disposable helper VM so bootc could partition a virtual disk without host root access. All disks were ordinary files under `build/vm`.

1. Extract the OCI image's uncompressed layer into a temporary root using `podman unshare tar`, preserving ownership and extended attributes. Obtain the layer filename from the OCI index and manifest.
2. Copy its matching kernel and `usr/share/ovmf/OVMF_CODE.fd` and `OVMF_VARS.fd` into the VM directory. Preserve a writable copy of the firmware variables for subsequent boots.
3. Add a temporary installer service to the extracted root, then populate a 24 GiB ext4 file with `podman unshare mkfs.ext4 -b 4096 -d ROOTFS installer.raw`.
4. Create a separate 48 GiB sparse `os.raw`. Boot the helper's matching kernel with the ext4 image as `/dev/vda`, the target as `/dev/vdb`, and `build/image` shared read-only using QEMU's 9p transport.
5. Mount the share at `/run/image` and run the following **inside that helper VM**, where `/dev/vdb` is the disposable target disk:

```sh
bootc install to-disk /dev/vdb --wipe \
  --composefs-backend --filesystem btrfs --bootloader systemd \
  --generic-image --source-imgref oci:/run/image \
  --target-imgref localhost/personal-os:dev --skip-fetch-check \
  --karg console=ttyS0,115200 --karg systemd.debug_shell=ttyS1
```

After installation, shut down the helper and boot `os.raw` alone with `just vm`. The target disk has no dependency on the helper root or the OCI share. These preparation steps are not yet an automated installer.

The local origin is a placeholder. Testing upgrades requires publishing a reachable image and selecting it as the bootc origin. `--skip-fetch-check` was used for this unpublished local image.

## Test access and evidence

The test disk has a root debug shell on its second serial port, exposed through `build/vm/debug.sock`. This kernel argument is supplied at VM installation time. QMP is available at `build/vm/qmp.sock`, and serial output goes to `build/vm/desktop-serial.log`.

The runner forwards host `127.0.0.1:2222` to guest port 22. During testing, a temporary SSH daemon, its service account and an authorized key were configured inside the VM. That transient daemon does not start after a reboot. The image does not currently provide an enabled SSH server.

Test credentials, screenshots, install logs and command results remain under the ignored `build/vm` directory. The VM presents a virtual sound card, but its QEMU audio backend discards output. Device detection was checked; audible playback and hardware acceleration were not.
