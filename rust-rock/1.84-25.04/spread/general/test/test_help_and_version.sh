#!/usr/bin/env bash

if [[ "$1" != "--spread" ]]; then
    FILE_DIR=$(realpath "$(dirname "$0")")
    source "$FILE_DIR"/setup.sh
fi

## TESTS 
# spellchecker: ignore rustc

# cargo
docker run --rm rust-rock:latest exec cargo --help \
    | sponge | grep -q "Rust's package manager"
docker run --rm rust-rock:latest exec cargo --version \
    | sponge | grep -q 'cargo 1.84'

# rust
docker run --rm rust-rock:latest exec rustc --help \
    | sponge | grep -q "Usage: rustc"
docker run --rm rust-rock:latest exec rustc --version \
    | sponge | grep -q 'rustc 1.84'

# gcc
docker run --rm rust-rock:latest exec gcc --help \
    | sponge | grep -q "Usage: gcc"
docker run --rm rust-rock:latest exec gcc --version \
    | sponge | head -n1 | grep -q 'gcc (Ubuntu 14'
