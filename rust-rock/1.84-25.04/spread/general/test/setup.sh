# Setup which mimics the spread environment
# spellchecker: ignore rockcraft skopeo

FILE_DIR=$(realpath "$(dirname "$0")")

# shellcheck source=./defer.sh
source "$FILE_DIR"/defer.sh

fatal() { echo "Error: $1" >&2; exit 1; }

# check FILE_DIR is set
[[ -z "$FILE_DIR" ]] && fatal "FILE_DIR is not set"

# find PROJECT_PATH by walking up until you find rockcraft.yaml
PROJECT_PATH=$(realpath "$FILE_DIR")
# walk up until you find rockcraft.yaml
while [[ ! -f "$PROJECT_PATH/rockcraft.yaml" ]]; do
    PROJECT_PATH=$(dirname "$PROJECT_PATH")
    [[ "$PROJECT_PATH" == "/" ]] && fatal "Could not find rockcraft.yaml"
done
export PROJECT_PATH

CRAFT_ARTIFACT=$(find "$PROJECT_PATH" -maxdepth 1 -name '*.rock' -print -quit)
[[ -z "$CRAFT_ARTIFACT" ]] && fatal "Could not find rockcraft artifact in $PROJECT_PATH"

command -v docker >/dev/null 2>&1 || fatal "docker is not installed"
command -v rockcraft >/dev/null 2>&1 || fatal "rockcraft is not installed"
command -v sponge >/dev/null 2>&1 || fatal "sponge is not installed. Please install the moreutils package"

sudo rockcraft.skopeo \
    --insecure-policy copy \
    "oci-archive:$CRAFT_ARTIFACT" \
    docker-daemon:rust-rock:latest &>/dev/null \
    || fatal "Could not import $CRAFT_ARTIFACT to docker"

defer "docker image rm --force rust-rock:latest &>/dev/null || true" EXIT

# all tests expect to run from their directory
# shellcheck disable=SC2064
defer "cd \"$PWD\" || true" EXIT
cd "$FILE_DIR" || exit 1

# use trap to echo a message on exit
on_exit() {
    case $status in
        0) echo -e "\e[32mTest passed\e[0m: $0" ;;
        130) echo -e "\e[33mTest interrupted\e[0m: $0" ;;
        *) echo -e "\e[31mTest failed\e[0m: $0" ;;
    esac
}
# shellcheck disable=SC2064
defer "on_exit" EXIT
defer 'exit 130' INT TERM

# Set bash options
set -euxo pipefail
