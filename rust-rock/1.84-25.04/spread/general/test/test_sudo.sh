#!/usr/bin/env bash

FILE_DIR=$(realpath "$(dirname "$0")")

if [[ "$1" != "--spread" ]]; then
    # shellcheck source=./setup.sh
    source "$FILE_DIR"/setup.sh
fi

# shellcheck source=./defer.sh
source "$FILE_DIR"/defer.sh

## TESTS 
# spellchecker: ignore doctests rustdoc libpam tzdata

url="https://github.com/trifectatechfoundation/sudo-rs/archive/refs/tags/v0.2.8.tar.gz"
sudo rm -rf "$FILE_DIR/testfiles/sudo-rs" || true
mkdir -p "$FILE_DIR/testfiles/sudo-rs"
wget -qO- "$url" | tar xz --strip 1 -C "$FILE_DIR/testfiles/sudo-rs"
defer "sudo rm -rf $FILE_DIR/testfiles/sudo-rs" EXIT

name=test_sudo
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$PWD"/testfiles/sudo-rs:/workdir rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Install dependencies of sudo-rs
docker exec "$name" apt-get update
docker exec "$name" apt-get install -y coreutils dpkg apt
docker exec "$name" apt-get install -y tzdata libpam0g-dev

# Build
docker exec --workdir /workdir "$name" cargo build

# Run tests
# disable doctests since we don't have rustdoc
# tests which we expect to fail
skip=(
    common::resolve::test::canonicalization
    su::context::tests::group_as_non_root
    su::context::tests::su_to_root
    system::audit::test::test_secure_open_cookie_file
)
skip_flags=$(printf "%s\n" "${skip[@]}" | sed 's/^/--skip /' | xargs)
# shellcheck disable=SC2086
docker exec --workdir /workdir "$name" cargo test \
    --lib --bins --tests \
    -- $skip_flags --show-output

# Run the built binary to verify it works
docker exec -t "$name" /workdir/target/debug/sudo --help | grep -q "sudo - run commands as another user"
docker exec -t "$name" /workdir/target/debug/sudo --version | grep -q "sudo-rs 0.2.8"
