#!/usr/bin/env bash
# spellchecker: ignore doctests rustdoc

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

tmpdir=$(mktemp -d)

url="https://github.com/eza-community/eza/archive/refs/tags/v0.23.3.tar.gz"
# sudo rm -rf "$tmpdir/eza" || true
mkdir -p "$tmpdir/eza"
wget -qO- "$url" | tar xz --strip 1 -C "$tmpdir/eza"
defer "sudo rm -rf $tmpdir/eza" EXIT

name=test_eza
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$tmpdir/eza:/workdir" rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Build
docker exec --workdir /workdir "$name" cargo build

# Run tests
# disable doctests since we don't have rustdoc
docker exec --workdir /workdir "$name" cargo test --lib --bins --tests

# # Run the built eza binary to verify it works
docker exec -t "$name" /workdir/target/debug/eza --help | grep -q "eza \[options\] \[files...\]"
docker exec -t "$name" /workdir/target/debug/eza /workdir | grep -q "README.md"
docker exec -t "$name" /workdir/target/debug/eza /workdir/target/debug/eza | grep -q "eza"
