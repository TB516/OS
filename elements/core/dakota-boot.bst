kind: manual
description: Signed kernel, modules and EFI boot files from Dakota's regular image

sources:
- kind: docker
  url: ghcr:projectbluefin/dakota
  # renovate: datasource=docker depName=ghcr.io/projectbluefin/dakota
  track: testing
  ref: sha256:4697e6606ae5c23b58e24c2001654af60a614d977d23d37cc9358baa17d103a7
  architecture: amd64
  os: linux

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst
- gnome.bst:freedesktop-sdk.bst:components/findutils.bst
- gnome.bst:freedesktop-sdk.bst:components/grep.bst
- gnome.bst:freedesktop-sdk.bst:components/openssl.bst
- gnome.bst:freedesktop-sdk.bst:components/sbsigntools-maybe.bst
- gnome.bst:freedesktop-sdk.bst:components/kmod.bst

variables:
  # Any post-signing stripping would invalidate the imported signatures.
  strip-binaries: ''

config:
  install-commands:
  - |
    set -- usr/lib/modules/*
    test "$#" -eq 1
    test -f "$1/vmlinuz"
    test -f "$1/modules.dep"
    # Reject images without the signed boot payload instead of silently
    # producing an unsigned OS after a pin update.
    cert=usr/lib/dakota/secure-boot/dakota-secure-boot.der
    openssl x509 -inform DER -in "$cert" -out .dakota-secure-boot.pem
    sbverify --cert .dakota-secure-boot.pem "$1/vmlinuz"
    for binary in \
      usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed \
      usr/libexec/fwupd/efi/fwupdx64.efi.signed; do
      sbverify --cert .dakota-secure-boot.pem "$binary"
      install -Dm644 "$binary" "%{install-root}/$binary"
    done
    for binary in shimx64.efi mmx64.efi; do
      path="usr/lib/dakota/secure-boot/$binary"
      test -s "$path"
      install -Dm644 "$path" "%{install-root}/$path"
    done
    install -Dm644 "$cert" "%{install-root}/$cert"

    # These capabilities and the default LSM list are owned by the kernel
    # image; fail here if a later upstream kernel drops a requirement.
    for option in MODULE_SIG SECURITY_LOCKDOWN_LSM BPF_SYSCALL BPF_LSM TCG_TPM INTEL_IOMMU AMD_IOMMU; do
      grep -qx "CONFIG_$option=y" "$1/config"
    done
    grep '^CONFIG_LSM=' "$1/config" | grep -q 'bpf'
    grep '^CONFIG_LSM=' "$1/config" | grep -q 'lockdown'
    find "$1" -type f -name '*.ko*' -exec sh -ec '
      for module do
        test -n "$(modinfo -F signer "$module")"
      done
    ' sh {} +

    install -d "%{install-root}/usr/lib/modules"
    cp -a "$1" "%{install-root}/usr/lib/modules/"
    # Build our own initramfs from these modules and this OS's userspace.
    rm -f "%{install-root}/$1/initramfs.img"
