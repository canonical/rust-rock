#!/bin/sh
# spellchecker: ignore coreutils
# NOTE: this is a dash script, not bash!
#
# This script replaces `apt` and `apt-get` until they are properly installed.
# Unless called with `--bootstrap` it will just print a message and exit 1.
# With the flag it will reinstall apt properly. The key bit is:
#
#   apt-ger update && apt-get install --no-install-recommends -y coreutils dpkg apt
#

set -e

APT_REAL="/usr/bin/.apt"
APT_GET_REAL="/usr/bin/.apt-get"
APT_SHIM="/usr/bin/.apt-shim"

fatal() { printf "Error: %s\n" "$1" >&2; exit 1; }

# shellcheck disable=SC2317
on_exit() {
    [ $? -ne 0 ] && fatal "Apt bootstrap failed with status $?."
    rm -f "$APT_REAL" "$APT_GET_REAL"
    rm -f "$APT_SHIM"
    printf "Apt has been successfully bootstrapped.\n"
    return $?
}

bootstrap() {
    printf "Bootstrapping apt...\n"
    # make sure the real apt and apt-get exist
    test -x "$APT_REAL" || fatal "$APT_REAL not found or not executable."
    test -x "$APT_GET_REAL" || fatal "$APT_GET_REAL not found or not executable."
    # make sure apt and apt-get symlinks exist
    test -L /usr/bin/apt || fatal "/usr/bin/apt is not a symlink."
    test -L /usr/bin/apt-get || fatal "/usr/bin/apt-get is not a symlink."
    # test that the shim exists and this script is running as the shim
    test -f "$APT_SHIM" || fatal "$APT_SHIM not found."
    test "$0" = "/usr/bin/apt-get" -o "$0" = "/usr/bin/apt" || \
        fatal "$0 is not /usr/bin/apt or /usr/bin/apt-get."
    trap 'on_exit' EXIT
    "$APT_GET_REAL" update
    "$APT_GET_REAL" install --no-install-recommends --yes coreutils dpkg apt
    exit $?
}

message_str="This apt installation has been minimized and is not yet fully functional.
To restore a fully functional apt, please run:
    $0 --bootstrap"

main() {
    if [ "$1" = "--bootstrap" ]; then
        bootstrap
    else
        printf "%s\n" "$message_str" >&2; exit 1;
    fi
}

main "$@"
