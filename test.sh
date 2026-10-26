#!/bin/ksh
set -eu

version=$(codex --version)
[ "$version" = 'codex-cli 0.164.0' ] || {
    echo "Unexpected Codex version: $version" >&2
    exit 1
}
[ -x /usr/local/bin/codex-code-mode-host ]
echo "Installed Codex 0.164.0 and code-mode host are available."
