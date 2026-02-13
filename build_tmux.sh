#!/bin/sh
set -eu

# -----------------------------
# Config
# -----------------------------
OPT_DIR="$HOME/opt"
PREFIX="$HOME/.local"

LIBEVENT_REPO="$OPT_DIR/libevent"
TMUX_REPO="$OPT_DIR/tmux"

# You can change these tags if needed
LIBEVENT_TAG="release-2.1.12-stable"
TMUX_TAG="3.6a"

# Set to 1 if you want to build your own libevent
# even when system libevent exists.
FORCE_LOCAL_LIBEVENT="${FORCE_LOCAL_LIBEVENT:-0}"

# -----------------------------
# Helpers
# -----------------------------
log() { printf '%s\n' "==> $*" >&2; }
die() { printf '%s\n' "ERROR: $*" >&2; exit 1; }

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

nproc_fallback() {
    getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4
}

# -----------------------------
# Preflight
# -----------------------------
need_cmd git
need_cmd cmake
need_cmd make
need_cmd cc

mkdir -p "$OPT_DIR" "$PREFIX"

# Prefer local prefix for builds (safe even if empty)
export PATH="$PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export CPPFLAGS="-I$PREFIX/include ${CPPFLAGS:-}"
export LDFLAGS="-L$PREFIX/lib ${LDFLAGS:-}"
export LD_LIBRARY_PATH="$PREFIX/lib:${LD_LIBRARY_PATH:-}"

# -----------------------------
# Check system libevent
# -----------------------------
have_system_libevent=0
if command -v pkg-config >/dev/null 2>&1; then
    if pkg-config --exists libevent; then
        have_system_libevent=1
    fi
fi

if [ "$FORCE_LOCAL_LIBEVENT" -eq 1 ]; then
    log "FORCE_LOCAL_LIBEVENT=1 set, will build local libevent."
    have_system_libevent=0
fi

# We'll use this to decide tmux static flag
use_local_libevent=0

# -----------------------------
# Build & install libevent (local) if needed
# -----------------------------
build_libevent() {
    log "Cloning libevent into $LIBEVENT_REPO"
    if [ ! -d "$LIBEVENT_REPO/.git" ]; then
        git clone https://github.com/libevent/libevent.git "$LIBEVENT_REPO"
    fi

    cd "$LIBEVENT_REPO"
    git fetch --tags

    if git rev-parse "$LIBEVENT_TAG" >/dev/null 2>&1; then
        git checkout "$LIBEVENT_TAG"
    else
        log "Tag $LIBEVENT_TAG not found, staying on current branch."
    fi

    mkdir -p build
    cd build

    log "Configuring libevent with CMake prefix=$PREFIX"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX"

    log "Building libevent"
    cmake --build . -j"$(nproc_fallback)"

    log "Installing libevent to $PREFIX"
    cmake --install .
}

if [ "$have_system_libevent" -eq 1 ]; then
    ver="$(pkg-config --modversion libevent 2>/dev/null || echo unknown)"
    log "System libevent found via pkg-config: $ver"
    log "Skipping local libevent build."
    use_local_libevent=0
else
    log "System libevent not found (or forced local build). Building local libevent..."
    build_libevent
    use_local_libevent=1
fi

# Re-export in case libevent was just installed
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export CPPFLAGS="-I$PREFIX/include ${CPPFLAGS:-}"
export LDFLAGS="-L$PREFIX/lib ${LDFLAGS:-}"
export LD_LIBRARY_PATH="$PREFIX/lib:${LD_LIBRARY_PATH:-}"

# -----------------------------
# Build & install tmux
# -----------------------------
build_tmux() {
    log "Cloning tmux into $TMUX_REPO"
    if [ ! -d "$TMUX_REPO/.git" ]; then
        git clone https://github.com/tmux/tmux.git "$TMUX_REPO"
    fi

    cd "$TMUX_REPO"
    git fetch --tags

    if git rev-parse "$TMUX_TAG" >/dev/null 2>&1; then
        git checkout "$TMUX_TAG"
    else
        log "Tag $TMUX_TAG not found, staying on current branch."
    fi

    # tmux repo usually needs autogen for git builds
    if [ -x "./autogen.sh" ]; then
        log "Running autogen.sh"
        ./autogen.sh
    fi

    TMUX_STATIC_FLAG=""
    if [ "$use_local_libevent" -eq 1 ]; then
        TMUX_STATIC_FLAG="--enable-static"
        log "Using local libevent -> enabling tmux static build flag."
    else
        log "Using system libevent -> NOT enabling tmux static build flag."
    fi

    log "Configuring tmux prefix=$PREFIX"
    if [ -n "$TMUX_STATIC_FLAG" ]; then
        ./configure --prefix="$PREFIX" "$TMUX_STATIC_FLAG"
    else
        ./configure --prefix="$PREFIX"
    fi

    log "Building tmux"
    make -j"$(nproc_fallback)"

    log "Installing tmux to $PREFIX"
    make install
}

build_tmux

# -----------------------------
# Post-check
# -----------------------------
log "Done."
log "tmux path: $(command -v tmux || echo not found)"
log "tmux version: $(tmux -V 2>/dev/null || echo unknown)"

cat <<EOF

Notes:
1) If you WANT to build local libevent even when system has it:
   FORCE_LOCAL_LIBEVENT=1 sh $0

2) Ensure your shell picks up local tmux first:
   export PATH="$HOME/.local/bin:\$PATH"

3) If runtime complains about libevent .so (when using local libevent):
   export LD_LIBRARY_PATH="$HOME/.local/lib:\$LD_LIBRARY_PATH"
EOF
