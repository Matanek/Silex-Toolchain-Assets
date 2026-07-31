#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <official-action-artifact-directory>" >&2
    exit 1
fi

input_dir=$1
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tag=shadercross-3.0.0-e55cf5e-silex.1
output_dir=$repository_root/.release/$tag

macos_input=$input_dir/SDL3_shadercross-macos-arm64.zip
linux_input=$input_dir/SDL3_shadercross-linux-x64.zip
windows_input=$input_dir/SDL3_shadercross-VC-x64.zip

macos_asset=$output_dir/Shadercross-3.0.0-e55cf5e-macos-universal.tar.gz
linux_asset=$output_dir/Shadercross-3.0.0-e55cf5e-linux-x64.tar.gz
windows_asset=$output_dir/Shadercross-3.0.0-e55cf5e-windows-x64.zip

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

{
    echo "252de380a0a4c6b5479419be3e4f00e419805fc99a41bae840096f0708ce3e15  $(basename "$linux_asset")"
    echo "a92bfbbdf10c3065976fb41d1b561a82f5c6f78203f9805aabf00b12dd517c2b  $(basename "$macos_asset")"
    echo "c11ce40504040237ee786d2a2406446881d6daaf3b34e1a08d90f7fa459d5f0d  $(basename "$windows_asset")"
} > "$output_dir/SHA256SUMS.txt"

cp "$repository_root/Shadercross/RELEASE_NOTES.md" "$output_dir/RELEASE_NOTES.md"
echo "prepared: $output_dir"
