#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh

name=$(launch_container apt)

# Run apt update
docker exec "$name" apt update

# Verify apt works
docker exec "$name" apt info python3.13 \
    | sponge | head -n1 | grep -q "Package: python3.13"

# Install python 
docker exec "$name" apt install -y python3.13
docker exec "$name" python3.13 --version \
    | sponge | grep -q "Python 3.13"
