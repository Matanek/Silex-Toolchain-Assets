#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <official-action-artifact-directory>" >&2
    exit 1
fi

input_dir=$1
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tag=shadercross-3.0.0-e55cf5e-silex.2
output_dir=$repository_root/.release/$tag
licenses_dir=$repository_root/Licenses/Shadercross
third_party_notices_source=$repository_root/Licenses/README.md

macos_input=$input_dir/SDL3_shadercross-macos-arm64.zip
linux_input=$input_dir/SDL3_shadercross-linux-x64.zip
windows_input=$input_dir/SDL3_shadercross-VC-x64.zip

macos_asset=$output_dir/Shadercross-3.0.0-e55cf5e-macos-universal.tar.gz
linux_asset=$output_dir/Shadercross-3.0.0-e55cf5e-linux-x64.tar.gz
windows_asset=$output_dir/Shadercross-3.0.0-e55cf5e-windows-x64.zip
vkd3d_source_asset=$output_dir/vkd3d-2.0.tar.xz
third_party_notices_asset=$output_dir/THIRD_PARTY_NOTICES.md
third_party_licenses_asset=$output_dir/THIRD_PARTY_LICENSES.txt
vkd3d_source_url=https://dl.winehq.org/vkd3d/source/vkd3d-2.0.tar.xz

checksum() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    else
        shasum -a 256 "$1" | cut -d ' ' -f 1
    fi
}

verify() {
    expected=$1
    file=$2
    actual=$(checksum "$file")
    if [ "$actual" != "$expected" ]; then
        echo "checksum mismatch: $file" >&2
        echo "expected: $expected" >&2
        echo "actual:   $actual" >&2
        exit 1
    fi
}

require_tar_entry() {
    archive=$1
    entry=$2
    if ! tar -tzf "$archive" | grep -Fqx "$entry"; then
        echo "missing license entry: $entry in $archive" >&2
        exit 1
    fi
}

require_zip_entry() {
    archive=$1
    entry=$2
    if ! unzip -Z1 "$archive" | grep -Fqx "$entry"; then
        echo "missing license entry: $entry in $archive" >&2
        exit 1
    fi
}

verify 8d320666f565bbeb2ae0871856157301c6137dbeb35ec52d481d60f75c0d39c5 "$macos_input"
verify 892981243a72dd52ca72509beebf3b38fbbf16857a61fe9573e05d3428e5748b "$linux_input"
verify d5d290630ad9b03210c2cb4cbd2d0698c16feee12b08521d78435343924f5a25 "$windows_input"

mkdir -p "$output_dir"
unzip -p "$macos_input" SDL3_shadercross-3.0.0-darwin-arm64-x64.tar.gz > "$macos_asset"
unzip -p "$linux_input" SDL3_shadercross-3.0.0-linux-x64.tar.gz > "$linux_asset"
unzip -p "$windows_input" SDL3_shadercross-3.0.0-windows-VC-x64.zip > "$windows_asset"

verify a92bfbbdf10c3065976fb41d1b561a82f5c6f78203f9805aabf00b12dd517c2b "$macos_asset"
verify 252de380a0a4c6b5479419be3e4f00e419805fc99a41bae840096f0708ce3e15 "$linux_asset"
verify c11ce40504040237ee786d2a2406446881d6daaf3b34e1a08d90f7fa459d5f0d "$windows_asset"

require_tar_entry "$macos_asset" "SDL3_shadercross-3.0.0-darwin-arm64-x64/share/licenses/SDL3_shadercross/LICENSE.txt"
require_tar_entry "$macos_asset" "SDL3_shadercross-3.0.0-darwin-arm64-x64/share/licenses/vkd3d/COPYING"
require_tar_entry "$linux_asset" "SDL3_shadercross-3.0.0-linux-x64/share/licenses/SDL3_shadercross/LICENSE.txt"
require_tar_entry "$linux_asset" "SDL3_shadercross-3.0.0-linux-x64/share/licenses/vkd3d/COPYING"
require_zip_entry "$windows_asset" "SDL3_shadercross-3.0.0-windows-VC-x64/share/licenses/SDL3_shadercross/LICENSE.txt"

if [ ! -f "$vkd3d_source_asset" ]; then
    command -v curl >/dev/null 2>&1 || {
        echo "curl is required to obtain the corresponding vkd3d source" >&2
        exit 1
    }
    curl --fail --location "$vkd3d_source_url" --output "$vkd3d_source_asset"
fi
verify 9ad29bb236808186a47ec66e853b21e6fca59b9dc62a9474b05d5e3eda2710ef "$vkd3d_source_asset"

cp "$third_party_notices_source" "$third_party_notices_asset"
{
    for license in \
        SDL3.txt \
        SDL3_shadercross.txt \
        SPIRV-Cross.txt \
        DirectXShaderCompiler.txt \
        DirectXShaderCompiler-ThirdPartyNotices.txt \
        LGPL-2.1.txt \
        vkd3d.txt
    do
        echo "======================================================================"
        echo "$license"
        echo "======================================================================"
        echo
        cat "$licenses_dir/$license"
        echo
    done
} > "$third_party_licenses_asset"

cp "$repository_root/Shadercross/RELEASE_NOTES.md" "$output_dir/RELEASE_NOTES.md"

{
    echo "252de380a0a4c6b5479419be3e4f00e419805fc99a41bae840096f0708ce3e15  $(basename "$linux_asset")"
    echo "a92bfbbdf10c3065976fb41d1b561a82f5c6f78203f9805aabf00b12dd517c2b  $(basename "$macos_asset")"
    echo "c11ce40504040237ee786d2a2406446881d6daaf3b34e1a08d90f7fa459d5f0d  $(basename "$windows_asset")"
    echo "$(checksum "$third_party_licenses_asset")  $(basename "$third_party_licenses_asset")"
    echo "$(checksum "$third_party_notices_asset")  $(basename "$third_party_notices_asset")"
    echo "9ad29bb236808186a47ec66e853b21e6fca59b9dc62a9474b05d5e3eda2710ef  $(basename "$vkd3d_source_asset")"
} > "$output_dir/SHA256SUMS.txt"

echo "prepared: $output_dir"
