#!/bin/ksh
set -eu
set -o pipefail

# Temporary 8 GiB data limit for the Codex Rust/LLVM build.
# Original data limit: ulimit -d 4194304
ulimit -d 8388608

ROOT=$(cd "$(dirname "$0")" && pwd)
BUILD_LOG=${BUILD_LOG:-"$ROOT/build.log"}
PORTSDIR_DEFAULT="$ROOT/.work/ports-8.0/ports"
PORTSDIR=${PORTSDIR:-"$PORTSDIR_DEFAULT"}
PORTSDIR_IS_DEFAULT=no
[ "$PORTSDIR" = "$PORTSDIR_DEFAULT" ] && PORTSDIR_IS_DEFAULT=yes
PORTS_ARCHIVE=${PORTS_ARCHIVE:-"$ROOT/.work/ports-8.0.tar.gz"}
PORTS_URL=${PORTS_URL:-https://mirror.leaseweb.com/pub/OpenBSD/8.0/ports.tar.gz}
WRKOBJDIR=${WRKOBJDIR:-"$ROOT/.work/pobj"}
DISTDIR=${DISTDIR:-"$ROOT/.work/distfiles"}
PACKAGE_REPOSITORY=${PACKAGE_REPOSITORY:-"$ROOT/.work/packages"}

[ "$(uname -s)" = OpenBSD ] || {
    echo "This build recipe is for OpenBSD." >&2
    exit 1
}
[ "$(uname -r)" = 8.0 ] || {
    echo "This build recipe targets OpenBSD 8.0, found $(uname -r)." >&2
    exit 1
}

for tool in ftp tar; do
    command -v "$tool" >/dev/null || {
        echo "Missing dependency: $tool (see README.md)" >&2
        exit 1
    }
done
if [ ! -f "$PORTSDIR/infrastructure/mk/bsd.port.mk" ]; then
    if [ -e "$PORTSDIR" ]; then
        echo "Refusing to replace incomplete ports tree $PORTSDIR." >&2
        exit 1
    fi
    if [ ! -f "$PORTS_ARCHIVE" ] || ! tar -tzf "$PORTS_ARCHIVE" >/dev/null 2>&1; then
        mkdir -p "$(dirname "$PORTS_ARCHIVE")"
        PORTS_PART="$PORTS_ARCHIVE.part"
        rm -f "$PORTS_PART"
        ftp -o "$PORTS_PART" "$PORTS_URL"
        tar -tzf "$PORTS_PART" >/dev/null
        mv "$PORTS_PART" "$PORTS_ARCHIVE"
    fi
    PORTS_STAGE="$ROOT/.work/ports-8.0.extract.$$"
    mkdir -p "$PORTS_STAGE" "$(dirname "$PORTSDIR")"
    tar -xzf "$PORTS_ARCHIVE" -C "$PORTS_STAGE"
    if [ ! -f "$PORTS_STAGE/ports/infrastructure/mk/bsd.port.mk" ]; then
        echo "OpenBSD 8.0 ports archive has an unexpected layout." >&2
        exit 1
    fi
    mv "$PORTS_STAGE/ports" "$PORTSDIR"
    rmdir "$PORTS_STAGE"
fi

# OpenBSD ports rejects symlinked package paths. Keep the working port as a
# real directory inside PORTSDIR and replace it from this checkout before build.
mkdir -p "$PORTSDIR/devel"
if [ -L "$PORTSDIR/devel/codex" ]; then
    rm "$PORTSDIR/devel/codex"
fi
if [ -e "$PORTSDIR/devel/codex" ]; then
    if [ "$PORTSDIR_IS_DEFAULT" != yes ]; then
        echo "Refusing to replace existing custom port path $PORTSDIR/devel/codex." >&2
        exit 1
    fi
    rm -r "$PORTSDIR/devel/codex"
fi
mkdir "$PORTSDIR/devel/codex"
cp -Rp "$ROOT/port/codex/." "$PORTSDIR/devel/codex/"

mkdir -p "$WRKOBJDIR" "$DISTDIR" "$PACKAGE_REPOSITORY" "$(dirname "$BUILD_LOG")"
PKG_REPO_ARCH=$(uname -m)
echo "Building Codex; this can take many hours."
echo "Full build output: $BUILD_LOG"
echo "Watch the full log from another terminal: tail -f $BUILD_LOG"
env PORTSDIR="$PORTSDIR" \
    FETCH_PACKAGES="${FETCH_PACKAGES-}" \
    PKG_PATH="${PKG_PATH:-https://mirror.leaseweb.com/pub/OpenBSD/%c/packages/%a}" \
    SUDO="${SUDO:-doas /usr/bin/env TRUSTED_PKG_PATH=$PACKAGE_REPOSITORY/$PKG_REPO_ARCH/all:$PACKAGE_REPOSITORY/$PKG_REPO_ARCH/no-arch}" \
    WRKOBJDIR="$WRKOBJDIR" \
    DISTDIR="$DISTDIR" \
    PACKAGE_REPOSITORY="$PACKAGE_REPOSITORY" \
    make -C "$PORTSDIR/devel/codex" package 2>&1 | tee "$BUILD_LOG" | \
    awk '/Looking for|Fatal:|Error|Broken dependency|Missing library|error:|FAILED|unsigned package|command not found/ { print; fflush() }'

find "$PACKAGE_REPOSITORY" -type f -name 'codex-0.164.0.tgz' -print
