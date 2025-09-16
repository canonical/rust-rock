#!/usr/bin/env bash

FILE_DIR=$(realpath "$(dirname "$0")")

if [[ "$1" != "--spread" ]]; then
    # shellcheck source=./setup.sh
    source "$FILE_DIR"/setup.sh
fi

# shellcheck source=./defer.sh
source "$FILE_DIR"/defer.sh

## TESTS 
# spellchecker: ignore oxidizr

url="https://github.com/jnsgruk/oxidizr/archive/refs/tags/v1.0.1.tar.gz"
sudo rm -rf "$FILE_DIR/testfiles/oxidizr" || true
mkdir -p "$FILE_DIR/testfiles/oxidizr"
wget -qO- "$url" | tar xz --strip 1 -C "$FILE_DIR/testfiles/oxidizr"
defer "sudo rm -rf $FILE_DIR/testfiles/oxidizr" EXIT

name=test_oxidizr
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD"/testfiles/oxidizr:/workdir rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Build
docker exec --workdir /workdir "$name" cargo build

# Run tests
docker exec --workdir /workdir "$name" cargo test -- --show-output

# Run the built binary to verify it works
help=$(docker exec -t "$name" /workdir/target/debug/oxidizr --help | head -n1)
echo "$help" | grep -q "A command-line utility to install modern Rust-based replacements of essential packages"
version=$(docker exec -t "$name" /workdir/target/debug/oxidizr --version)
# yep. there's a version mismatch between the tag and Cargo.toml
echo "$version" | grep -q "oxidizr 1.0.0"

