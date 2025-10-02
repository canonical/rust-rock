#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh

# spellchecker: ignore rustc

name=$(launch_container rustc)

docker exec "$name" rustc /work/hello.rs -o /tmp/hello
docker exec "$name" /tmp/hello \
    | sponge | grep -q "Hello from Rust!"
