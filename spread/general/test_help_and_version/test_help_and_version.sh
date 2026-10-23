#!/usr/bin/env bash

## TESTS 
# spellchecker: ignore rustc

# cargo
docker run --rm rust-rock:1.93-26.04 exec cargo --help \
    | sponge | grep -q "Rust's package manager"
docker run --rm rust-rock:1.93-26.04 exec cargo --version \
    | sponge | grep -q 'cargo 1.93'

# rust
docker run --rm rust-rock:1.93-26.04 exec rustc --help \
    | sponge | grep -q "Usage: rustc"
docker run --rm rust-rock:1.93-26.04 exec rustc --version \
    | sponge | grep -q 'rustc 1.93'

# gcc
docker run --rm rust-rock:1.93-26.04 exec gcc --help \
    | sponge | grep -q "Usage: gcc"
docker run --rm rust-rock:1.93-26.04 exec gcc --version \
    | sponge | head -n1 | grep -q 'gcc (Ubuntu 15'
