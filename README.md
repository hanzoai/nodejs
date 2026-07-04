# hanzoai/nodejs

The **one** canonical Node base image for every Hanzo Node service.

- **Node 24** (LTS "Krypton", pinned `node:24.18.0-alpine`)
- **sqlite3 bundled, two ways** — both proven at build time:
  1. `require('node:sqlite')` — the built-in `DatabaseSync` (Node ≥ 22.5). Zero deps.
  2. Native npm sqlite (`better-sqlite3`, `sqlite3`) compiles against the baked-in
     toolchain (`build-base` + `python3` + `sqlite-dev`) via node-gyp.

## Use

One way. In any Hanzo Node service's Dockerfile:

```dockerfile
FROM ghcr.io/hanzoai/nodejs:v24.18.0
```

Pin the exact semver (`v24.18.0`). The moving major tag `v24` also exists but
consumers must pin the patch for reproducible builds.

## Verify

```sh
docker run --rm ghcr.io/hanzoai/nodejs:v24.18.0 node -e "require('node:sqlite');console.log('ok')"
```

## Release

Tag `vX.Y.Z` where `X.Y.Z` matches the pinned Node version in the `Dockerfile`.
CI (`hanzo-build-linux-amd64`, self-hosted) builds `linux/amd64` and publishes
`ghcr.io/hanzoai/nodejs:vX.Y.Z` + `:vX`. Never `:latest`, never `:sha`.
