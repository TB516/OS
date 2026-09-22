kind: manual

build-depends:
- gnome.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - |
    mkdir -p "%{install-root}/usr/lib" "%{install-root}/etc"
    cat > "%{install-root}/usr/lib/os-release" <<'EOF'
    NAME="%{image-name}"
    PRETTY_NAME="%{image-name} %{image-version}"
    ID="%{image-id}"
    VERSION="%{image-version}"
    VERSION_ID="%{image-version}"
    IMAGE_ID="%{image-id}"
    IMAGE_VERSION="%{image-version}"
    EOF
    ln -s ../usr/lib/os-release "%{install-root}/etc/os-release"
