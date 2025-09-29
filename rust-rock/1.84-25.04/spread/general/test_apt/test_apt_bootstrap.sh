#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

## TESTS 
# spellchecker: ignore doctests rustdoc libpam tzdata coreutils

name=test_apt_bootstrap
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Make sure we can bootstrap apt
docker exec "$name" apt --bootstrap

# Verify apt works
docker exec "$name" apt info python3.13 \
    | sponge | head -n1 | grep -q "Package: python3.13"

# Install python 
docker exec "$name" apt install -y python3.13
docker exec "$name" python3.13 --version \
    | sponge | grep -q "Python 3.13"

# Repeat with apt-get
name=test_apt-get_bootstrap
docker rm -f "$name" 2>/dev/null || true
docker create --name "$name" rust-rock:latest > /dev/null
docker start "$name" 2>/dev/null || true
defer "docker rm --force $name &>/dev/null || true;" EXIT

# Make sure we can bootstrap apt-get
docker exec "$name" apt-get --bootstrap

# Verify apt-get works
docker exec "$name" apt info python3.13 \
    | sponge | head -n1 | grep -q "Package: python3.13"
