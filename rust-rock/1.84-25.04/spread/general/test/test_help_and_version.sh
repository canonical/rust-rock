#!/usr/bin/env bash

if [[ "$1" != "--spread" ]]; then
    FILE_DIR=$(realpath "$(dirname "$0")")
    source "$FILE_DIR"/setup.sh
fi

## TESTS 
# spellchecker: ignore rustc

# cargo
docker run --rm rust-rock:latest exec cargo --help | grep -q "Rust's package manager"
docker run --rm rust-rock:latest exec cargo --version | grep -q 'cargo 1.84'

# rust
docker run --rm rust-rock:latest exec rustc --help | grep -q "Usage: rustc"
docker run --rm rust-rock:latest exec rustc --version | grep -q 'rustc 1.84'

# gcc
docker run --rm rust-rock:latest exec gcc --help | grep -q "Usage: gcc"
gcc_version=$(docker run --rm rust-rock:latest exec gcc --version | head -n1)
echo "$gcc_version"
echo "$gcc_version" | grep -q "gcc"
echo "$gcc_version" | grep -q "14."
