# Secure Boot

Personal OS uses Dakota's signed boot chain. See [validation notes](validation.md) for what has been tested.

## What the image supplies

`core/dakota-boot.bst` imports the signed kernel, matching modules, signed systemd-boot/fwupd EFI loaders, Fedora's Microsoft-signed shim/MokManager and Dakota's public certificate from one pinned production OCI image. It preserves signatures and builds our own initramfs. The import requires the signed payload and relevant kernel capabilities; it does not fall back to unsigned files.

Dakota's merged source recipes provide the enrollment helper, its boot-time EFI maintenance service, explicit `lockdown=integrity`, and `kernel.kexec_load_disabled=1`. A local patch installs the helper on `PATH` as `secure-boot`, updates the service to call it, and labels new firmware entries `Personal OS`. freedesktop-sdk-extra supplies `mokutil`. Local boot arguments request `intel_iommu=on` and `iommu.passthrough=0`; AMD IOMMU is enabled by the kernel by default. The imported kernel must include BPF LSM and lockdown in its default LSM list.

Signing stays upstream. Keep Dakota's `secure_boot_signing` build option false here: enabling it would request upstream signing elements and private-key inputs, which this project does not need.

## Enrollment

The supported initial path is installation or upgrade with firmware Secure Boot disabled, followed by enrollment using Dakota's tool. Installing directly with Secure Boot already enforcing remains unvalidated. Bootc's installer uses the imported signed systemd-boot automatically; enrollment adds the shim entry needed for firmware to trust it.

Inspect the installed system with:

```sh
sudo secure-boot status
sudo secure-boot check
```

When ready to change the EFI partition and firmware boot entries:

```sh
sudo secure-boot enroll
```

The upstream tool asks for confirmation, installs the shim chain under `EFI/dakota` and the fallback path, and queues the Dakota certificate. Reboot and complete MokManager enrollment using password `dakota`, then enable Secure Boot in firmware. Its service refreshes the EFI copies from the image on subsequent boots after enrollment. Preserve the Dakota paths: they identify the signing/enrollment implementation, independently of Personal OS's display name.

Existing firmware entries retain their labels. The helper identifies its entry by the EFI loader path, so renaming an existing label to `Personal OS` does not affect enrollment or maintenance.

For TPM-unlocked encrypted disks, the tool also handles the transition between Secure Boot states. Know the disk passphrase before enrolling. This path needs its own validation before use on an encrypted host.

Lockdown prevents hibernation and loading modules signed by untrusted keys. Disabling kexec is intentional. TPM 2.0 and IOMMU must also be enabled in firmware; image configuration cannot enable those firmware settings.

## EAC requirements and review gates

[Epic's Linux v2 requirements](https://onlineservices.epicgames.com/news/introducing-easy-anti-cheat-linux-v2) include recognized signing keys, signed modules, TPM 2.0, enforced Secure Boot, measured boot, IOMMU translation, integrity lockdown, disabled kexec and an active BPF LSM. All enrolled MOKs must be recognized when booting through shim. Dakota's certificate is distinct from Universal Blue's; its EAC acceptance remains unconfirmed.

Dakota's `check` command is an upstream diagnostic, not Epic's acceptance test. Read its reported failures/waits; its exit code alone does not establish readiness.

The image does not include an NVIDIA-specific out-of-tree driver stack. Any future out-of-tree modules need a signing key recognized by EAC as well.
