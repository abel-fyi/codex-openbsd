#!/bin/ksh
set -eu

ROOT=$(cd "$(dirname "$0")" && pwd)
PACKAGE=${1:-$(find "$ROOT/.work/packages" "$ROOT/package" \
    -name 'codex-*.tgz' 2>/dev/null | sort | tail -1)}

[ -n "$PACKAGE" ] && [ -f "$PACKAGE" ] || {
    echo "Usage: $0 /path/to/codex-VERSION.tgz" >&2
    exit 1
}

doas pkg_add -D unsigned "$PACKAGE"

# OpenBSD 7.9 cannot resolve current_exe() when argv[0] is only "codex".
doas install -d -o root -g bin -m 755 /usr/local/libexec/codex
doas install -o root -g bin -m 755 /usr/local/bin/codex \
    /usr/local/libexec/codex/codex-bin
doas install -o root -g bin -m 755 /usr/local/bin/codex-code-mode-host \
    /usr/local/libexec/codex/codex-code-mode-host

tmp=$(mktemp /tmp/codex-launcher.XXXXXXXXXX)
trap 'rm -f "$tmp"' EXIT
printf '%s\n' '#!/bin/sh' \
    'exec /usr/local/libexec/codex/codex-bin "$@"' >"$tmp"
chmod 755 "$tmp"
doas install -o root -g bin -m 755 "$tmp" /usr/local/bin/codex

codex features enable code_mode_host
echo "Installed $(codex --version)"
