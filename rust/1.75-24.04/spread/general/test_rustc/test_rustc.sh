#!/usr/bin/env bash

# spellchecker: ignore rustc

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

name=$(launch_container rustc)
defer "docker rm --force $name &>/dev/null || true" EXIT

docker exec "$name" rustc /work/hello.rs -o /tmp/hello
docker exec "$name" /tmp/hello \
    | sponge | grep -q "Hello from Rust!"
