#!/usr/bin/env bash

# shellcheck source=../../lib/defer.sh
source defer.sh

## TESTS 
# spellchecker: ignore

name=test_hello_gcc
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v ./testfiles:/workdir:ro rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true" EXIT

docker exec "$name" gcc /workdir/hello.c -o /tmp/hello
docker exec "$name" /tmp/hello \
    | sponge | grep -q "Hello from C!"
