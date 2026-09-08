# Rust rock

This repository contains the SDK [rock](https://documentation.ubuntu.com/server/explanation/virtualisation/about-rock-images/) definitions for the [rust](https://www.rust-lang.org/) programming language.

This contains a minimal Rust toolchain and Cargo build system which can be used to build a wide variety of Rust applications. It also includes a minimal GCC toolchain to custom build steps in Cargo builds.

Any additional dependencies can be either mounted at runtime or installed
with the apt installation included in this rock.

## Example

Let's build [`sudo-rs`](https://github.com/trifectatechfoundation/sudo-rs)!

First clone the repository and checkout a specific tag:

```bash
git clone --depth 1 --branch v0.2.8 https://github.com/trifectatechfoundation/sudo-rs
cd sudo-rs
```

`sudo-rs` needs a couple of dependencies that are not in the rock, so lets get a
shell in the container with the code directory mounted:

```bash
docker run --rm -it -v ./:/work rust:1.75 sh
```

Now install the dependencies:

```bash
apt update && apt install --yes tzdata libpam0g-dev
```

and compile:

```bash
cargo build --release
```

Let's now log out of the container and try our binary:

```bash
$ ./target/release/su --help
Usage: su [options] [-] [<user> [<argument>...]]

Change the effective user ID and group ID to that of <user>.
A mere - implies -l.  If <user> is not given, root is assumed.
```

Voilà.

For a project with no extra dependencies we can just run cargo directly:

```bash
docker run --rm -v ./:/work rust:1.75 cargo build --release
```

## Available versions

* [Rust 1.75 (Ubuntu 24.04)](./rust/1.75-25.04/rockcraft.yaml)
* [Rust 1.85 (Ubuntu 24.04)](./rust/1.85-24.04/rockcraft.yaml)
* ~~[Rust 1.84 (Ubuntu 25.04)](./rust/1.84-25.04/rockcraft.yaml)~~ EOL
* [Rust 1.85 (Ubuntu 25.10)](./rust/1.85-25.10/rockcraft.yaml)
* [Rust 1.88 (Ubuntu 25.10)](./rust/1.88-25.10/rockcraft.yaml)
* [Rust 1.93 (Ubuntu 26.04)](./rust/1.93-26.04/rockcraft.yaml)
