#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh

name=$(launch_container cargo)

# Create a new cargo project in /tmp
docker exec "$name" cargo new --bin /tmp/hello

# Build and run the project
docker exec "$name" cargo -Z unstable-options -C /tmp/hello build
docker exec "$name" /tmp/hello/target/debug/hello \
    | sponge | grep -q "Hello, world!"

# Now in release mode
docker exec "$name" cargo -Z unstable-options -C /tmp/hello build --release
docker exec "$name" /tmp/hello/target/release/hello \
    | sponge | grep -q "Hello, world!"
