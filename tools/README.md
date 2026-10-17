# Tools

Small, reviewable helper scripts. They use only what ships with Windows (PowerShell 5.1 and .NET Framework) — nothing to install.

## `verify-media001.ps1` — read-only MEDIA-001 verifier

**Purpose:** let anyone with the disc image re-confirm the recorded MEDIA-001 findings. It addresses audit item W8 in [docs/reviews/media-001-audit-tracker.md](../docs/reviews/media-001-audit-tracker.md).

**Safety:**
- Opens the media read-only (`FileAccess.Read`, `FileShare.Read`).
- Never writes, mounts, extracts or executes anything.
- Hashes file contents in memory only.
- Prints only PASS/FAIL lines, metadata and hashes. It prints no game content.

**Expected values:**
- File paths, sizes, extents and SHA-256 values, plus the image SHA-256, are read from [docs/inventory/materials-inventory.md](../docs/inventory/materials-inventory.md). The inventory stays the single source of truth.
- Sector count (272,313), data-sector count (8,880), volume ID (`PITFALL`) and volume size (8,728 blocks) are parameters with documented defaults.

### Checks

1. **EDC self-test:** `"123456789"` → `0x6EC2EDC4` (CRC-32/CD-ROM-EDC check value). Runs before the image is touched.
2. **Image:** SHA-256 of `Pitfall.img` against the inventory; IMG ÷ 2,352 and SUB ÷ 96 both equal 272,313 with no remainder.
3. **Data sectors:** every Mode 1 sector (LBA 0–8879) has a valid sync pattern, header address, mode byte 1 and EDC.
4. **Volume:** primary volume descriptor type, ID and volume space.
5. **Files:** directory walk; each file's path, size, extent, flags and SHA-256 against the inventory. Missing or extra files fail.

Out of scope: ECC, Q-subchannel CRCs, the Media Catalog Number, audio tracks and the CCD/CUE descriptors.

### Run

From the repository root, with the image at `private/original-media/Pitfall_The_Mayan_Adventure_ISO/`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify-media001.ps1
```

`-ExecutionPolicy Bypass` applies only to this one process; it does not change any system setting. Add `-SkipImageHash` to skip the whole-image hash, which saves a few seconds.

**Expected result:** every line reads `PASS`, the last line is `RESULT: PASS (all checks)`, and the exit code is `0`. Runtime is roughly 10–30 seconds.

### Test that it can fail

Give it a wrong expectation. This changes no media:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify-media001.ps1 -ExpectedVolumeId WRONG -SkipImageHash
```

**Expected result:** `FAIL  Volume ID`, then `RESULT: FAIL (1 check(s) failed)`, and exit code `1`.

### Runs so far

| Date | Who | Result |
| --- | --- | --- |
| 2026-10-15 | Claude Code (Windows 11 Home 10.0.26200, PowerShell 5.1.26100.9444) | All checks PASS. Negative test (wrong volume ID plus one altered inventory hash in a scratch copy) gave exactly 2 FAILs, exit code 1. |

A run by the same examiner is a reproducibility check, not an independent confirmation. A run by someone else with their own copy of the image would be.

## `inspect-pe.ps1` — read-only PE32 header/import/export inspector

> **Draft status (branch `draft/inspect-pe-exports`, 2026-10-16):** the export-table support and the export tests described below are an **unreviewed, never-run draft**. They await ChatGPT Work's source review, and running the tests needs the user's separate authorization. Everything else in this section describes the reviewed and tested version at `c389278`.

**Purpose:** report a 32-bit Windows program's (PE32) headers, sections, entry point and static imports, in original and sorted order, and (draft) its export table. It is the reviewed and synthetic-tested replacement for the session-local parser behind report R2.1 ([docs/technical/executable.md](../docs/technical/executable.md)). Review history: [audit tracker](../docs/reviews/media-001-audit-tracker.md).

**Safety:**
- Opens its input read-only.
- Never writes, executes, disassembles or extracts anything.
- In image mode, verifies the file's SHA-256 before parsing.
- Prints only header values, offsets, hashes, and import and export names, ordinals and forwarder strings.

**Input modes:**
- `-Path <file>`: a standalone file. Used by the tests.
- `-Image <img> -Extent <lba> -Size <bytes> -ExpectedSha256 <hash>`: a file inside a raw 2,352-byte-sector Mode 1 image.

**Exit codes:** for outcomes handled by the script itself, after PowerShell has started and bound the parameters, each code is also printed as the final `RESULT:` line. Failures before that point produce PowerShell's own error output, and are **not** guaranteed to print a `RESULT:` line or to use these codes. Examples: a missing or wrongly typed argument rejected during parameter binding, or PowerShell failing to start.

| Code | Meaning |
| --- | --- |
| 0 | OK |
| 1 | Input error (arguments, missing file, size, extent or range) |
| 2 | Hash mismatch; nothing parsed |
| 3 | Malformed (truncated, out of range, unterminated, ambiguous or inconsistent structure) |
| 4 | Unsupported (not MZ, MZ without a PE signature, or not PE32) |
| 5 | Internal error |

**Structural rules it enforces:**
- End of the section table ≤ `SizeOfHeaders` ≤ file size.
- No overlapping section address ranges.
- Section raw data lies inside the file.
- The import directory lies within one supported stored region: either the header area (an RVA below both `SizeOfHeaders` and the lowest section address, mapped 1:1) or one section's stored data.
- Import descriptors and their all-zero terminator lie within the declared directory size.
- Lookup tables and names must be terminated inside their region.
- Names must be printable ASCII.

**Address-mapping policy:** this tool bounds section mapping by `VirtualSize`. That is the tool's deliberate, stricter policy, not a claim that it reproduces the Windows loader exactly.

