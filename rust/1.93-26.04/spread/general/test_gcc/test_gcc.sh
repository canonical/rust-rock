#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh
# shellcheck source=../../lib/defer.sh
source defer.sh

name=$(launch_container gcc)
defer "docker rm --force $name &>/dev/null || true" EXIT

docker exec "$name" gcc /work/hello.c -o /tmp/hello
docker exec "$name" /tmp/hello \
    | sponge | grep -q "Hello from C!"
