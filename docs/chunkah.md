# Image layers

The build workflow runs Chunkah after exporting the BuildStream image, then
validates and publishes the result. Chunkah splits the filesystem into OCI
layers so registry pushes and bootc upgrades can reuse unchanged layers.
It adds packaging work and disk usage in CI; it does not speed up compilation.

`include/chunkah-image.txt` pins the tool. Renovate updates its tag and digest
using the same rule as the BuildStream builder image.

The workflow passes the original image configuration to Chunkah to preserve
labels, including the bootc label. It writes an OCI directory directly and uses
a fixed timestamp to keep layer timestamps reproducible. The 128-layer limit
follows upstream's recommendation for large bootc images.

Our image has no RPM package database for package grouping. Chunkah's built-in
large-file detection supplies components, while smaller unclaimed files remain
grouped together. We do not add Dakota's custom BuildStream component metadata.
Actual transfer savings need measuring across two builds with a small update.

Runtime validation still needs a chunked image boot and upgrade in a VM, plus
CI disk usage and packaging time measurements.

References: [Chunkah usage](https://github.com/coreos/chunkah/blob/v0.6.0/README.md)
and [fallback component detection](https://github.com/coreos/chunkah/blob/v0.6.0/src/components/bigfiles.rs).
