# Rust rock

This repository contains the SDK [rock](https://documentation.ubuntu.com/server/explanation/virtualisation/about-rock-images/) definitions for the [rust](https://www.rust-lang.org/) programming language.

This contains a minimal Rust 1.84 toolchain and Cargo build system which can be used to build a wide variety of Rust applications. It also includes a minimal GCC toolchain to custom build steps in Cargo builds.

Any additional dependencies can be either mounted at runtime or installed
with the apt installation included in this rock.

## Example

Let's build [`sudo-rs`](https://github.com/trifectatechfoundation/sudo-rs)!

First clone the repository and checkout a specific tag:

```bash
git clone --depth 1 --branch v0.2.8 https://github.com/trifectatechfoundation/sudo-rs
cd sudo-rs
```

Now lets launch the rust-rock container with the code directory mounted:

```bash
$ docker run --name=my-rust-rock --rm -it -v ./:/work rust-rock:1.84
2025-10-06T09:12:26.508Z [pebble] {"type":"security","datetime":"2025-10-06T09:12:26Z","level":"WARN","event":"sys_startup:0","description":"Starting daemon","appid":"pebble"}
2025-10-06T09:12:26.508Z [pebble] Started daemon.
2025-10-06T09:12:26.509Z [pebble] POST /v1/services 81.875µs 400 (http+unix)
2025-10-06T09:12:26.509Z [pebble] Cannot start default services: no default services
```

The rock is running, but [`pebble`](https://github.com/canonical/pebble) - the container entrypoint does not have any entry point. This is fine! This is not a rock with a service. Its for building applications. Let's now log into the container and build the application. In a separate terminal run:

```bash
docker exec -it my-rust-rock sh
```

to get a shell. Then, lets install the dependency of sudo-rs:

```bash
apt update && apt install --yes tzdata libpam0g-dev
```

and compile:

```bash
cd /work && cargo build --release
```

Let's now log out of the container and try our binary:

```bash
$ ./target/release/su --help
Usage: su [options] [-] [<user> [<argument>...]]

Change the effective user ID and group ID to that of <user>.
A mere - implies -l.  If <user> is not given, root is assumed.
```

Voilà.

## Available versions

* [Rust 1.84 (Ubuntu 25.04)](./rust-rock/1.84-25.04/rockcraft.yaml)
