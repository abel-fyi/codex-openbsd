# Codex 0.153.4 for OpenBSD 7.9

Reproducibility notes for the working OpenBSD/amd64 Codex backport built on
OpenBSD 7.9. The installed package contains both `codex` and
`codex-code-mode-host`, and Code Mode was tested by creating a file.

## Source

The successful build uses OpenBSD's official `-current` port:

<https://github.com/openbsd/ports/tree/master/devel/codex>

It was version 0.153.4 when tested. OpenBSD 7.9's release package was 0.121.0;
the `-current` port normally expects a matching `-current` base system.

## OpenBSD 7.9 compatibility changes

1. Use LLVM 21 because the OpenBSD 7.9 package repository does not provide the
   LLVM 22 expected by the current ports tree.
2. Use a newer GN binary with OpenBSD executable-path support because 7.9's
   packaged GN is too old for V8 150.4.0.
3. Change the generated package dependency from the current tree's Python 3.14
   to `python->=3.13`, satisfied by OpenBSD 7.9's Python 3.13.
4. Launch the installed Codex binary by absolute path. On this 7.9 system,
   Rust cannot resolve `current_exe()` when `argv[0]` is only `codex`.

The OpenBSD machine retains the exact working package and build evidence under
`~/codex-openbsd/`:

```text
package/   installable package and SHA256
port/      modified devel/codex port
patches/   port, GN, and earlier manual-build diffs
tools/     working OpenBSD GN binary
logs/      build/package logs and original error report
```

## Installed layout

```text
/usr/local/bin/codex                         absolute-path launcher
/usr/local/bin/codex-code-mode-host          package-installed host
/usr/local/libexec/codex/codex-bin           real Codex 0.153.4 binary
/usr/local/libexec/codex/codex-code-mode-host sibling host copy
```

Code Mode is enabled in `~/.codex/config.toml`:

```toml
[features]
code_mode_host = true
```

Verify with:

```sh
codex --version
codex features list | grep code_mode_host
pkg_info -e 'codex-*'
```

Expected results include `codex-cli 0.153.4`, `code_mode_host ... true`, and
`inst:codex-0.153.4`.

## Updating

Check the official `devel/codex` port in a current ports tree. Build a new
version in a disposable work tree, reapply only the compatibility changes still
needed by the installed OpenBSD release, and test both binaries before replacing
the working package. Do not copy `auth.json`, session logs, tokens, hostnames, or
other private configuration into a public repository.
