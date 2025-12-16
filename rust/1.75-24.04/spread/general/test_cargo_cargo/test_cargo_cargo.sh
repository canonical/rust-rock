#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

## TESTS 
# spellchecker: ignore
tmpdir=$(mktemp -d)

url="https://github.com/rust-lang/cargo.git"
tag="rust-1.75.0"
# sudo rm -rf "$tmpdir/cargo" || true
git clone "$url" "$tmpdir/cargo" -b "$tag" --single-branch
defer "sudo rm -rf $tmpdir/cargo" EXIT

name=$(launch_container cargo "$tmpdir/cargo")
defer "docker rm --force $name &>/dev/null || true" EXIT

# Install dependencies of cargo
docker exec "$name" apt-get update
docker exec "$name" apt-get install -y libssl-dev pkg-config

# Compile cargo
docker exec --workdir /work "$name" cargo build

# Run the built cargo binary to verify it works
docker exec -t "$name" /work/target/debug/cargo --version | grep -q "cargo 1.75.0"
docker exec -t "$name" /work/target/debug/cargo help | grep -q "Rust's package manager"

# Create a new cargo project in /tmp
docker exec "$name" /work/target/debug/cargo new --bin /tmp/hello

# Build and run the project
docker exec --workdir /tmp/hello "$name" /work/target/debug/cargo build
docker exec -t "$name" /tmp/hello/target/debug/hello | grep -q "Hello, world!"

# Rebuild cargo with cargo, this time in release mode
docker exec --workdir /work "$name" /work/target/debug/cargo build --release

docker exec -t "$name" /work/target/release/cargo --version | grep -q "cargo 1.75.0"
docker exec -t "$name" /work/target/release/cargo help | grep -q "Rust's package manager"