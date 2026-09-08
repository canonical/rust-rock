#!/usr/bin/env bash

## TESTS
# spellchecker: ignore pts

# with no arguments the rock runs its default command
docker run --rm rust-rock:latest \
    | sponge | grep -q "Rust's package manager"

# arguments after the image name replace that default
docker run --rm rust-rock:latest cargo --version \
    | sponge | grep -q 'cargo 1.93'

# the command's own exit status is what docker reports
status=0
docker run --rm rust-rock:latest sh -c 'exit 42' || status=$?
test "$status" -eq 42

# the command runs in /work, mounted or not
docker run --rm rust-rock:latest pwd \
    | sponge | grep -q '^/work$'
docker run --rm -v "$(pwd):/work" rust-rock:latest pwd \
    | sponge | grep -q '^/work$'

# and somewhere else if HOME says so
docker run --rm -e HOME=/tmp rust-rock:latest pwd \
    | sponge | grep -q '^/tmp$'

# the command gets a real terminal when docker allocates one
docker run --rm -t rust-rock:latest sh -c '[ -t 1 ] && echo TTY_OK' \
    | sponge | grep -q '^TTY_OK'
