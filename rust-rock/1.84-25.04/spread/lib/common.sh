# spellchecker: ignore sigpipe
# Set bash options
set -euxo pipefail
# ignore sigpipe
trap '' SIGPIPE