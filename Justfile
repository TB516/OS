set positional-arguments

default:
    @just --list

# Resolve the image graph and check the BuildStream runner's shell syntax.
validate:
    bash -n scripts/bst scripts/vm
    ./scripts/bst show --deps all --format '%{name}' oci/image.bst > /dev/null

# Inspect the full pinned graph without building the OS.
graph:
    ./scripts/bst show --deps all oci/image.bst

# List only the components staged into the image.
contents:
    ./scripts/bst show --deps run --format '%{name}' oci/stack.bst

# Compile the full OS image. The first build can be large.
build:
    ./scripts/bst build oci/image.bst

# Export a built image to a new OCI directory. Existing output is not replaced.
export:
    ./scripts/bst artifact checkout --directory build/image oci/image.bst

# Boot the installed test disk through UEFI in a QEMU window.
vm:
    ./scripts/vm

# Copy an exported image to GHCR. Set include/image.yml to this ref first.
publish ref:
    skopeo copy --all oci:build/image "docker://$1"

# Pass arbitrary arguments to the pinned BuildStream container.
bst *args:
    ./scripts/bst "$@"
