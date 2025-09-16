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

url="https://github.com/eza-community/eza/archive/refs/tags/v0.23.3.tar.gz"
sudo rm -rf "$FILE_DIR/testfiles/eza" || true
mkdir -p "$FILE_DIR/testfiles/eza"
wget -qO- "$url" | tar xz --strip 1 -C "$FILE_DIR/testfiles/eza"
defer "sudo rm -rf $FILE_DIR/testfiles/eza" EXIT

name=test_eza
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD"/testfiles/eza:/workdir rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

docker exec --workdir /workdir "$name" cargo build

# # Run the built eza binary to verify it works
docker exec -t "$name" /workdir/target/debug/eza --help | grep -q "eza \[options\] \[files...\]"
docker exec -t "$name" /workdir/target/debug/eza /workdir | grep -q "README.md"
docker exec -t "$name" /workdir/target/debug/eza /workdir/target/debug/eza | grep -q "eza"
