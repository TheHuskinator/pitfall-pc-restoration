# Disc contents — MEDIA-001 data track (ISO 9660 inventory)

**Date:** 2026-10-15
**Examiner:** Claude Code
**Approval:** user-approved read-only file listing (2026-10-15)
**Source image:** `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.img`, SHA-256 `EDCE93BE…E147172`. The hash was re-verified unchanged after the listing. See [materials-inventory.md](../inventory/materials-inventory.md).

## Plain-English summary

Track 1 contains a plain ISO 9660 file system labeled **`PITFALL`** with **40 files**. 38 of them sit in one folder, `ASSETS`; the other two (`AUTORUN.INF`, `PITSTART.EXE`) are at the root. The files are:
- the main program `PITFALL.EXE`;
- the audio library `WAIL32.DLL`;
- the shared data file `INIT.PH` and 24 level files `LEVEL00.PH`–`LEVEL23.PH`;
- an intro video;
- help and readme documents;
- a launcher.

Every file record carries the date **24 August 1995** (directory metadata, not a verified manufacturing or release date). All 8,880 Mode 1 sectors passed their header and built-in error (EDC) checks. That is strong evidence of internal consistency, but it does not prove the image is bit-identical to an original disc, authentic, or complete. Nothing was copied out of the image, opened or run.

## Method and scope

- Read-only .NET file stream over the raw image. Mode 1 user data was taken from bytes 16–2063 of each 2,352-byte sector.
- **Read:** the volume descriptors from LBA 16, then walked the directory records from the root.
- **Hashed:** each file's bytes with SHA-256 **in memory**. No file was written to disk.
- **Integrity:** checked sync, header address, mode byte and EDC (the CD-ROM sector checksum) for every sector in LBA 0–8879.
- **Not done:** file contents were not opened, parsed or interpreted (including `AUTORUN.INF`), and nothing was executed.
- The script was session-local and not committed. It ran on Windows PowerShell 5.1.26100.9444 (.NET CLR 4.0.30319.42000) with .NET's built-in SHA-256, plus a 6-line in-memory C# EDC helper compiled through `Add-Type`. No tools were installed.

### EDC algorithm (for reproduction)

| Parameter | Value |
| --- | --- |
| Algorithm | CD-ROM EDC, a 32-bit CRC (catalogued as CRC-32/CD-ROM-EDC) |
| Polynomial | `0x8001801B` (normal form); `0xD8018001` reflected, as used in the table-driven code below |
| Input / output reflection | Reflected / reflected (processed least-significant bit first) |
| Initial value | `0x00000000` |
| Final XOR | `0x00000000` |
| Byte range (Mode 1) | Raw-sector bytes 0–2063: sync, header and 2,048 user-data bytes |
| Stored value | Raw-sector bytes 2064–2067, little-endian `UInt32` |
| Pass condition | Computed value equals stored value |
| Known test vector | ASCII `123456789` → `0x6EC2EDC4`. Re-run on 2026-10-15 with the same helper code, without the disc image, and it produced exactly this value. That value matches the published check value in Greg Cook's *Catalogue of parametrised CRC algorithms* (CRC RevEng, <https://reveng.sourceforge.io/crc-catalogue/all.htm>, entry CRC-32/CD-ROM-EDC; **Reported**, catalogue not re-fetched today). |

Helper code as run (C#, compiled in memory through `Add-Type`):

```csharp
public static class Edc {
    static readonly uint[] T = Build();
    static uint[] Build() { var t = new uint[256]; for (uint i = 0; i < 256; i++) { uint e = i; for (int k = 0; k < 8; k++) e = (e >> 1) ^ ((e & 1) != 0 ? 0xD8018001u : 0u); t[i] = e; } return t; }
    public static uint Compute(byte[] b, int len) { uint e = 0; for (int i = 0; i < len; i++) e = (e >> 8) ^ T[(e ^ b[i]) & 0xFF]; return e; }
}
// Per sector: Edc.Compute(raw, 2064) == BitConverter.ToUInt32(raw, 2064)
```

Limitation: the full listing script is not in the repository. The aggregate 8,880/8,880 result has therefore not been reproduced by an independent party. Committing a reviewed, read-only verifier script would make it reproducible; that needs separate user approval.

## Findings

### Sector integrity — Verified

Examiner-reported result: all **8,880 / 8,880** Mode 1 sectors (LBA 0–8879) have valid sync, the correct header address (LBA+150), mode byte 1, and a **matching EDC**.

Limits of this result:
- **Coverage:** the CCD/CUE assign 9,030 sectors (LBA 0–9029) to track 1. The remaining 150 sectors (8880–9029) are zero-filled, carry no Mode 1 header, and were **not** EDC-checked. See D2 in [original-media-examination.md](original-media-examination.md).
- **What it shows:** strong internal-consistency evidence for the user data in those 8,880 sectors.
- **What it does not show:** bit-perfect equivalence to the original disc, the physical read-error history of the dump, or release authenticity.
- **ECC** (the separate error-correction parity) was not validated.
- **Independent reproduction:** the result has not been independently reproduced. See *EDC algorithm* above.

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
- **Dates:** every directory and file record is dated `1995-08-24 00:01:00`, GMT offset 0. These are ISO directory-record timestamps written when the disc was mastered. They are not independently verified manufacturing or release dates.
- **Flags:**
  - All 40 **file** records have flags `0x00`, meaning no hidden, multi-extent or interleaved entries.
  - The `ASSETS` **directory** record has the directory bit (`0x02`) set. This is inferred from the directory walk descending into it; the full flag byte for that record was not printed.
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
- **No conventionally named installer** (e.g. `SETUP.EXE`, `INSTALL.EXE`) was identified among the 40 files. A differently named program, such as `PITSTART.EXE`, could still perform installation. Installation and launcher behavior were **not tested**.
- `WAIL32.DLL` is the only file with a `.DLL` extension. The game's external dependencies (e.g. Windows or DirectX components, or libraries loaded at run time) **remain unknown**. Determining them requires executable analysis.
- **Hypothesis (untested):** the game may run directly from the CD.

## What this does and does not establish

- **Does:**
  - Every Mode 1 sector passed the header and EDC checks, so the data track is internally consistent.
  - Its file system lists the program, data and video files that the published research describes, with consistent 1995-08-24 directory timestamps.
  - The game's files can now be fingerprinted individually.
- **Does not:** confirm the exact retail SKU, region or revision. The volume carries no publisher or date metadata, so identifying the release still depends on comparing these file hashes with another known copy (e.g. Chris Heimlich's, if he shares them), or on product markings on the physical disc.
- The audio tracks were not examined further in this task.

## Open questions

1. Does the user's physical disc or box show a catalog number, region or version marking? Comparing it with this inventory could confirm the release.
2. Is the four-way `.HLP`/`.WRI` set language variants? This needs content inspection, which is a later, separately approved task.
3. Which external Windows components does `PITFALL.EXE` import? This is executable analysis, which is a later, separately approved task.
