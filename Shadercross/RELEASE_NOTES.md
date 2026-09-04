Prebuilt SDL Shadercross 3.0.0 toolchain packages for Silex.

Upstream revision: `e55cf5e31ced6f3d1be5cc6d0c50e99384f9f4ba`

Hosts:

- macOS arm64, using the official universal arm64/x64 package
- macOS x64, using the official universal arm64/x64 package
- Linux arm64, built natively from the pinned upstream revision
- Linux x64
- Windows x64
- Windows arm64 through the Windows x64 emulation layer

The macOS, Linux x64, and Windows packages come from the official SDL
Shadercross workflow. The Linux arm64 package is built reproducibly on a
native arm64 runner by the workflow recorded in this repository. Every
package includes the runtime libraries and licenses required by the
`shadercross` command. Silex verifies the exact asset checksum before
installation.

The release also provides `THIRD_PARTY_NOTICES.md` and
`THIRD_PARTY_LICENSES.txt` beside the binary archives. The unmodified
`vkd3d-2.0.tar.xz` source archive accompanies the LGPL-covered vkd3d
libraries distributed in the macOS and Linux packages.
