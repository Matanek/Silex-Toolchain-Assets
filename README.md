# Silex Toolchain Assets

This repository records the provenance and preparation of prebuilt tools used
by the Silex installation. Binary archives are published as GitHub Release
assets and are never committed to Git.

End users do not clone this repository. The Silex installer downloads the
archive for the host, verifies its SHA-256 digest, and installs it under
`~/.silex/toolchain/`.

## Shadercross

The first tool is the official SDL Shadercross command used by Silex to compile
the standard HLSL shader source into the format selected for the GPU backend.

- Source and release metadata: [`Shadercross/Manifest.json`](Shadercross/Manifest.json)
- Release notes: [`Shadercross/RELEASE_NOTES.md`](Shadercross/RELEASE_NOTES.md)
- Preparation script: [`Scripts/prepare-shadercross.sh`](Scripts/prepare-shadercross.sh)

The preparation script imports the packages produced by the pinned official
SDL workflow and the native Linux arm64 package produced by this repository.
It verifies the GitHub Actions inputs and every exact package included in the
release candidate.

The manifest names every Silex desktop target explicitly. macOS ARM64 and x64
share one verified universal archive, Windows ARM64 declares its use of the
published x64 compatibility tool, and Linux keeps distinct native ARM64 and
x64 archives.

```sh
./Scripts/prepare-shadercross.sh /path/to/downloaded/action-artifacts
```

The resulting upload directory is ignored by Git:

```text
.release/shadercross-3.0.0-e55cf5e-silex.3/
```

The prepared release also contains:

- `THIRD_PARTY_NOTICES.md`, identifying every redistributed component;
- `THIRD_PARTY_LICENSES.txt`, containing the corresponding license texts;
- the exact vkd3d source archive required for the LGPL-covered libraries.

## License

The original scripts and metadata in this repository are licensed under the
Apache License 2.0 with LLVM Exceptions
(`Apache-2.0 WITH LLVM-exception`). See [LICENSE](LICENSE) and [NOTICE](NOTICE).

This license does not cover the upstream binaries published as release assets.
Those binaries remain subject to the terms recorded in
[Licenses/README.md](Licenses/README.md).
