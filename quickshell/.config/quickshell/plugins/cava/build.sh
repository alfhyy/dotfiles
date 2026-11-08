#!/bin/sh
# Build + install the Cava QML module. Re-run after a major Qt/Quickshell upgrade.
set -e
src=$(dirname "$(realpath "$0")")
build=${XDG_CACHE_HOME:-$HOME/.cache}/qs-cava-build
cmake -S "$src" -B "$build" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "$build"
cmake --install "$build" --prefix "$HOME/.local/lib/qt6/qml"
