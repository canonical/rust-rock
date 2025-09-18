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

name=test_hello_rustc
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD":/workdir:ro rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true" EXIT

docker exec "$name" rustc /workdir/testfiles/hello.rs -o /tmp/hello
docker exec "$name" /tmp/hello \
    | sponge | grep -q "Hello from Rust!"
