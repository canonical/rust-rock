#!/usr/bin/env bash

# shellcheck source=../../lib/defer.sh
source defer.sh

## TESTS 
# spellchecker: ignore

name=test_hello_rustc
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v ./testfiles:/workdir:ro rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true" EXIT

docker exec "$name" rustc /workdir/hello.rs -o /tmp/hello
docker exec "$name" /tmp/hello \
    | sponge | grep -q "Hello from Rust!"
