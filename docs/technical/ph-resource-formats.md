# Kinesoft Windows 95 .PH resource formats — Chris Heimlich research extraction

**Prepared:** 2026-10-15  
**Status:** **Secondary technical notes, UNVALIDATED.** This is a selective, independently worded summary of Chris Heimlich's *The Modern Adventure* posts **S001-S006** in [sources.md](../research/sources.md). It does **not** mean we have inspected original bytes, run MATLAB scripts, obtained Chris's private repository or implemented a working decoder. Field descriptions below reflect his published interpretation; ambiguity is called out.

## 1. File organization and outer segments (S001)

- `PITFALL.EXE` has supporting DLLs; resource data is in files with `.PH` extension.
- `INIT.PH` is reported to contain shared/common resources; `LEVEL*.PH` files contain level-specific data. Do not infer an exact file count or revision before inventorying our copy.
- S001 describes an outer sequence of **4-byte lengths followed by payloads of that size**. Segment start/length conventions need verification on real files. Do not blindly split solely on interior signatures.
- He located **uncompressed RIFF/WAVE sound-effect data within `INIT.PH`**; he did not find WAVE data in level files. The music and ambience were identified as **Red Book CD audio tracks**, not necessarily recoverable from the EXE or a data-only ISO.
- A repeated sprite-segment signature is rendered in his notes as **`4.V4`**; S001 also prints a hex value. Treat the literal byte representation as a **to-verify item**, not a validated magic constant, since typography and integer byte order need checking.

## 2. Sprite segments (S002, updated by S003 and S006)

Each segment has an indexed-color palette at a relative location; RGB palette triplets are used to resolve 8-bit pixel indexes. S002 distinguishes a simpler format and a more common complex format.

### Simpler variant (as S002 describes)

| Offset in sprite segment | Type | Reported meaning |
| --- | --- | --- |
| `0x00` | 4 bytes | Segment signature `4.V4` (actual bytes unverified) |
| `0x04` | uint32 | Relative palette offset |
| `0x08` | uint16 | Palette color count |
| `0x0A` | uint16 | Bytes per sprite entry |
| `0x0C` | uint16 | Sprite columns/width |
| `0x0E` | uint16 | Sprite rows/height |

After the 16-byte header, entries contain fixed-size raw index grids, followed by the palette. **Pixel index 0 indicates transparency** in this variant; the RGB palette begins with usable index 1. S002 describes this variant in only two observed sprite segments, and speculates it may be older/unused.

### Complex variant (S002/S003/S006)

| Offset | Type | Reported meaning |
| --- | --- | --- |
| `0x00` | 4 bytes | Segment signature |
| `0x04` | uint32 | Relative palette offset |
| `0x08` | uint16 | Number of palette colors |
| `0x0A` | uint16 | Sprite entry count |
| `0x0C...` | uint32 per entry | Relative offsets to sprite entries |
| Entry `+0x00` | uint32 | Width in pixels |
| Entry `+0x04` | uint32 | Height in pixels |
| Entry `+0x08` | int32 | Render X offset **(interpreted later in S006)** |
| Entry `+0x0C` | int32 | Render Y offset **(interpreted later in S006)** |

The 16-byte per-entry header precedes the encoded rows. The segment's palette stores ordered RGB triples. S003 supplies a revised **complete MATLAB function** for both variants on the original page; use that primary listing for implementation details instead of treating the early S002 excerpt as definitive.

Reported complex-row markers:

- `0x7F`: row terminator.
- `0x7E`: terminator for the final row/sprite.
- `0x7D`: row position increment used in wider sprites; S003 notes complications for widths **above 124 pixels**.
- Encoded bytes describe sequences of palette indexes and transparent spans; transparency may be implied at beginning/end of rows. **Do not implement as literal uncompressed pixel bytes.**

S003 reports **11,568 total extracted individual sprites** including shared and level-specific sets. S006 tests signed per-frame X/Y offsets by alignment against displayed animations; reported player origin near the center of the feet. This is promising for accurate sprite placement, **not yet validated here**.

Implementation questions: verify magic bytes and little-endian interpretation, palette indexing in both variants, relative offsets, row marker edge cases, alignment/padding, oversized sprites and signed X/Y offsets on representative files.

## 3. Background tile planes (S004)

S004 reports **8x8 pixels per tile**, 8-bit palette indexes, with a pool of tiles and a 2-byte reference per tile on each plane. Its documented header uses **little-endian fields**.

