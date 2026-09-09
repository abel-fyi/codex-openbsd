#!/bin/ksh
set -eu

ROOT=$(cd "$(dirname "$0")" && pwd)
PORTSDIR=${PORTSDIR:-"$ROOT/.work/ports"}
WRKOBJDIR=${WRKOBJDIR:-"$ROOT/.work/pobj"}
DISTDIR=${DISTDIR:-"$ROOT/.work/distfiles"}
PACKAGE_REPOSITORY=${PACKAGE_REPOSITORY:-"$ROOT/.work/packages"}

[ "$(uname -s)" = OpenBSD ] || {
    echo "This build recipe is for OpenBSD." >&2
    exit 1
}
[ "$(uname -r)" = 7.9 ] ||
    echo "Warning: tested on OpenBSD 7.9; review patches for $(uname -r)." >&2

for tool in git cargo cmake ninja protoc; do
    command -v "$tool" >/dev/null || {
        echo "Missing dependency: $tool (see README.md)" >&2
        exit 1
    }
done
[ -x "$ROOT/tools/gn-openbsd-amd64" ] || {
    echo "Missing tools/gn-openbsd-amd64" >&2
    exit 1
}

if [ ! -f "$PORTSDIR/infrastructure/mk/bsd.port.mk" ]; then
    mkdir -p "$(dirname "$PORTSDIR")"
    git clone --depth=1 https://github.com/openbsd/ports.git "$PORTSDIR"
fi

mkdir -p "$WRKOBJDIR" "$DISTDIR" "$PACKAGE_REPOSITORY"
echo "Building Codex; this can take many hours."
env PORTSDIR="$PORTSDIR" \
    WRKOBJDIR="$WRKOBJDIR" \
    DISTDIR="$DISTDIR" \
    PACKAGE_REPOSITORY="$PACKAGE_REPOSITORY" \
    MODCLANG_VERSION=21 \
    make -C "$ROOT/port/codex" package

find "$PACKAGE_REPOSITORY" -name 'codex-*.tgz' -print
