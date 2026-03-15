#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

name=$(launch_container apt)
defer "docker rm --force $name &>/dev/null || true" EXIT

# Run apt update
docker exec "$name" apt update

# Verify apt works
docker exec "$name" apt info python3.12 \
    | sponge | head -n1 | grep -q "Package: python3.12"

# Install python 
docker exec "$name" apt install -y python3.12
docker exec "$name" python3.12 --version \
    | sponge | grep -q "Python 3.12"
