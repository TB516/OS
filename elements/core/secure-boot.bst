kind: stack
description: Dakota enrollment and EFI maintenance with the imported signing key

depends:
- core/dakota-boot.bst
- dakota.bst:bluefin/secure-boot-tools.bst
- dakota.bst:bluefin/lockdown-kargs.bst
- dakota.bst:bluefin/kexec-disable.bst
- gnome.bst:gnomeos-deps/mokutil.bst
# Used by Dakota's enrollment, TPM reseal and readiness commands.
- gnome.bst:freedesktop-sdk.bst:components/openssl.bst
- gnome.bst:freedesktop-sdk.bst:components/cryptsetup.bst
- gnome.bst:freedesktop-sdk.bst:components/jq.bst
