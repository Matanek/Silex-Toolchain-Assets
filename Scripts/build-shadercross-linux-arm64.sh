#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <Shadercross-source-directory> <SDL-prefix> <output-directory>" >&2
    exit 2
fi

source_dir="$(cd -- "$1" && pwd)"
sdl_prefix="$(cd -- "$2" && pwd)"
output_dir="$3"
expected_revision="e55cf5e31ced6f3d1be5cc6d0c50e99384f9f4ba"

actual_revision="$(git -C "$source_dir" rev-parse HEAD)"
if [[ "$actual_revision" != "$expected_revision" ]]; then
    echo "expected Shadercross revision $expected_revision, got $actual_revision" >&2
    exit 1
fi
case "$(uname -m)" in
    aarch64|arm64) ;;
    *) echo "Shadercross Linux ARM64 must be built on a native ARM64 host" >&2; exit 1 ;;
esac

build_root="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/silex-shadercross-linux-arm64"
build_dir="$build_root/build"
prefix_dir="$build_root/prefix"
stage_dir="$build_root/stage"
package_root="$stage_dir/SDL3_shadercross-3.0.0-linux-arm64"
output="$output_dir/Shadercross-3.0.0-e55cf5e-linux-arm64.tar.gz"

rm -rf -- "$build_root"
mkdir -p "$output_dir"

export SOURCE_DATE_EPOCH=1788220800
export TZ=UTC

cmake -S "$source_dir" -B "$build_dir" -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix_dir" \
    -DCMAKE_PREFIX_PATH="$sdl_prefix" \
    -DSDLSHADERCROSS_CLI=ON \
    -DSDLSHADERCROSS_CLI_STATIC=OFF \
    -DSDLSHADERCROSS_DXC=ON \
    -DSDLSHADERCROSS_INSTALL=ON \
    -DSDLSHADERCROSS_INSTALL_CPACK=OFF \
    -DSDLSHADERCROSS_INSTALL_RUNTIME=ON \
    -DSDLSHADERCROSS_SHARED=ON \
    -DSDLSHADERCROSS_STATIC=ON \
    -DSDLSHADERCROSS_TESTS=OFF \
    -DSDLSHADERCROSS_VENDORED=ON
cmake --build "$build_dir" --config Release --parallel 4
cmake --install "$build_dir" --config Release

file "$prefix_dir/bin/shadercross"
file "$prefix_dir/bin/shadercross" | grep -Eq 'ARM aarch64|ARM64|aarch64'
printf '%s\n' \
    'float4 main(float4 position : POSITION) : SV_Position {' \
    '    return position;' \
    '}' > "$build_root/portable.vert.hlsl"
LD_LIBRARY_PATH="$prefix_dir/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    "$prefix_dir/bin/shadercross" "$build_root/portable.vert.hlsl" \
        --source HLSL --dest SPIRV --stage vertex --entrypoint main \
        --output "$build_root/portable.vert.spv"
test -s "$build_root/portable.vert.spv"

mkdir -p "$package_root"
cp -a "$prefix_dir/." "$package_root/"
find "$package_root" -exec touch -h -d "@$SOURCE_DATE_EPOCH" {} +
LC_ALL=C tar \
    --sort=name \
    --format=gnu \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    --mtime="@$SOURCE_DATE_EPOCH" \
    -C "$stage_dir" \
    -cf - SDL3_shadercross-3.0.0-linux-arm64 | gzip -n -9 > "$output"

contents="$build_root/archive-contents.txt"
tar -tzf "$output" > "$contents"
grep -Fqx 'SDL3_shadercross-3.0.0-linux-arm64/bin/shadercross' "$contents"
grep -Fqx 'SDL3_shadercross-3.0.0-linux-arm64/share/licenses/SDL3_shadercross/LICENSE.txt' "$contents"
grep -Fqx 'SDL3_shadercross-3.0.0-linux-arm64/share/licenses/vkd3d/COPYING' "$contents"
sha256sum "$output"
