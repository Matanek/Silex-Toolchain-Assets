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
SDL workflow. It verifies both the GitHub Actions artifact ZIPs and the exact
packages extracted from them.

```sh
./Scripts/prepare-shadercross.sh /path/to/downloaded/action-artifacts
```

The resulting upload directory is ignored by Git:

```text
.release/shadercross-3.0.0-e55cf5e-silex.1/
```
