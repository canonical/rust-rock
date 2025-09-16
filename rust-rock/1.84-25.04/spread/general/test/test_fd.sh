#!/usr/bin/env bash

FILE_DIR=$(realpath "$(dirname "$0")")

if [[ "$1" != "--spread" ]]; then
    # shellcheck source=./setup.sh
    source "$FILE_DIR"/setup.sh
fi

# shellcheck source=./defer.sh
source "$FILE_DIR"/defer.sh

## TESTS 
# spellchecker: ignore fd binutils libc

url="https://github.com/sharkdp/fd/archive/refs/tags/v10.3.0.tar.gz"
sudo rm -rf "$FILE_DIR/testfiles/fd" || true
mkdir -p "$FILE_DIR/testfiles/fd"
wget -qO- "$url" | tar xz --strip 1 -C "$FILE_DIR/testfiles/fd"
defer "sudo rm -rf $FILE_DIR/testfiles/fd" EXIT

name=test_fd
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD"/testfiles/fd:/workdir rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

docker exec --workdir /workdir "$name" cargo build --no-default-features

# # Run the built binary to verify it works
help=$(docker exec -t "$name" /workdir/target/debug/fd --help)
echo "$help" | grep -q "A program to find entries in your filesystem"
version=$(docker exec -t "$name" /workdir/target/debug/fd --version)
echo "$version" | grep -q "fd 10.3.0"
libc=$(docker exec -t --workdir / "$name" /workdir/target/debug/fd --color never libc.so.6)
echo "$libc" | grep -q "libc.so.6"
