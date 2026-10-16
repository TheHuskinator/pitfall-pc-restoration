# Original media examination — candidate CD image set (MEDIA-001)

**Inspection date:** 2026-10-15 (America/Chicago; UTC 2026-10-16 02:17 at start)
**Examiner:** Claude Code (primary technical agent)
**Prepared for:** ChatGPT Chat 2 (research / technical-claim review)
**Status:** Read-only structural examination complete. **Internally consistent ≠ authentic or complete.** Nothing in this report establishes release, region, revision, provenance or permission for use.

## Plain-English summary

The four files form a clean, self-consistent **CloneCD-style raw disc image** made up of an image file (`.img`), a subchannel file (`.sub`), and two text descriptors (`.ccd`, `.cue`). The two descriptors agree with each other and with the image file sizes, sector for sector. They describe **one session with 24 tracks**:
- track 1 is a computer data track;
- tracks 2–24 are declared as standard CD audio.

This is the classic "mixed-mode" layout used by mid-90s PC games that played their music straight from the CD. Sampled data sectors have correct headers, and sampled audio sectors contain non-silent sample data, so the audio area is not blank. The one notable oddity is that neither descriptor declares the silent gap before track 2, although the subchannel data does. We have not listened to, decoded, error-checked or authenticated anything, and we do not know where this image came from.

---

## 1. Objective, scope and baseline

**Objective:** determine whether the four files are a structurally consistent disc-image set, what track/session layout they describe, and whether both data and possible CD audio appear to be preserved.

**In scope (done):** file metadata, full-file SHA-256 (before and after), descriptor text parsing, arithmetic, bounded reads of sector headers and Q-subchannel fields at documented positions.

**Out of scope (not done):** mounting, extraction, file-system listing, executable/resource analysis, audio playback/export, error-correction (EDC/ECC) checks, Q-channel CRC validation, tool installation, compatibility testing.

| Baseline item | Value (verified observation) |
| --- | --- |
| Repository | `C:\Users\jrsee\Documents\GitHub\pitfall-pc-restoration` |
| Branch / HEAD | `main` @ `0773dedbeaf666f7c32dfcd3f572d35e13223dea` (equals the reviewed instruction baseline; `git merge-base --is-ancestor` exit 0) |
| Remote sync | Local HEAD equals the **cached** `origin/main`. No fetch was performed (command-line git cannot authenticate), so this does **not** prove the live GitHub state. |
| Initial working tree | Clean (`git status --short --untracked-files=all` produced no output) |
| `AGENTS.md` | None found in the repository |
| `sources/` folder | Does not exist |
| OS | Microsoft Windows 11 Home 10.0.26200 (build 26200) |
| Shell / runtime | Windows PowerShell 5.1.26100.9444; .NET CLR 4.0.30319.42000 |
| Git | 2.53.0.windows.4 at `%LOCALAPPDATA%\GitHubDesktop\app-3.6.7\resources\app\git\cmd\git.exe` (not on PATH; `CLAUDE.md` note still accurate) |
| Tools used | Built-in PowerShell cmdlets (`Get-Item`, `Get-FileHash`, `Get-ChildItem`) and .NET `System.IO.File.Open(..., FileMode.Open, FileAccess.Read, FileShare.Read)`. No third-party tools. |

**Git exclusion (verified):** `git check-ignore -v --` reported rule `.gitignore:12:/private/` for all four files at their actual paths. `git ls-files -- private` returned nothing, and every tracked file is Markdown or `.gitignore`. No proprietary files are tracked.

## 2. Four-file inventory

> **Path discrepancy (verified; resolved 2026-10-15):** The assignment and `CLAUDE.md` named `private/original-media/Pitfall.*`. The files actually live one level deeper, in `private/original-media/Pitfall_The_Mayan_Adventure_ISO/`. The examination used the actual paths, and no file was moved or renamed. After the examination, the user confirmed the subfolder as the canonical location, and `CLAUDE.md` was updated to match.

All four are regular local files (no link/junction; attribute `Archive` only; not read-only). Paths are relative to the repository root.

