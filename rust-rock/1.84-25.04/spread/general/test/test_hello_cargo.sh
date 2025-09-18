#!/usr/bin/env bash

FILE_DIR=$(realpath "$(dirname "$0")")

if [[ "$1" != "--spread" ]]; then
    # shellcheck source=./setup.sh
    source "$FILE_DIR"/setup.sh
fi

# shellcheck source=./defer.sh
source "$FILE_DIR"/defer.sh

## TESTS 
# spellchecker: ignore

name=test_hello_cargo
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD":/workdir:ro rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

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
