#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

tmpdir=$(mktemp -d)

## TESTS 
# spellchecker: ignore doctests rustdoc libpam tzdata coreutils

url="https://github.com/trifectatechfoundation/sudo-rs/archive/refs/tags/v0.2.8.tar.gz"
sudo rm -rf "$tmpdir/sudo-rs" || true
mkdir -p "$tmpdir/sudo-rs"
wget -qO- "$url" | tar xz --strip 1 -C "$tmpdir/sudo-rs"
defer "sudo rm -rf $tmpdir/sudo-rs" EXIT

name=test_sudo
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" -v "$tmpdir/sudo-rs:/workdir" rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Install dependencies of sudo-rs
docker exec "$name" apt-get --bootstrap
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
docker exec -t "$name" /workdir/target/debug/sudo --help \
    | sponge | grep -q "sudo - run commands as another user"
docker exec -t "$name" /workdir/target/debug/sudo --version \
    | sponge | grep -q "sudo-rs 0.2.8"
