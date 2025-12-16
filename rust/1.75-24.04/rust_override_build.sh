set -e
# spellchecker: ignore rustc binutils archiver coreutils

function main() {
    local slices=(cargo_cargo) # cargo provides rustc and gcc too

    # ar is needed to create static libraries, which cargo sometimes does
    # when building dependencies
    slices+=(binutils_archiver)
    
    # cargo needs ca-certificates to be able to download crates.io index
    # + its required in SDK rocks
    slices+=(ca-certificates_data)

    # this is an SDK rock. we really want coreutils
    slices+=(coreutils_bins)

    # we want the base-files_chisel to generate the chisel manifest, and
    # base-files_release-info  to indicate that this is a 25.04 rock
    slices+=(
        base-files_chisel
        base-files_release-info
    )

    # package management, to be able to install additional dependencies if needed 
    slices+=(apt_apt-get)

    # fail if chisel version is too old (less than v1.3.0)
    local chisel_version=$(chisel --version)
    if ! echo "$chisel_version" | grep -qE 'v1\.[3-9][0-9]*'; then
        echo "chisel version is too old: $chisel_version. Please upgrade to at least v1.3.0." >&2
        exit 1
    fi

    local arch=$(echo "$CRAFT_ARCH_TRIPLET_BUILD_FOR" | cut -d- -f1)
    local chisel_arch=""
    case "$arch" in
        x86_64) chisel_arch="amd64" ;;
        aarch64)chisel_arch="arm64" ;;
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
    esac

    # NOTE: we have to pass the --arch flag to chisel to install the correct slices
    #       see: https://github.com/canonical/chisel/pull/256
    chisel cut --release './' \
        --root "$CRAFT_PART_INSTALL" \
        --arch "$chisel_arch" \
        "${slices[@]}"

    # we need to create a symlink for rustc to find the linker
    ln -s gcc "$CRAFT_PART_INSTALL"/usr/bin/cc
}

main "$@"
