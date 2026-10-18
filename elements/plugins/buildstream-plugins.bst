kind: junction

sources:
- kind: git
  url: github:apache/buildstream-plugins.git
  # renovate: datasource=github-tags depName=apache/buildstream-plugins
  track: 2.8.0
  ref: 2681232038711d5c3d4ef1ecc962321c33ec72c1
# OCI/zstd compatibility and standard digest syntax for OCI image imports.
- kind: patch_queue
  path: patches/buildstream-plugins
