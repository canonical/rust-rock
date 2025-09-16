#!/usr/bin/env bash

FILE_DIR=$(realpath "$(dirname "$0")")

if [[ "$1" != "--spread" ]]; then
    # shellcheck source=./setup.sh
    source "$FILE_DIR"/setup.sh
fi

# shellcheck source=./defer.sh
source "$FILE_DIR"/defer.sh

## TESTS 
# spellchecker: ignore tzdata libpam

url="https://github.com/trifectatechfoundation/sudo-rs.git"
tag="v0.2.8"
sudo rm -rf "$FILE_DIR/testfiles/sudo-rs" || true
git clone "$url" "$FILE_DIR/testfiles/sudo-rs" -b "$tag" --single-branch
defer "sudo rm -rf $FILE_DIR/testfiles/sudo-rs" EXIT

name=test_sudo
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD"/testfiles/sudo-rs:/workdir rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Install dependencies of sudo-rs
docker exec "$name" apt-get update
docker exec "$name" apt-get install -y tzdata libpam0g-dev

docker exec --workdir /workdir "$name" cargo build

# Run the built binary to verify it works
docker exec -t "$name" /workdir/target/debug/sudo --help | grep -q "sudo - run commands as another user"
docker exec -t "$name" /workdir/target/debug/sudo --version | grep -q "sudo-rs 0.2.8"
