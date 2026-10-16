# Materials inventory

A record of original materials the user has supplied. **The files themselves stay in `private/` and are never committed** — this page holds only descriptive information so we can identify exactly which version we are working from.

## How to add an item

1. Copy the original into `private/` (keep the original media untouched elsewhere).
2. Record a SHA-256 hash, e.g. in PowerShell: `Get-FileHash -LiteralPath <file> -Algorithm SHA256`.
3. Add a row below.

## Items

### MEDIA-001 — candidate CD image set (CloneCD-style IMG/SUB/CCD/CUE)

- **First observed / hashed:** 2026-10-15 by Claude Code (read-only). Hashes re-verified unchanged at end of session.
- **Location:** `private/original-media/Pitfall_The_Mayan_Adventure_ISO/` (confirmed by the user as the canonical location, 2026-10-15).
- **Source / provenance:** **Reported (user, 2026-10-15):** the image was made from a legitimate physical copy of the game that the user owned. Not independently verifiable from the files themselves. Who made the image, with which software, and on what date have not been stated. File timestamps of 2007-03-31 are consistent with an image made around then (weak evidence).
- **Release / region / revision:** **unknown.** Not inferred from filenames.
- **Permission for use:** private reference use only, per `docs/legal/rights-and-provenance.md`. No redistribution rights established.
- **Structure summary:** single session, 24 tracks (1 × Mode 1 data + 23 × declared audio). Full report: [original-media-examination.md](../technical/original-media-examination.md).

| ID | File (repo-relative) | Bytes | Last write (UTC) | SHA-256 | Notes |
| --- | --- | ---: | --- | --- | --- |
| MEDIA-001a | `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.img` | 640,480,176 | 2007-03-31 22:33:22 | `EDCE93BEAEB97DDEFE703A756C498B9533206213B50EA34550F470E1CE147172` | Raw 2,352-byte sectors; 272,313 sectors |
| MEDIA-001b | `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.sub` | 26,142,048 | 2007-03-31 22:33:22 | `36DEFDCE92B9B6A79328645E45F93A7EAF35DB08B2D7C343324CE4AA40F9F73B` | 96-byte subchannel per sector; 272,313 sectors |
| MEDIA-001c | `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.ccd` | 5,510 | 2007-03-31 22:33:16 | `034C26F37CF7BE2ECA8EC20F9B42944332AA3F7DA572705A59EAD0903DD37ACC` | CloneCD control file, `Version=3` |
| MEDIA-001d | `private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.cue` | 1,445 | 2007-03-31 22:33:16 | `DC08B707EBBF531FEF4E52954B0D5DCCDF55802FE053FED8274F3E8A0545AF28` | References `Pitfall.img` (present) |
