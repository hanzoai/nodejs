# hanzoai/nodejs — the ONE canonical Node base image for every Hanzo Node service.
#
# Node 24 (LTS "Krypton") + sqlite3 bundled two ways, BOTH proven at build time:
#   1. node:sqlite — the built-in DatabaseSync (stable since Node 22.5; present in
#      24). `require('node:sqlite')` works out of the box, zero dependencies.
#   2. native npm sqlite — better-sqlite3 / sqlite3 compile against the baked-in
#      toolchain (build-base + python3 + sqlite-dev) through node-gyp.
#
# One base, one way. Services do:  FROM ghcr.io/hanzoai/nodejs:v24.18.0
# Bump the pinned node:<ver>-alpine below to move the whole fleet's runtime;
# the git tag (vX.Y.Z) must match the Node version so consumers can reason about it.
FROM node:24.18.0-alpine

# Native addon build toolchain (node-gyp needs python3 + make + g++, all via
# build-base), the system sqlite CLI + headers, and the glibc shim so prebuilt
# (glibc) native addons load on musl. corepack ships pnpm/yarn shims.
RUN apk add --no-cache \
      build-base \
      python3 \
      sqlite \
      sqlite-dev \
      libc6-compat \
 && corepack enable

# Build-time proof gate — the image FAILS TO BUILD if either sqlite path breaks.
#   (1) node:sqlite builtin round-trips an in-memory DB.
#   (2) better-sqlite3 compiles from source against the toolchain and round-trips.
# The verify scratch dir is removed so it adds no weight to the published layer.
RUN node -e "const {DatabaseSync}=require('node:sqlite');const d=new DatabaseSync(':memory:');d.exec('create table t(x int)');d.prepare('insert into t values (?)').run(7);if(d.prepare('select x from t').get().x!==7)throw new Error('node:sqlite roundtrip failed');console.log('node:sqlite OK on '+process.version);" \
 && mkdir -p /tmp/verify && cd /tmp/verify && npm init -y >/dev/null 2>&1 \
 && npm install --no-audit --no-fund better-sqlite3 >/dev/null 2>&1 \
 && node -e "const D=require('better-sqlite3');const db=new D(':memory:');db.exec('create table t(x int)');db.prepare('insert into t values (?)').run(42);if(db.prepare('select x from t').get().x!==42)throw new Error('better-sqlite3 roundtrip failed');console.log('better-sqlite3 '+require('better-sqlite3/package.json').version+' OK');" \
 && cd / && rm -rf /tmp/verify /root/.npm

# Match the upstream node image default so this is a transparent drop-in.
CMD ["node"]