| File | Bytes | Last write (UTC) | SHA-256 |
| --- | ---: | --- | --- |
| `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.img` | 640,480,176 | 2007-03-31 22:33:22 | `EDCE93BEAEB97DDEFE703A756C498B9533206213B50EA34550F470E1CE147172` |
| `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.sub` | 26,142,048 | 2007-03-31 22:33:22 | `36DEFDCE92B9B6A79328645E45F93A7EAF35DB08B2D7C343324CE4AA40F9F73B` |
| `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.ccd` | 5,510 | 2007-03-31 22:33:16 | `034C26F37CF7BE2ECA8EC20F9B42944332AA3F7DA572705A59EAD0903DD37ACC` |
| `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.cue` | 1,445 | 2007-03-31 22:33:16 | `DC08B707EBBF531FEF4E52954B0D5DCCDF55802FE053FED8274F3E8A0545AF28` |

- **Provenance — Reported (user, 2026-10-15, after the examination):** the image was made from a legitimate physical copy of the game that the user owned. The files themselves cannot confirm this. Who made the image, with which software, and on what date have not been stated.
- **Assumption / inference:** the 2007 timestamps, plus a folder dated 2016-11-30 and named `..._ISO`, are consistent with the image being created around 2007. Filesystem timestamps can be altered or preserved by copying, so this is weak evidence.
- **Preservation (verified):** all four SHA-256 hashes, sizes and timestamps were recomputed at the end of the session and were identical to the initial values.

## 3. Descriptor findings (CCD and CUE)

### 3.1 CCD (CloneCD control file)

Verified observations (section/key):

