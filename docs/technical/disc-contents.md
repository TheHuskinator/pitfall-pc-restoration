# Disc contents — MEDIA-001 data track (ISO 9660 inventory)

**Date:** 2026-10-15
**Examiner:** Claude Code
**Approval:** user-approved read-only file listing (2026-10-15)
**Source image:** `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.img`, SHA-256 `EDCE93BE…E147172`. The hash was re-verified unchanged after the listing. See [materials-inventory.md](../inventory/materials-inventory.md).

## Plain-English summary

Track 1 contains a plain ISO 9660 file system labeled **`PITFALL`** with **40 files**. 39 of them sit in one folder, `ASSETS`; the other two (`AUTORUN.INF`, `PITSTART.EXE`) are at the root. The files are:
- the main program `PITFALL.EXE`;
- the audio library `WAIL32.DLL`;
- the shared data file `INIT.PH` and 24 level files `LEVEL00.PH`–`LEVEL23.PH`;
- an intro video;
- help and readme documents;
- a launcher.

Every file is dated **24 August 1995**. All 8,880 data sectors passed their built-in error check, so the data track was read without damage. Nothing was copied out of the image, opened or run.

## Method and scope

- Read-only .NET file stream over the raw image. Mode 1 user data was taken from bytes 16–2063 of each 2,352-byte sector.
- **Read:** the volume descriptors from LBA 16, then walked the directory records from the root.
- **Hashed:** each file's bytes with SHA-256 **in memory**. No file was written to disk.
- **Integrity:** checked sync, header address, mode byte and EDC (the CD-ROM sector checksum) for every sector in LBA 0–8879.
- **Not done:** file contents were not opened, parsed or interpreted (including `AUTORUN.INF`), and nothing was executed.
- The script was session-local and not committed. It ran on Windows PowerShell 5.1.26100.9444 with .NET's built-in SHA-256, plus a 6-line in-memory C# EDC helper compiled through `Add-Type`. No tools were installed.

## Findings

### Sector integrity — Verified

All **8,880 / 8,880** data-track sectors (LBA 0–8879) have valid sync, the correct header address (LBA+150), mode 1, and a **matching EDC**. This resolves D5 in [original-media-examination.md](original-media-examination.md) for the data track.

ECC (the separate error-correction parity) was not recomputed. EDC matching on every sector is strong evidence that the user data is intact.

### Volume descriptors — Verified

| Field | Value |
| --- | --- |
| Descriptors | LBA 16 = Primary (type 1); LBA 17 = terminator (type 255). **No Joliet or other supplementary descriptor**, so names are 8.3 ISO names only. |
| Volume ID | `PITFALL` |
| System / Volume set / Publisher / Preparer / Application IDs | all blank |
| Copyright / Abstract / Bibliographic file IDs | blank |
| Volume creation / modification / expiration / effective dates | all unset (zeros) |
| Volume space | 8,728 blocks × 2,048 bytes |
| Path table size | 24 bytes (root + one subdirectory) |

The highest file extent ends exactly at block 8,728, matching the volume space. Track 1 holds 8,880 sectors, so 152 sectors (8728–8879) follow the file system. That is consistent with normal end-of-track padding or postgap.

### Directory structure — Verified

- Root: `ASSETS/` (directory, extent 21), `AUTORUN.INF`, `PITSTART.EXE`.
- `ASSETS/`: 38 files.
- **Dates:** every directory and file record is dated `1995-08-24 00:01:00`, GMT offset 0. All file flags are `0x00` (no hidden, multi-extent or interleaved entries).
- **Total file bytes:** 17,792,330.

The full per-file table with sizes, extents and SHA-256 is in [materials-inventory.md](../inventory/materials-inventory.md#media-001--data-track-file-inventory).

### What the files appear to be — Assumption / inference from names and sizes only

| Group | Files | Reading | Cross-reference |
| --- | --- | --- | --- |
| Main program | `ASSETS/PITFALL.EXE` (772,608 B) | Game executable | **Matches** the S001 report that `PITFALL.EXE` is the game program |
| Launcher / autorun | `PITSTART.EXE`, `AUTORUN.INF`, `ASSETS/PITSTART.WAV` | Likely the CD autorun/launcher and its sound | — |
| Helper | `ASSETS/KILLPIT.EXE` (11,776 B) | Unknown small utility; name suggests stopping the game process | Untested guess |
| Audio library | `ASSETS/WAIL32.DLL` | Miles Sound System 32-bit library (by name) | **Matches** WAIL32.DLL listed in the request checklist |
| Shared data | `ASSETS/INIT.PH` (2,057,605 B) | Common resources | **Matches** S001 (shared sprites and embedded WAV effects; contents not yet checked) |
| Level data | `ASSETS/LEVEL00.PH`–`LEVEL23.PH` (24 files) | Level-specific resources | **Matches** S001's `LEVEL*.PH` naming. The count of 24 is newly observed here. |
| Video | `ASSETS/INTRO.AVI` (6,526,102 B) | Intro movie | — |
| Docs | `ASSETS/PITFALL0–3.HLP`, `ASSETS/TECH0–3.WRI` | Windows Help files and Write documents, four of each. Possibly four languages or variants (**unverified**). | — |

Notably:
- **No installer** (no `SETUP.EXE` or `INSTALL.EXE`) is present.
- Only one DLL is on the disc. Other dependencies (e.g. DirectX components) are **not** shipped on this disc.
- **Inference:** the game may run directly from the CD. Untested.

## What this does and does not establish

- **Does:** the data track is intact. It contains the program, data and video files that the published research describes, with consistent 1995-08-24 dates. The game's files can now be fingerprinted individually.
- **Does not:** confirm the exact retail SKU, region or revision. The volume carries no publisher or date metadata, so identifying the release still depends on comparing these file hashes with another known copy (e.g. Chris Heimlich's, if he shares them), or on product markings on the physical disc.
- The audio tracks were not examined further in this task.

## Open questions

1. Does the user's physical disc or box show a catalog number, region or version marking? Comparing it with this inventory could confirm the release.
2. Is the four-way `.HLP`/`.WRI` set language variants? This needs content inspection, which is a later, separately approved task.
3. Which external Windows components does `PITFALL.EXE` import? This is executable analysis, which is a later, separately approved task.
