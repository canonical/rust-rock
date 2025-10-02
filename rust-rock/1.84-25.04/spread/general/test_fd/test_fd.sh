#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

tmpdir=$(mktemp -d)

## TESTS 
# spellchecker: ignore fd binutils libc

url="https://github.com/sharkdp/fd/archive/refs/tags/v10.3.0.tar.gz"
# sudo rm -rf "$tmpdir/fd" || true
mkdir -p "$tmpdir/fd"
wget -qO- "$url" | tar xz --strip 1 -C "$tmpdir/fd"
defer "sudo rm -rf $tmpdir/fd" EXIT

name=$(launch_container fd "$tmpdir/fd")
defer "docker rm --force $name &>/dev/null || true" EXIT

# Build
docker exec --workdir /work "$name" cargo build --no-default-features

# Run tests
skip=(
    test_exec
    test_exec_batch
    test_exec_batch_multi
    test_exec_batch_with_limit
    test_exec_invalid_utf8
    test_exec_multi
    test_exec_with_separator
    test_list_details
)
skip_flags=$(printf "%s\n" "${skip[@]}" | sed 's/^/--skip /' | xargs)
# shellcheck disable=SC2086
docker exec --workdir /work "$name" cargo test \
    --no-default-features \
    -- $skip_flags --show-output

# # Run the built binary to verify it works
docker exec "$name" /work/target/debug/fd --help 2>&1 \
    | sponge | head -n1 | grep -q "A program to find entries in your filesystem"
docker exec "$name" /work/target/debug/fd --version \
    | sponge | grep -q "fd 10.3.0"
docker exec --workdir / "$name" /work/target/debug/fd --color never libc.so.6 \
    | sponge | grep -q "libc.so.6"
