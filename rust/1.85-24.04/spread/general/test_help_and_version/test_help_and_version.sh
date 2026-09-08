#!/usr/bin/env bash

## TESTS 
# spellchecker: ignore rustc

# cargo
docker run --rm rust-rock:latest cargo --help \
    | sponge | grep -q "Rust's package manager"
docker run --rm rust-rock:latest cargo --version \
    | sponge | grep -q 'cargo 1.85'

# rust
docker run --rm rust-rock:latest rustc --help \
    | sponge | grep -q "Usage: rustc"
docker run --rm rust-rock:latest rustc --version \
    | sponge | grep -q 'rustc 1.85'

# gcc
docker run --rm rust-rock:latest gcc --help \
    | sponge | grep -q "Usage: gcc"
docker run --rm rust-rock:latest gcc --version \
    | sponge | head -n1 | grep -q 'gcc (Ubuntu 13'
