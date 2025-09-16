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

url="https://github.com/rust-lang/cargo.git"
tag="rust-1.84.0"
sudo rm -rf "$FILE_DIR/testfiles/cargo" || true
git clone "$url" "$FILE_DIR/testfiles/cargo" -b "$tag" --single-branch
defer "sudo rm -rf $FILE_DIR/testfiles/cargo" EXIT

name=test_cargo
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD"/testfiles/cargo:/workdir rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Install dependencies of cargo
docker exec "$name" apt-get update
docker exec "$name" apt-get install -y libssl-dev pkg-config

# Compile cargo
docker exec --workdir /workdir "$name" cargo build

# Run the built cargo binary to verify it works
docker exec -t "$name" /workdir/target/debug/cargo --version | grep -q "cargo 1.84.0"
docker exec -t "$name" /workdir/target/debug/cargo help | grep -q "Rust's package manager"

# Create a new cargo project in /tmp
docker exec "$name" /workdir/target/debug/cargo new --bin /tmp/hello

# Build and run the project
docker exec --workdir /tmp/hello "$name" /workdir/target/debug/cargo build
docker exec -t "$name" /tmp/hello/target/debug/hello | grep -q "Hello, world!"

# Rebuild cargo with cargo, this time in release mode
docker exec --workdir /workdir "$name" /workdir/target/debug/cargo build --release

docker exec -t "$name" /workdir/target/release/cargo --version | grep -q "cargo 1.84.0"
docker exec -t "$name" /workdir/target/release/cargo help | grep -q "Rust's package manager"