# Technical notes

Findings about how the original Kinesoft Windows 95 build works.

## Existing research notes

- [ph-resource-formats.md](ph-resource-formats.md) — published observations from Chris Heimlich's research about `.PH` segments, sprite encoding, backgrounds, and level entity/collision data. **Reported, not validated** against our own game files. See [sources](../research/sources.md).

- [original-media-examination.md](original-media-examination.md) — **Verified** structure of disc image MEDIA-001: single-session mixed-mode, 1 data track + 23 audio tracks.
- [disc-contents.md](disc-contents.md) — ISO 9660 contents of the data track: 40 files, with directory timestamps of 1995-08-24. All 8,880 Mode 1 sectors are reported to pass header/EDC checks (not independently reproduced).

- [executable.md](executable.md) — **Verified** PE header and static imports of `ASSETS/PITFALL.EXE`: 32-bit x86 Windows GUI program, PE timestamp field 1995-09-15 (actual build time not established); six standard Windows DLLs in its static imports (no DirectX or `WAIL32.DLL` in static imports; run-time loading untested).

- [startup-messages.md](startup-messages.md) — **Accepted by Work, 2026-10-21; Claude-reported findings reviewed by Work, not independently reproduced.** In `ASSETS/PITFALL.EXE`, the CD-ROM sentence is stored once, as the complete text of string-table entry **227**; the 256-colour warning is entry **17** (US English). This locates the stored text only. Which code uses it, and the start-up check logic, are not established.

- [startup-executables.md](startup-executables.md) — **R2.2 (final: Work's follow-up ACCEPT of the corrections in `6629328`, reviewed at `06ee277`; the first audit is recorded as "Chat 2"):** static headers and imports of `PITSTART.EXE` and `ASSETS/KILLPIT.EXE`. Both are 32-bit x86 Windows GUI programs. `PITSTART.EXE` imports 92 functions from 6 DLLs, including Video for Windows (`MSVFW32.dll`); `KILLPIT.EXE` imports 24 functions from KERNEL32 and USER32. Roles are hypotheses only.

- [wail32.md](wail32.md) — **R2.3 (accepted by Work, `aae2681`; Claude-reported; lists manually transcribed):** static headers, imports and exports of `ASSETS/WAIL32.DLL`. It is a PE32 x86 DLL with 104 named export entries (`AIL_…`, `FILE_…`, `MEM_…`; no forwarders) and 65 imports from KERNEL32, USER32 and WINMM. Not statically imported by any of the three executables; use by the game is not tested. This was the export-enabled parser's first game-file run.

## Planned technical investigations (create pages when evidence arrives)

- `install-layout.md` — what the installer puts where; files on the disc vs. on the hard drive.
- `data-formats.md` — structure of data files (graphics, levels, audio, video), described in our own words.
- `compatibility.md` — how the original behaves on Windows 10/11 today, and what breaks.

Every finding should name the inventory item (see `../inventory/`) it was observed on, and be labeled Verified / Reported / Assumption.
