# Technical notes

Findings about how the original Kinesoft Windows 95 build works.

## Existing research notes

- [ph-resource-formats.md](ph-resource-formats.md) — published observations from Chris Heimlich's research about `.PH` segments, sprite encoding, backgrounds, and level entity/collision data. **Reported, not validated** against our own game files. See [sources](../research/sources.md).

## Planned technical investigations (create pages when evidence arrives)

- `install-layout.md` — what the installer puts where; files on the disc vs. on the hard drive.
- `executable.md` — the main program: size, hashes, required Windows components (e.g. DirectX version), imported DLLs.
- `data-formats.md` — structure of data files (graphics, levels, audio, video), described in our own words.
- `compatibility.md` — how the original behaves on Windows 10/11 today, and what breaks.

Every finding should name the inventory item (see `../inventory/`) it was observed on, and be labeled Verified / Reported / Assumption.