- `[CloneCD] Version=3`.
- `[Disc] TocEntries=27`, `Sessions=1`, `DataTracksScrambled=0`, `CDTextLength=0`.
- `[Session 1] PreGapMode=1`, `PreGapSubC=1`. The meaning of these two keys is **not documented** in the partial, unofficial specification in the [GNU ccd2cue manual](https://www.gnu.org/software/ccd2cue/manual/ccd2cue.html). They are recorded without interpretation.
- `[Entry 0]`–`[Entry 26]` = 27 TOC entries, all `Session=1`, `ADR=0x01`, `ALBA=-150`, `Zero=0`:
  - **3 special entries (not tracks):**
    - `Point=0xA0`: `Control=0x04`, `PMin=1`, `PSec=0`.
    - `Point=0xA1`: `Control=0x00`, `PMin=24`.
    - `Point=0xA2`: `Control=0x00`, `PMin:PSec:PFrame=60:32:63`, `PLBA=272313`.
  - **24 track entries:** `Point=0x01`–`0x18`. Track 1 has `Control=0x04`; tracks 2–24 have `Control=0x00`.
  - For every track entry and for A2, `PLBA = (PMin×60+PSec)×75+PFrame − 150` holds exactly. That is the standard rule for turning a disc time into a sector number (see §7).
- `[TRACK 1] MODE=1`. `[TRACK 2]`–`[TRACK 24] MODE=0`.
- Index declarations:
  - `[TRACK 1]` and `[TRACK 2]` declare only `INDEX 1`.
  - Tracks 3–24 declare both `INDEX 0` and `INDEX 1`, always exactly 148 sectors apart.

Interpretation (assumption, based on the standard CD table-of-contents layout):
- **A0 / A1:** `PMin` holds the first track number (1) and the last track number (24). The A0 `PSec=0` value is the disc-type byte that conventionally means CD-DA/CD-ROM. The `PLBA` values on A0 (4350) and A1 (107850) are just the formula applied to those numbers, **not real disc addresses**.
- **A2:** gives the lead-out (the end of the recorded area) at sector 272,313.
- **Control bit 2 (0x04):** marks a data track. 0x00 marks an audio track with 2 channels, no pre-emphasis and copy not permitted.

### 3.2 CUE sheet

Verified observations (line numbers in `Pitfall.cue`):

- **L1:** `FILE "Pitfall.img" BINARY`. This is the only `FILE` line. It names a file present in the same folder: a bare filename, with no path separators, absolute path or `..`. **There is no `.bin` reference mismatch.**
- **L2:** `TRACK 1 MODE1/2352`. **L4, L6 … L69:** `TRACK 2`–`TRACK 24 AUDIO`. That gives 24 tracks numbered sequentially 1–24.
- **INDEX lines:**
  - Track 1 has `INDEX 1 00:00:00` (L3).
  - Track 2 has only `INDEX 1 02:00:30` (L5).
  - Tracks 3–24 each have `INDEX 0` and `INDEX 1`.
  - Every MM:SS:FF value is in range (seconds ≤ 59, frames ≤ 74).
- **No** `PREGAP`, `POSTGAP`, `FLAGS`, `CATALOG`, `ISRC` or `REM` lines are present.
- **Minor syntax observation:** index numbers are written as `INDEX 1` rather than the usual two-digit `INDEX 01`. Most parsers accept this. Not a structural problem.

### 3.3 CCD ↔ CUE cross-check (verified)

- **Agreement:** For all 24 tracks, the CUE index values (converted from MM:SS:FF, file-relative) equal the CCD `[TRACK n] INDEX` values and the CCD entry `PLBA` values. The track types also agree (`MODE1/2352` ↔ `MODE=1` + `Control 0x04`; `AUDIO` ↔ `MODE=0` + `Control 0x00`).
- **Missing indexes:** Both descriptors omit `INDEX 0` for track 2.
- **Session information:** The CUE format carries no session information. The CCD declares one session.
- **Conflicting values:** none.

### 3.4 Track / session table

Conventions:
- **Sector** means a file-relative sector number, which equals the disc LBA for this image (see §7).
- **Byte offset** = INDEX 01 sector × 2,352.
- **Stored pregap** = INDEX 01 − INDEX 00. This is silent gap data physically present in the `.img`, not a declared CUE `PREGAP`.
- **End** is exclusive and equals the next track's first stored sector, or the lead-out for track 24.
- **Length** is measured from INDEX 01 to End.
- Sector and length values are **calculated** from verified descriptor fields.

| Sess | Trk | Type (CUE L / CCD) | INDEX 00 | INDEX 01 | INDEX 01 byte offset | End | Stored pregap | Length (sectors) | Length (s) |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 1 | MODE1/2352 (L2) / MODE=1, Ctrl 0x04 | — | 0 | 0 | 9030 | 0 | 9030 ¹ | 120.40 |
| 1 | 2 | AUDIO (L4) / MODE=0, Ctrl 0x00 | — ¹ | 9030 | 21,238,560 | 10924 | 0 ¹ | 1894 | 25.25 |
| 1 | 3 | AUDIO (L6) | 10924 | 11072 | 26,041,344 | 14289 | 148 | 3217 | 42.89 |
| 1 | 4 | AUDIO (L9) | 14289 | 14437 | 33,955,824 | 25286 | 148 | 10849 | 144.65 |
| 1 | 5 | AUDIO (L12) | 25286 | 25434 | 59,820,768 | 42016 | 148 | 16582 | 221.09 |
| 1 | 6 | AUDIO (L15) | 42016 | 42164 | 99,169,728 | 49087 | 148 | 6923 | 92.31 |
| 1 | 7 | AUDIO (L18) | 49087 | 49235 | 115,800,720 | 67645 | 148 | 18410 | 245.47 |
| 1 | 8 | AUDIO (L21) | 67645 | 67793 | 159,449,136 | 88057 | 148 | 20264 | 270.19 |
| 1 | 9 | AUDIO (L24) | 88057 | 88205 | 207,458,160 | 99496 | 148 | 11291 | 150.55 |
| 1 | 10 | AUDIO (L27) | 99496 | 99644 | 234,362,688 | 106895 | 148 | 7251 | 96.68 |
| 1 | 11 | AUDIO (L30) | 106895 | 107043 | 251,765,136 | 124424 | 148 | 17381 | 231.75 |
| 1 | 12 | AUDIO (L33) | 124424 | 124572 | 292,993,344 | 137996 | 148 | 13424 | 178.99 |
| 1 | 13 | AUDIO (L36) | 137996 | 138144 | 324,914,688 | 152569 | 148 | 14425 | 192.33 |
| 1 | 14 | AUDIO (L39) | 152569 | 152717 | 359,190,384 | 170001 | 148 | 17284 | 230.45 |
| 1 | 15 | AUDIO (L42) | 170001 | 170149 | 400,190,448 | 188800 | 148 | 18651 | 248.68 |
| 1 | 16 | AUDIO (L45) | 188800 | 188948 | 444,405,696 | 208173 | 148 | 19225 | 256.33 |
| 1 | 17 | AUDIO (L48) | 208173 | 208321 | 489,970,992 | 221791 | 148 | 13470 | 179.60 |
| 1 | 18 | AUDIO (L51) | 221791 | 221939 | 522,000,528 | 229577 | 148 | 7638 | 101.84 |
| 1 | 19 | AUDIO (L54) | 229577 | 229725 | 540,313,200 | 239634 | 148 | 9909 | 132.12 |
| 1 | 20 | AUDIO (L57) | 239634 | 239782 | 563,967,264 | 248300 | 148 | 8518 | 113.57 |
| 1 | 21 | AUDIO (L60) | 248300 | 248448 | 584,349,696 | 256841 | 148 | 8393 | 111.91 |
| 1 | 22 | AUDIO (L63) | 256841 | 256989 | 604,438,128 | 258811 | 148 | 1822 | 24.29 |
| 1 | 23 | AUDIO (L66) | 258811 | 258959 | 609,071,568 | 269031 | 148 | 10072 | 134.29 |
| 1 | 24 | AUDIO (L69) | 269031 | 269179 | 633,109,008 | 272313 (lead-out) | 148 | 3134 | 41.79 |

¹ Per the descriptors. The subchannel shows a different boundary at the end of track 1 and start of track 2 (see §4.3 and §6, D2). By subchannel evidence, track 1 data ends at sector 8879 (8,880 sectors = 118.40 s) and track 2 has a 149-sector stored pregap (8881–9029).

**Layout conclusion (inference from verified fields and samples):** a **single-session, mixed-mode** disc (one Mode 1 data track followed by 23 tracks declared as CD audio). It is not data-only, not audio-only and not multisession. Total recorded length is 272,313 sectors (3,630.84 s ≈ 60 min 31 s).

## 4. IMG / SUB size, boundary and sampled-header checks

### 4.1 Size arithmetic (verified)

| Test | Result |
| --- | --- |
| IMG ÷ 2,352 (raw sector) | 640,480,176 ÷ 2,352 = **272,313 remainder 0** |
| SUB ÷ 96 (subchannel per sector) | 26,142,048 ÷ 96 = **272,313 remainder 0** |
| IMG sectors = SUB sectors | Yes |
| IMG sectors = CCD A2 lead-out `PLBA` | Yes (272,313) |
| All track starts ordered, increasing and within the file | Yes |

Even division alone does not prove the format. The sampled headers in §4.2 independently support the 2,352-byte raw-sector reading. The constants match [libcdio's sector definitions](https://github.com/libcdio/libcdio/blob/master/include/cdio/sector.h). The image ends exactly at the lead-out, so there is **no sign of truncation**. The lead-out area itself is not stored, which is normal for this format.

### 4.2 Sampled data-track sectors (verified; header bytes 0–15 only)

These are 17 track-1 sectors at file offset sector × 2,352. Because CCD reports `DataTracksScrambled=0`, the headers were read as-is.

| Sectors sampled | 12-byte sync | Header MSF vs expected (LBA+150) | Mode byte |
| --- | --- | --- | --- |
| 0, 1, 2, 15, 16, 17, 100, 1000, 4515, 8000, 8879 (11 samples) | valid | all match | 1 |
| 8880, 8900, 8950, 9000, 9028, 9029 (6 samples) | absent | `00:00:00` (all-zero) | 0 |

- **ISO 9660 check at sector 16:** user-data byte 0 = `1` (primary volume descriptor) and bytes 1–5 = the standard identifier `CD001`. Only those 6 bytes were read. The volume label and other descriptor fields were **not** read.
- **Boundary scan:** sectors 8870–9035 were scanned, reading only the 16 header bytes and 12 Q bytes of each. The last sector with a valid Mode 1 header is **8879**.
- **Silence of 8880–9029 (verified):** all 150 of these sectors are entirely zero bytes. Only a non-zero yes/no per sector was computed; no payload was kept.

### 4.3 Subchannel (SUB) checks

**Verified:** SUB size and alignment match IMG exactly (§4.1).

**Assumption:** the `.sub` stores each sector's 96 bytes non-interleaved, as P (12) then Q (12) then R–W (72), which is CloneCD's convention. The Q values below are consistent with that assumption, but they are **unvalidated**: the Q CRC was not checked, and the brief excluded building a full decoder.

| Sectors | Q ctrl | Q ADR | Q track / index | Agrees with descriptors? |
| --- | --- | --- | --- | --- |
| 0–8879 (sampled) | 4 | 1 | 01 / 01 | Yes |
| 8880 | 4 | 1 | 01 / 01 | Yes (but the sector holds no data header) |
| 8881–9029 | 0 | 1 | **02 / 00** | **No — descriptors declare no track-2 INDEX 00** |
| 9030 onward (track 2 sampled) | 0 | 1 | 02 / 01 | Yes |
| 10915–10923 | 0 | 1 | 02 / 01 | Yes |
| 10924–11071 | 0 | 1 | 03 / 00 | Yes (148-sector pregap confirmed) |
| 11072–11076 | 0 | 1 | 03 / 01 | Yes |
| 17, 9033 | — | **2** | — | ADR 2 frames, conventionally the Media Catalog Number. **Not decoded.** |

- **Absolute time check:** on every ADR-1 sample, the Q absolute time equals LBA + 150 (for example sector 270179 → `60:04:29`).
- **Q control nibble:** 4 for data, 0 for audio, matching the CCD `Control` values.
- **Coverage gap:** pregap boundaries for tracks 4–24 were checked against the descriptors only, not against the Q channel.

## 5. Possible CD-audio findings and validation limits

- **Verified — declarations:** 23 tracks (2–24) are declared audio in both CCD (`MODE=0`, `Control=0x00`) and CUE (`AUDIO`). Their ranges exist inside the `.img` and add up exactly to the lead-out.
- **Verified — samples:** 12 full sectors in audio regions were read, but only to compute a sync-pattern yes/no and a count of zero bytes.
  - **Zero-filled samples:** the first INDEX 01 sector of tracks 2, 3, 12, 23 and 24, the track-3 pregap start (10924) and the final sector (272312). All were entirely zero, consistent with digital silence at track edges.
  - **Mostly non-zero samples:** 1,000 sectors into tracks 2, 3, 12, 23 and 24, only 14–138 of 2,352 bytes were zero.
  - **No data sync:** none of the audio samples had the data sync pattern.
- **Inference:** the audio regions contain non-silent, non-data sample content consistent with recorded audio. Chris Heimlich reports that the game's music and ambience are CD audio tracks (**Reported**, [S001](../research/sources.md)). This layout is *compatible* with that report but does **not** confirm it.
- **Not tested:**
  - Playback or listening.
  - Whether the audio is the original music, and whether it is complete or free of errors.
  - The drive read offset or sample offset.
  - C2 / CIRC error status.
  - Comparison with any reference checksum (e.g. an AccurateRip-style database).
  - Track titles and the expected track count for the retail release.
- Do not equate the AUDIO declarations, plausible lengths or non-zero content with authenticated or playable game music.

## 6. Discrepancies, blockers and unanswered questions

| ID | Finding | Label | Impact |
| --- | --- | --- | --- |
| D1 | Files are in `private/original-media/Pitfall_The_Mayan_Adventure_ISO/`, not the documented `private/original-media/`. | Verified — **resolved** | The user confirmed the subfolder as canonical (2026-10-15), and `CLAUDE.md` was updated. Git exclusion is unaffected. |
| D2 | Both descriptors place sectors 8880–9029 in track 1 and declare no INDEX 00 for track 2. The Q subchannel marks 8881–9029 (149 sectors) as track 2 index 00, and 8880 as track 1 without a data header. All 150 sectors are zero. | Verified (Q unvalidated) | Probably a descriptor-generation simplification rather than damage (**assumption**). It changes the computed lengths of track 1 and track 2 by about 2 s. It does not affect data-sector content. Before relying on exact track timing, check whether the original TOC/indexes are reproduced faithfully. |
| D3 | Stored pregaps for tracks 3–24 are 148 sectors, not the more common 150. The CCD, CUE and (for track 3) Q all agree. | Verified | Unusual but internally consistent. The cause is unknown: mastering, drive or offset behavior. **Not interpreted.** |
| D4 | Provenance is **reported** by the user as their own legitimate physical copy. Release, region and revision remain unknown. Timestamps suggest the image was created around 2007 (§2). | Reported / unknown | Release identity is still unconfirmed, which blocks any claim that this is the reference Kinesoft retail build. |
| D5 | Data sectors' EDC/ECC (built-in error-detection codes) were not verified. Only 11 data headers plus the boundary scan were checked. | Not tested | Undetected read errors in the data track remain possible. |
| D6 | Q-channel CRCs were not validated. The MCN (ADR 2) was not decoded. | Not tested | Q findings are unvalidated. The MCN could help identify the release. |
| D7 | `[Session 1] PreGapMode=1 / PreGapSubC=1` meanings are undocumented in the reference used. | Unknown | None currently. |

**No blockers** to finishing this read-only task: all reads succeeded, no references escaped scope, and the hashes did not change.

**Questions — answered by the user 2026-10-15:**
1. Origin: a legitimate physical copy the user owned (**Reported**).
2. Path: use the real subfolder path (adopted).

**Still open (optional):** who created the image, with what software, and whether it was made from the same disc the user now reports as scratched.

## 7. Reproduction commands and calculation conventions

**Conventions**
- 1 raw sector = 2,352 bytes in `.img`; 96 bytes in `.sub`; 75 sectors (frames) per second.
- CUE `MM:SS:FF` → frames = (MM×60 + SS)×75 + FF. In this CUE these are **file-relative**. Because the file starts at disc LBA 0 (track 1 INDEX 01 = `00:00:00`), file-relative frame = disc LBA.
- The 150-sector lead-in adjustment was applied **only** when converting between disc time (CCD `PMin/PSec/PFrame`, data-header MSF, Q absolute time) and LBA: LBA = MSF frames − 150. It was **not** applied to CUE indexes or CCD `[TRACK]` values, which are already LBA / file-relative.
- **Gap ownership** follows the CUE convention: a stored INDEX 00 range belongs to the track it introduces. Track length is measured from INDEX 01 to the next track's first stored sector. There are no CUE `PREGAP` (unstored silence) declarations.

**Commands** (PowerShell 5.1, run from the repository root)

```powershell
$git = "$env:LOCALAPPDATA\GitHubDesktop\app-3.6.7\resources\app\git\cmd\git.exe"
$d   = 'private/original-media/Pitfall_The_Mayan_Adventure_ISO'
& $git rev-parse --abbrev-ref HEAD; & $git rev-parse HEAD
& $git status --short --untracked-files=all
& $git check-ignore -v -- "$d/Pitfall.img" "$d/Pitfall.sub" "$d/Pitfall.ccd" "$d/Pitfall.cue"
& $git ls-files -- private
foreach ($e in 'img','sub','ccd','cue') {
  $f = Get-Item -LiteralPath "$d/Pitfall.$e"
  '{0} {1} {2:u} {3}' -f $f.Name, $f.Length, $f.LastWriteTimeUtc, (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash
}
```

The structural checks in §3–§5 were produced by a session-local helper script, `examine-media.ps1`, which was not committed (this task authorized documentation writes only). Its logic:

1. Parse CUE `FILE/TRACK/INDEX` lines and CCD `[section] key=value` pairs.
2. Check `PLBA = MSF−150` for each TOC entry.
3. Divide file sizes by 2,352 and 96.
4. Compare CUE ↔ CCD indexes, types and controls, plus ordering and bounds.
5. Open `.img` and `.sub` with `[IO.File]::Open(path,'Open','Read','Read')` and read at offsets `sector×2352` (16 header bytes, or one 2,352-byte buffer reduced to a sync yes/no and a zero count) and `sector×96+12` (12 Q bytes).
6. Close both streams in a `finally` block.

The boundary scans covered sectors 8870–9035, 10915–10930 and 11066–11076. The script can be re-created on request or added to the repository with approval.

## 8. Recommended next task

**Proposed task:** read-only **ISO 9660 directory inventory of track 1**.
- **Read:** the primary volume descriptor fields (volume identifier, creation date) and the directory records.
- **Record:** each file's name, size and date, plus a SHA-256 computed in memory directly from the image's sectors.
- **Store:** only that metadata, in `docs/inventory/`.
- **Do not:** write any file out, mount the image, or execute anything.

**Purpose:** establish *what* is on the data track, for example whether `PITFALL.EXE`, the supporting DLLs, `INIT.PH` and the `LEVEL*.PH` files reported in S001 are present. It also yields per-file fingerprints and volume dates that can be compared with other known copies, such as Chris Heimlich's if he shares hashes. This is the smallest step toward release identification, and toward checking the gap in D4.

**Required approval:** explicit user approval. This reads file-system structure and file contents (in memory) inside the image, which goes beyond this task's header-only boundary. It still requires no mounting, extraction to disk, execution or tool installation. Decoding the MCN or validating Q CRCs (D6) could be bundled in, or kept as a separate optional step.
