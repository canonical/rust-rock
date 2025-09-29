#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh


tmpdir=$(mktemp -d)

## TESTS 
# spellchecker: ignore oxidizr

url="https://github.com/jnsgruk/oxidizr/archive/refs/tags/v1.0.1.tar.gz"
sudo rm -rf "$tmpdir/oxidizr" || true
mkdir -p "$tmpdir/oxidizr"
wget -qO- "$url" | tar xz --strip 1 -C "$tmpdir/oxidizr"
defer "sudo rm -rf $tmpdir/oxidizr" EXIT

name=test_oxidizr
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$tmpdir/oxidizr:/workdir" rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Build
docker exec --workdir /workdir "$name" cargo build

# Run tests
docker exec --workdir /workdir "$name" cargo test -- --show-output

# Run the built binary to verify it works
docker exec -t "$name" /workdir/target/debug/oxidizr --help \
    | sponge | head -n1 | grep -q "A command-line utility to install modern Rust-based replacements of essential packages"
# yep. there's a version mismatch between the tag and Cargo.toml
docker exec -t "$name" /workdir/target/debug/oxidizr --version \
    | sponge | head -n1 | grep -q "oxidizr 1.0.0"
