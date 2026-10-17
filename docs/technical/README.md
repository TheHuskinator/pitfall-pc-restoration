# Technical notes

Findings about how the original Kinesoft Windows 95 build works.

## Existing research notes

- [ph-resource-formats.md](ph-resource-formats.md) — published observations from Chris Heimlich's research about `.PH` segments, sprite encoding, backgrounds, and level entity/collision data. **Reported, not validated** against our own game files. See [sources](../research/sources.md).

- [original-media-examination.md](original-media-examination.md) — **Verified** structure of disc image MEDIA-001: single-session mixed-mode, 1 data track + 23 audio tracks.
- [disc-contents.md](disc-contents.md) — ISO 9660 contents of the data track: 40 files, with directory timestamps of 1995-08-24. All 8,880 Mode 1 sectors are reported to pass header/EDC checks (not independently reproduced).

- [executable.md](executable.md) — **Verified** PE header and static imports of `ASSETS/PITFALL.EXE`: 32-bit x86 Windows GUI program, PE timestamp field 1995-09-15 (actual build time not established); six standard Windows DLLs in its static imports (no DirectX or `WAIL32.DLL` in static imports; run-time loading untested).

- [startup-executables.md](startup-executables.md) — **R2.2 (Chat 2: Accept with corrections; corrections pending review):** static headers and imports of `PITSTART.EXE` and `ASSETS/KILLPIT.EXE`. Both are 32-bit x86 Windows GUI programs. `PITSTART.EXE` imports 92 functions from 6 DLLs, including Video for Windows (`MSVFW32.dll`); `KILLPIT.EXE` imports 24 functions from KERNEL32 and USER32. Roles are hypotheses only.

## Planned technical investigations (create pages when evidence arrives)

- `install-layout.md` — what the installer puts where; files on the disc vs. on the hard drive.
- `data-formats.md` — structure of data files (graphics, levels, audio, video), described in our own words.
- `compatibility.md` — how the original behaves on Windows 10/11 today, and what breaks.

Every finding should name the inventory item (see `../inventory/`) it was observed on, and be labeled Verified / Reported / Assumption.
