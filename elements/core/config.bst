kind: import

# Stage after containers-common so our container policy replaces its own.
runtime-depends:
- dakota.bst:freedesktop-sdk.bst:components/containers-common.bst

sources:
- kind: local
  path: files/system

config:
  source: /
  target: /

public:
  bst:
    # Replace containers-common's policy to require signed OS updates.
    overlap-whitelist:
    - /etc/containers/policy.json
