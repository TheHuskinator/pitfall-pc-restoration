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