| Offset in background segment | Type | Reported meaning |
| --- | --- | --- |
| `0x00` | uint32 | Number of tile columns |
| `0x04` | uint32 | Number of tile rows |
| `0x08` | uint32 | Tile-pool offset relative to segment |
| `0x0C` | uint32 | Palette offset relative to segment |
| `0x10` | uint32 | Number of palette colors |
| `0x14...` | uint16 x (columns × rows) | Tile references |

Each pool tile consumes **64 indexed bytes**. Palette entries are **RGB triples**. In the published MATLAB decoder, palette index zero is handled as transparent.

The 16-bit reference is interpreted as:

| Bit(s), with bit 0 least significant | Purpose in S004 |
| --- | --- |
| 0-11 | Tile-pool index |
| 12 | Tile-to-tile priority flag |
| 13 | Vertical flip |
| 14 | Horizontal flip |
| 15 | Sprite-to-tile priority flag |

The author's **priority flag names are provisional**: he notes cases that do not fit a simple two-flag compositing model. **Parallax scroll parameters and tile animation behavior were not located** in S004. Do not assume these are resolved by extracting static layers.

Validation tasks: test header bounds and tile counts; check palette alpha handling, both flips and priority maps; compare reconstructed backgrounds with authorized screenshots/gameplay for `LEVEL00` and `LEVEL21` if available.

## 4. Dynamic, static and collision layout chunks (S005)

These are **the author's descriptive categories**, not necessarily names used by the original engine:

- **Dynamic:** animated/moving/interactive entities such as enemies or pickups.
- **Static:** invisible or fixed gameplay markers such as start locations or climbable areas.
- **Collision:** ground and wall layout constraints.

S005 describes a **16x16-pixel coordinate grid** whose columns and rows are encoded separately. An unresolved Y-axis offset appears when comparing entity coordinates to background images.

**Documented generic chunk shape:**

| Location | Stored representation | Interpretation |
| --- | --- | --- |
| First part | uint16 per column | Offset to the column's record block; zeros denote absent/unused columns |
| Second part, per populated column | Repeated `uint8 Y, uint8 entityID` | One record per row/ID pair |
| End of each column block | `0xFF` byte | End marker |

**Important endianness caveat:** S005's MATLAB parser explicitly **byte-swaps each 16-bit column offset**, describing those offsets as **big-endian**. That differs from the documented little-endian background header (S004). Verify actual byte order per field before implementing a shared binary reader.

The number of grid columns does not appear explicitly in the chunk by S005's analysis; it infers the boundary between offset table and column records from the first nonzero offset. Meanings of IDs require mapping tables, named in his published script:

- `Dynamic_Entity_Name_Map.xlsx`
- `Static_Entity_Name_Map.xlsx`
- `Collision_Entity_Name_Map.xlsx`

S005 **does not complete** collision geometry semantics or all entity mappings. Its excerpted MATLAB code appears to mix `segmentData` and `entityData` variable names; **treat the listing as a research aid requiring debugging**, not guaranteed executable source.

## 5. Reported consolidated tooling (S006)

As of the February 2021 post, Chris reported:

- A master MATLAB script that orchestrates extraction of all `.PH` assets.
- Individual extraction scripts, supporting name maps, organized level folders and a MATLAB project (`.prj`).
- A **private GitHub repository** for that project; **we have not accessed it**.
- High confidence that all file contents could be dumped, **not** that the game logic, runtime semantics, scrolling and collision have been completely reconstructed.

The most valuable follow-up request is **permission to view or adapt his consolidated code and name maps**, not an assumption of access. See [request checklist](../research/chris-heimlich-request-list.md).

## 6. Suggested first read-only validation tasks for Claude

1. Identify hashes/version for an authorized `INIT.PH`, `LEVEL*.PH`, `PITFALL.EXE` and related files; keep proprietary originals under git-ignored `private/`.
2. Inspect the first outer chunks and their lengths with a bounds-checking hex viewer/script. Document actual signature bytes and offsets.
3. Choose **one simple sprite segment**; parse metadata without exporting copyrighted sprite files to the repository.
4. Inspect **one background layer** (e.g. `LEVEL21`) for dimensions, palette/pool offsets, index bounds and flag frequencies.
5. Inspect **one layout segment** and test big-endian column offsets; output only counts and IDs to technical notes.
6. Record deviations from S001-S006 explicitly; do not retroactively call the published interpretations verified without binary evidence.

**No decompiler, decoder, patch, executable or game asset has been created/committed by this documentation update.**
