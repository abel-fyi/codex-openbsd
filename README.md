# Codex 0.164.0 for OpenBSD 8.0

This repository builds Codex 0.164.0 on OpenBSD 8.0/amd64. The port has been
built and installed successfully, and `codex --version` reports
`codex-cli 0.164.0`.

The port is based on OpenBSD's `devel/codex` port, updated for the upstream
`rust-v0.164.0` tag. Its source patches and dependency metadata have been
refreshed for the V8 152.2.0 and ICU data used by this release.

## Build

The build uses the dependency graph in `port/codex/Makefile` and the OpenBSD
ports framework. By default, that framework first tries to fetch each matching
dependency package from OpenBSD's LeaseWeb CDN mirror, then builds dependencies
from source when no suitable package is available. Override `PKG_PATH` to use
another mirror. Set `FETCH_PACKAGES=No` only to disable package fetching. The
custom Codex 0.164.0 package itself is built from source. The script uses a
ports tree from the OpenBSD 8.0 `ports.tar.gz` snapshot under
`.work/ports-8.0/ports` and writes build artifacts under `.work/`. This keeps
dependency recipes aligned with the target release instead of a moving ports
branch. Override `PORTS_URL` or `PORTS_ARCHIVE` to choose a different snapshot
location or cached archive.

From the repository root on OpenBSD 8.0:

```sh
./build.sh
```

The script saves complete output to `build.log` and prints package lookups and
likely errors to the terminal. To use a different log path, set `BUILD_LOG`.
It raises the build process data limit to 8 GiB and limits Cargo to two jobs.
The login class used to launch the build must allow at least an 8 GiB data
limit. Check `ulimit -Hd`; if you adjust `/etc/login.conf`, rebuild its database
with `doas cap_mkdb /etc/login.conf` and start a fresh login session before
building. Keep comments outside backslash-continued class entries.
Watch the complete log in another terminal with:

```sh
tail -f build.log
```

## Successful OpenBSD 8.0 setup

The build was completed on OpenBSD 8.0/amd64 with the packaged LLVM
`llvm-22.1.8p10` installed. The port finds its libclang library under
`/usr/local/llvm22/lib`; the V8 152.2.0 crate itself is built from source.
Codex uses two Cargo jobs, and `build.sh` raises the data-size limit to 8 GiB.

The login class must allow that limit before the script starts. The working
`staff` settings were:

```text
:datasize-cur=8192M:
:datasize-max=infinity:
:vmemoryuse-cur=8192M:
:vmemoryuse-max=infinity:
```

After editing `/etc/login.conf`, run `doas cap_mkdb /etc/login.conf`, then
fully log out and back in. Verify the hard data limit with `ulimit -Hd`; it
must be at least `8388608` kB. Keep comments outside the backslash-continued
`staff` entry so the class parser reads these capabilities.

The OpenBSD-specific V8 patch
`patch-codex-rs_modcargo-crates_v8-152_2_0_v8_src_base_platform_platform-openbsd_cc`
adds the stack-start and reserved-limit implementations using
`pthread_stackseg_np()` from `<pthread_np.h>`. Without it, V8 failed to link on
OpenBSD.

The V8 build can run for hours. The resulting release package is kept locally
at `package/codex-0.164.0.tgz`; the large archive is ignored by Git, and its
SHA256 is recorded in `package/SHA256`. Install or replace the package with:

```sh
./install.sh package/codex-0.164.0.tgz
pkg_info -e codex-0.164.0
/usr/local/bin/codex --version
```

`install.sh` uses `doas pkg_add -D unsigned -r` for this local package: `-r`
replaces an older installed Codex version, and `-D unsigned` allows the
locally-built package, which is not signed by OpenBSD's package keys.

Then launch Codex from the directory you want it to work in with `codex`.

The NetBSD port will live in a separate repository; OpenBSD packages and
packaging scripts are specific to OpenBSD.

## Status

- [x] Update the port baseline from the OpenBSD 8.0 ports tree snapshot.
- [x] Point the Makefile and registry crate list at Codex 0.164.0.
- [x] Finish distfile checksums and sizes.
- [x] Refresh the Codex source patches for 0.164.0.
- [x] Refresh the 62 V8 152.2.0 patches; all pass a source apply check.
- [x] Check all 77 Codex, V8, and vendored crate patches against 0.164.0 sources.
- [x] Fetch and verify all declared Codex and crate distfiles.
- [x] Resolve dependencies from matching mirror packages where available; build the rest.
- [x] Build and install the package on OpenBSD 8.0; verify `codex --version`.
