# LLM.md — hanzoai/nodejs

Canonical Node base image for the whole Hanzo Node fleet. One base, one way.

## What this is

`FROM node:24.18.0-alpine` + the sqlite3 toolchain, published as
`ghcr.io/hanzoai/nodejs:v24.18.0` (+ `:v24`). Every Hanzo Node service does
`FROM ghcr.io/hanzoai/nodejs:v24.18.0` so Node 24 and sqlite3 are uniform.

## sqlite3, two ways (both build-gated)

- `require('node:sqlite')` (builtin `DatabaseSync`, stable Node ≥22.5) — no deps.
- `better-sqlite3` / `sqlite3` compile via node-gyp against `build-base` +
  `python3` + `sqlite-dev`. The Dockerfile compiles better-sqlite3 at build time
  and round-trips it; the image fails to build if that breaks.

## Why alpine

Majority of Hanzo Node services already use `node:*-alpine`. better-sqlite3
compiles cleanly on musl with `build-base`; `node:sqlite` is builtin regardless.
`libc6-compat` lets prebuilt glibc addons load. Debian-slim consumers
(paas, platform, base-studio, market, embeddings, store-api, insights, gallery)
need an `apt-get`→`apk` port before switching to this base — tracked as the sweep tail.

## Release / bump

1. Edit the `FROM node:<X.Y.Z>-alpine` pin in `Dockerfile` to move the runtime.
2. Tag `vX.Y.Z` (must equal the Node version). CI publishes `:vX.Y.Z` + `:vX`.
3. Consumers bump their `FROM ghcr.io/hanzoai/nodejs:vX.Y.Z` pin on their own release.

CI: `.github/workflows/build.yml`, self-contained, routes to `hanzo-build-linux-amd64`.
amd64-only (DOKS has no arm64). Semver only, never sha/latest.
