# Third-party licenses

The license in `LICENSE` covers only the original Silex scripts, metadata,
and documentation in this repository. It does not relicense upstream
toolchain binaries published through GitHub Releases.

## Shadercross 3.0.0 release

The release identified by upstream revision
`e55cf5e31ced6f3d1be5cc6d0c50e99384f9f4ba` redistributes:

| Component | Provenance | License |
| --- | --- | --- |
| SDL3_shadercross | libsdl-org/SDL_shadercross at `e55cf5e31ced6f3d1be5cc6d0c50e99384f9f4ba` | zlib |
| SDL3 | SDL `3-head` selected by the pinned upstream workflow | zlib |
| SPIRV-Cross | KhronosGroup/SPIRV-Cross at `1a6169566c73d3da552748fc372fe2bbb856e46e` | Apache-2.0 |
| DirectX Shader Compiler, macOS | libsdl-org/DirectXShaderCompiler at `2c84a1c5ab7091608c97df6ba5ccf46e71c322eb` | see bundled DXC license and notices |
| DirectX Shader Compiler, Linux and Windows | Microsoft DXC `v1.9.2602` | see bundled DXC license and notices |
| vkd3d, macOS and Linux | Wine vkd3d 2.0, source SHA-256 `9ad29bb236808186a47ec66e853b21e6fca59b9dc62a9474b05d5e3eda2710ef` | LGPL-2.1-or-later |

The complete collected texts are stored under [`Shadercross/`](Shadercross/)
and are emitted beside every prepared release as
`THIRD_PARTY_LICENSES.txt`.

The macOS and Linux packages dynamically load separately distributed vkd3d
libraries. The corresponding, unmodified source archive is published beside
the binary archives as `vkd3d-2.0.tar.xz`.

The upstream packages also retain their internal
`share/licenses/SDL3_shadercross/LICENSE.txt` files and, where vkd3d is
present, `share/licenses/vkd3d/COPYING`.
