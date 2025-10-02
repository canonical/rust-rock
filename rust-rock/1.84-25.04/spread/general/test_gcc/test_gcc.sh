#!/usr/bin/env bash

# shellcheck source=../../lib/common.sh
source common.sh

name=$(launch_container gcc)

docker exec "$name" gcc /work/hello.c -o /tmp/hello
docker exec "$name" /tmp/hello \
    | sponge | grep -q "Hello from C!"
