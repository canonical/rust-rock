if [[ -z "${__DEFER_SH__:-}" ]]; then

    # Adapted from post by Richard Hansen:
    # https://stackoverflow.com/a/7287873/2531987
    # CC-BY-SA 3.0
    function defer() {
        local defer_cmd="$1"; shift
        defer_cmd="${defer_cmd%%;}"
        _fatal() { echo "Error: $1" >&2; exit 1; }
        _extract() { printf '%s\n' "$3"; }
        for defer_name in "$@"; do
            local existing_cmd=$(eval "_extract $(trap -p "${defer_name}")")
            existing_cmd=${existing_cmd#'status=$?; '} # remove leading status capture
            new_cmd="$(printf '%s' 'status=$?; '; printf '%s; ' "${defer_cmd}"; printf '%s' "${existing_cmd}")"
            trap -- "$new_cmd" "$defer_name" || _fatal "unable to modify trap ${defer_name}"
        done
    }

    export __DEFER_SH__=1
fi