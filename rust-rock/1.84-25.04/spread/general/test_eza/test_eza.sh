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

name=$(launch_container eza "$tmpdir/eza")
defer "docker rm --force $name &>/dev/null || true" EXIT

# Build
docker exec --workdir /work "$name" cargo build

# Run tests
# disable doctests since we don't have rustdoc
docker exec --workdir /work "$name" cargo test --lib --bins --tests

# # Run the built eza binary to verify it works
docker exec -t "$name" /work/target/debug/eza --help | grep -q "eza \[options\] \[files...\]"
docker exec -t "$name" /work/target/debug/eza /work | grep -q "README.md"
docker exec -t "$name" /work/target/debug/eza /work/target/debug/eza | grep -q "eza"
