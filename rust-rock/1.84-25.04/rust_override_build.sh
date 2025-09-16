set -e
# spellchecker: ignore rustc binutils libgcc

function main() {
    local slices=(
        cargo-1.84_cargo
        rustc-1.84_rustc
        gcc-14-"${CRAFT_ARCH_TRIPLET_BUILD_FOR//_/-}"_gcc-14
        binutils-"${CRAFT_ARCH_TRIPLET_BUILD_FOR//_/-}"_linker
        libgcc-14-dev_libgcc
    )

    # we need cpp and as for gcc to be able to create executables
    slices+=(
        cpp-14-"${CRAFT_ARCH_TRIPLET_BUILD_FOR//_/-}"_cc1
        binutils-"${CRAFT_ARCH_TRIPLET_BUILD_FOR//_/-}"_assembler
    )

    # ar is needed to create static libraries, which cargo sometimes does
    # when building dependencies
    slices+=(binutils-"${CRAFT_ARCH_TRIPLET_BUILD_FOR//_/-}"_archiver)
    
    # cargo needs ca-certificates to be able to download crates.io index
    # + its required in SDK rocks
    slices+=(ca-certificates_data)

    # package management, to be able to install additional dependencies if needed 
    slices+=(apt_apt-get)

    chisel cut --release './' \
        --root "$CRAFT_PART_INSTALL" \
        "${slices[@]}"

    ln -s cargo-1.84 "$CRAFT_PART_INSTALL"/usr/bin/cargo
    ln -s rustc-1.84 "$CRAFT_PART_INSTALL"/usr/bin/rustc
    ln -s \
        "$CRAFT_ARCH_TRIPLET_BUILD_FOR"-gcc-14 \
        "$CRAFT_PART_INSTALL"/usr/bin/cc
    ln -s \
        "$CRAFT_ARCH_TRIPLET_BUILD_FOR"-ld \
        "$CRAFT_PART_INSTALL"/usr/bin/ld
    ln -s \
        "$CRAFT_ARCH_TRIPLET_BUILD_FOR"-as \
        "$CRAFT_PART_INSTALL"/usr/bin/as
    ln -s \
        "$CRAFT_ARCH_TRIPLET_BUILD_FOR"-ar \
        "$CRAFT_PART_INSTALL"/usr/bin/ar

    # Also link gcc-14 to gcc, so that build scripts that expect to find `gcc` in PATH work correctly.
    ln -s \
        "$CRAFT_ARCH_TRIPLET_BUILD_FOR"-gcc-14 \
        "$CRAFT_PART_INSTALL"/usr/bin/gcc
}

main "$@"
