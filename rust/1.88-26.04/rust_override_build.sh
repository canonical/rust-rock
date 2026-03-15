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
    # base-files_release-info  to indicate that this is a 26.04 rock
    slices+=(
        base-files_chisel
        base-files_release-info
    )

    # package management, to be able to install additional dependencies if needed 
    slices+=(apt_apt-get)

    chisel cut --release './' \
        --ignore=unstable \
        --root "$CRAFT_PART_INSTALL" \
        "${slices[@]}"
}

main "$@"