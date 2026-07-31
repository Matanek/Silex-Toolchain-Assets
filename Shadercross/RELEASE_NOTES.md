Prebuilt SDL Shadercross 3.0.0 toolchain packages for Silex.

Upstream revision: `e55cf5e31ced6f3d1be5cc6d0c50e99384f9f4ba`

Hosts:

- macOS arm64, using the official universal arm64/x64 package
- Linux x64
- Windows x64
- Windows arm64 through the Windows x64 emulation layer

The packages come from the official SDL Shadercross workflow and include the
runtime libraries and licenses required by the `shadercross` command. Silex
verifies the exact asset checksum before installation.
