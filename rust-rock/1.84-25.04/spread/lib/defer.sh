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
    declare -f -t defer

    ############################################################################
    # Self-test when run directly with --test
    if [[ "${BASH_SOURCE[0]}" == "$0" && "$1" == "--test" ]]; then
        function test_basic() {
            test_var=0
            defer "test_var=1" USR1
            test "$test_var" -eq 0 || return 1
            kill -USR1 $$
            test "$test_var" -eq 1 || return 1
        }

        function test_defer_order() {
            output=""
            defer "output+='1'" USR1
            defer "output+='2'" USR1
            defer "output+='3'" USR1
            kill -USR1 $$
            test "$output" = "321" || return 1
        }

        function test_tolerates_trailing_semicolon() {
            test_var=0
            defer "test_var=1;" USR1
            test "$test_var" -eq 0 || return 1
            kill -USR1 $$
            test "$test_var" -eq 1 || return 1
        }

        function test_captures_status() {
            # When using $? we see the status of the previous deferred command
            test "$(
                defer 'echo $?' EXIT
                defer 'false' EXIT
                exit 99
            )" -eq 1 || return 1
            # But $status captures the status of the command that triggered the trap
            test "$(
                defer 'echo $status' EXIT
                defer 'false' EXIT
                exit 99
            )" -eq 99 || return 1
        }

        status=0
        # Find all the test functions and run them
        for test_func in $(declare -F | awk '{print $3}' | grep '^test_' | sort); do
            printf "Running %s... " "$test_func"
            if $test_func; then
                printf "\e[32mpass\e[0m\n"
            else
                printf "\e[31mfail\e[0m\n"
                status=1
            fi
        done

        if [[ $status -eq 0 ]]; then
            echo -e "\e[32mSelf-test passed\e[0m"
        else
            echo -e "\e[31mSelf-test failed\e[0m"
        fi
    fi

    export __DEFER_SH__=1
fi