### Exports (draft)

**Output:**
- A separate `=== EXPORTS` section comes **after** the static-import section. Every existing header and import line, and every exit-code meaning, is unchanged; the export section is purely added.
- A file with no export directory prints `(no export directory)`. For the R2.1 and R2.2 files, which have no export directory, that is expected to be the only difference (not yet verified by a run).
- The section shows the export directory location, the library name, the directory fields, then one line per address-table entry in original order. For example:
  - `ordinal 1: RVA 0x00001000 -> section .text [CODE X R] (stored bytes); names: Alpha, AlphaAlias`
  - `ordinal 3: unused (address 0); names: (none)`
  - `ordinal 4: forwarder -> OTHER.Func; names: Fwd`
- It ends with a `Total exports:` line. `NOTE:` lines mark observations that are not errors: a non-zero reserved flags field, an ordinal above 65535, duplicate names, or a name that refers to an unused entry.

**Rules:**
- **Metadata must be readable from stored data:**
  - the export directory must be at least 40 bytes, in one stored region, and within `SizeOfImage`;
  - the library name, address table, name pointer table, ordinal table and every name are all bounds-checked;
  - counts are capped at 65,536, and arithmetic is done in 64 bits;
  - each name's ordinal-table index must be below `NumberOfFunctions`.
- **Aliases are valid:** several names may share one entry, so there can be more names than functions.
- **Forwarders:** an address inside the export directory's own range is a forwarder. It must be a printable `DLL.Name` or `DLL.#ordinal` string (split at the last `.`; ordinal decimal 0–65535). Its terminating zero must lie inside the export directory range.
- **Targets are classified, not read** (this tool's policy):
  - an address may be in the header area, or in a section (whose flags are shown, and whether the address has stored bytes), or "unmapped/unclassified; loader validity not established";
  - only an address at or beyond `SizeOfImage` is malformed;
  - section flags are observations, not proof that an export is code rather than data.

### Run (MEDIA-001 `PITFALL.EXE`)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\inspect-pe.ps1 -Image private\original-media\Pitfall_The_Mayan_Adventure_ISO\Pitfall.img -Extent 8070 -Size 772608 -ExpectedSha256 36047291632BEAD27D3AF09EE99BBEF1EEC06F3B9FEA53DB906ECB1E74BFFA86
```

**Expected result:**
- `SHA-256 check: matches expected value`;
- the values in R2.1 §2–§6 (see §10 for the comparison);
- `Total imported functions: 180 from 6 DLL(s)`;
- `RESULT: OK`, exit code `0`.

### Tests

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\tests\test-inspect-pe.ps1
```

**What they do:**
- **Draft:** the script now defines 59 cases: the 29 reviewed cases T01–T29, unchanged, plus 30 export cases T30–T59, which have not been run or reviewed. The description below covers the reviewed 29.
- 29 synthetic test cases. Each builds a harmless test file from scratch in memory, with no game data and no system files. Some are valid; most are deliberately malformed or unsupported (truncated, out of range, unterminated, overlapping, wrong format, and so on).
- Each test file is **written to a new temporary folder on disk**, and the inspector is run against it in a separate process. The test checks the exit code and key output lines.
- They cover every finding from both of ChatGPT Work's reviews (the mapping is in the script's header comment), plus image mode across several sectors, with marker bytes so that a misplaced read would fail the fingerprint check.
- The temporary folder is deleted afterwards.

**Expected result:** 29 `PASS` lines, then `RESULT: all 29 tests passed`, exit code `0` (reviewed version at `c389278`). For the draft, the expectation is 59 `PASS` lines and `RESULT: all 59 tests passed`. This is untested until a run is authorized.

**Line endings:** Git's `core.autocrlf=true` setting can write CRLF line endings into checked-out copies of files committed with LF, so the SHA-256 of a checked-out copy can differ from the reviewed value.
- **Committed content:** to compare it, use the Git blob ID (`git hash-object`, which applies Git's normalization).
- **A physical working file:** to show it differs only in line endings, hash it after converting CRLF to LF and compare with the reviewed value.

On 2026-10-15, Claude reported doing both checks for these two scripts; see *Runs so far*.

### Runs so far

| Date | Who | Run | Result |
| --- | --- | --- | --- |
| 2026-10-15 | Claude Code (user-approved) | Synthetic tests at `c389278` | 29/29 PASS, exit 0; temporary folder removed |
| 2026-10-15 | Claude Code (user-approved) | `PITFALL.EXE` re-read at `c389278` | Fingerprint matched before parsing; `RESULT: OK`, exit 0. All R2.1 values reproduced; only display order differs ([executable.md §10](../docs/technical/executable.md)) |

**Reviewed code identity for both runs** (commit `c389278`):

| File | Git blob ID | Reviewed SHA-256 (LF line endings) |
| --- | --- | --- |
| `tools/inspect-pe.ps1` | `1299ce51c5f69d1c5ed1612291a35e89e27cbb07` | `81FDEB05637DB9C35072EB768EEAF2FFFF3105749771A516F534CE23A13C193C` |
| `tools/tests/test-inspect-pe.ps1` | `43d4e3e4217fe0f1cbec0073f31cf1ace968ac09` | `D5199AD4ECFD841017C35E8A81546B05127906E5C597AD9203B8F6A1707964E9` |

Claude's reported checks: both working files matched these blob IDs and, after CRLF→LF conversion, these SHA-256 values.

**Evidence limit:** both runs were performed and reported by Claude, who also wrote the tool, so this is not an independent confirmation. ChatGPT Work reviewed the source (twice) and the reported results, but did not run the tool.
