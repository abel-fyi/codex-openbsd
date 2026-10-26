#!/bin/ksh
set -eu

ROOT=$(cd "$(dirname "$0")" && pwd)
PACKAGE=${1:-$(find "$ROOT/package" "$ROOT/.work/packages" \
    -type f -name 'codex-0.164.0.tgz' 2>/dev/null | sort | tail -1)}

[ -n "$PACKAGE" ] && [ -f "$PACKAGE" ] || {
    echo "Usage: $0 /path/to/codex-0.164.0.tgz" >&2
    exit 1
}

doas pkg_add -D unsigned -r "$PACKAGE"
pkg_info -e codex-0.164.0
/usr/local/bin/codex --version
