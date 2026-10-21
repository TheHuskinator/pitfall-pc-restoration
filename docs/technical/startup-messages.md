# Start-up messages in `PITFALL.EXE`: where the text is stored

**Status:** accepted by Work on 2026-10-21. These are **Claude-reported findings reviewed by Work**, not an independently reproduced examination. Claude wrote and ran both helpers; Work checked the recorded evidence files against their fingerprints and checked the printed arithmetic, without reading the game file.

**Subject:** the working copy of `ASSETS/PITFALL.EXE` from MEDIA-001 (see [materials-inventory.md](../inventory/materials-inventory.md)): 772,608 bytes, SHA-256 `36047291632BEAD27D3AF09EE99BBEF1EEC06F3B9FEA53DB906ECB1E74BFFA86`. Each helper read the file into memory, then verified its hash before parsing or searching.

## Plain-English summary

The game shows two messages when it starts on Windows 11 (see [existing-account-confirmation-1.md](../testing/existing-account-confirmation-1.md)): a 256-colour warning, then "Pitfall must be played using the CD-ROM." It then closes.

Two read-only searches of the program file found where the text of both messages is kept:

- Each sentence is stored **once**, as 16-bit Unicode text (UTF-16LE), inside the program's resources. Resources are data built into a Windows program, such as icons, menus and lists of text messages.
- Each sentence is the complete text of one entry in a **string table**. A string table is a numbered list of text messages that a program can ask Windows for by number.
- The CD-ROM message is string **227**, and the colour warning is string **17**. Both are in the US-English (`0x0409`) tables.

**What this does not tell us:** which part of the program asks for message 227, or what condition leads there. The start-up check logic is still unknown. Finding it needs code analysis, which has not been done.

## Method

| Step | Tool and fingerprint | Synthetic tests | Run on `PITFALL.EXE` |
|---|---|---|---|
| 1. Text search: find each sentence, in single-byte (ANSI) and UTF-16LE form | `find-pe-text.ps1` revision 2, SHA-256 `0E581E3319CE413A2A87F58A3689CD018BC18DABCF918946ED1C2240CDBB45F2` | 72/72 PASS, 2026-10-20 (tests `EDA9A7E3…0130EF`) | Once, 2026-10-21 21:49 UTC; exit 0 |
| 2. Resource mapping: walk the resource directory and find which resource contains each sentence | `map-pe-resource.ps1`, SHA-256 `EF66F9DD4FDAAFABDC36E609F43C36C51B875FDA2508A058EC168CDE9FAC5C89` | 55/55 PASS, 2026-10-21 (tests `70C661DE…56929`) | Once, 2026-10-21 22:27 UTC; exit 0 |

- **How each step was approved:** Work reviewed each helper's source, accepted it for one synthetic test run, accepted the test result, and then authorized exactly one run on the working copy. Both runs used Windows PowerShell 5.1, unelevated. Each helper's fingerprint matched before and after its run.
- **Read-only:** each run read the file once, into memory. Neither helper writes to the file, and neither prints bytes or text from it. Both print positions, sizes, counts, IDs and classifications only.
- **What the mapping helper checks:**
  - **Before mapping:** it confirms that the bytes at each given position are exactly the expected sentence in UTF-16LE.
  - **The resource directory:** it reads the directory through the program header's resource entry, not through the section name, following Microsoft's "PE Format" specification (section ".rsrc Section").
  - **Unique containment:** exactly one resource data entry must contain each target, and no entry may contain it partly.
  - **The string ID:** for a string-table block it parses the block's 16 entries and derives the string ID as (block ID − 1) × 16 + entry position. This follows Microsoft's STRINGTABLE documentation ("RC allocates 16 strings per section") and Raymond Chen's "The format of string resources".
- **Where the helpers are kept:** both helpers and their tests are in git-ignored local review batches, not in this repository. Adding them to `tools/` would be a separate, reviewed change.

## Results

### Text search (step 1)

| Sentence | ANSI copies | UTF-16LE copies | File offset | RVA | Section |
|---|---:|---:|---|---|---|
| T1 "Pitfall must be played using the CD-ROM." | 0 | 1 | `0x000AC90A` | `0x000B550A` | #6 `.rsrc` |
| T3 "Pitfall must be played in 256 color mode for optimum performance." | 0 | 1 | `0x000AA982` | `0x000B3582` | #6 `.rsrc` |

- **Shorter search terms:** two shorter terms ("using the CD-ROM" and "256 color mode") were each found once, inside their full sentences, at the expected distances.
- **The section table** printed by the helper agrees with [executable.md](executable.md) §3.
- **What Work corrected in the first interpretation** (2026-10-21):
  1. **References were not searched,** by design, because the helper does not search for references to UTF-16LE text. This does not mean that references do not exist or cannot be found.
  2. **No reference-finding method was established** at that point.
  3. **The 0x1F88-byte gap** between the two sentences shows distance only. It does not by itself show that they belong to the same resource or block. The mapping later showed that they are in different blocks.

### Resource mapping (step 2)

- **The resource directory:** RVA `0x00076000`, size `0x0003FD84`, in section #6 `.rsrc`.
- **The walk:** it covered 87 directory tables, 165 directory entries and 79 data entries, within all of the helper's limits.

| | T1 (CD-ROM message) | T3 (256-colour warning) |
|---|---|---|
| Resource type | 6, RT_STRING (string table) | 6, RT_STRING |
| Block ID | 15 | 2 |
| Language | `0x0409` (English, United States) | `0x0409` |
| Block data | RVA `0x000B5424`, 1,078 bytes, code page 0 | RVA `0x000B3534`, 540 bytes, code page 0 |
| Block parse | 16 entries, 0 bytes left over | 16 entries, 0 bytes left over |
| Position in the block | entry 3 (of 0–15), 230 bytes into the data | entry 1 (of 0–15), 78 bytes into the data |
| **String ID** | **227** = (15 − 1) × 16 + 3 | **17** = (2 − 1) × 16 + 1 |
| Match | the whole entry (40 UTF-16 units) | the whole entry (65 UTF-16 units) |

**Consistency checks.** These are arithmetic on the printed values, made by Claude and checked by Work. They are not independent verification.
- **The positions agree.** Block data RVA plus the position in the block reproduces the text search's RVAs exactly:
  - `0xB5424` + 230 = `0xB550A`;
  - `0xB3534` + 78 = `0xB3582`.
- **The lengths agree.** Each entry's length equals its sentence's length.
- **The blocks parse exactly.** Both blocks parse to 16 entries with no bytes left over.

## Limits

- **"Unique mapping" has a narrow meaning:** exactly one resource contains each *specified* target range. Evidence about how many copies of each sentence exist comes from the text search, not from the mapping.
- **Only the stored text is shown.** An exact string-table entry does not prove that the message displayed on screen is never modified or combined with other text at run time.
- **The mapping does not show loading:** it does not establish whether, how or when the program loads either string.
- **A string ID is not code:** it identifies an entry in a string table, not the code that loads or displays it.
- **No loading route is assumed:**
  - The program imports `LoadStringA` ([executable.md](executable.md) §6), but that is not evidence that either string is loaded through it.
  - The program also imports `FindResourceA`, `LoadResource` and `LockResource`, and other routes are possible.
- **The audio question is not settled:** these results do not bear on whether CD audio tracks are required.
- **Not examined:** the other resources, other text in the file, the program's code, and other game files.

## Evidence files

All are kept locally in the git-ignored `private/work-review/` folder. They contain metadata only.

| Batch | File | SHA-256 |
|---|---|---|
| `2026-10-21-pitfall-exe-search-run-1` | `find-pe-text-run-1-output.txt` | `49A2218E57AB5AE0291BE697B6A39C9B3BD9A481C9274D188E8D2E0267AC9074` |
| | `search-helper-r2-synthetic-run-1.txt` | `5BA3C856F934704C5D9AE3102A2E702D796F9934A959B2A54B4A0044693A526E` |
| | `RUN-RECORD.md` (its interpretation was superseded by the corrected summary) | `F6A6A8819F8383A957006719299910512E5D970B44FEB1C0259BDD1D9FD2EB80` |
| `2026-10-21-resource-mapping-helper` | `search-run-1-summary-corrected.md` | `8CAF7F358E98EDE53D31C90CB085787DFA1232D78E44D9F34EF63B466529C9BC` |
| `2026-10-21-resource-mapping-synthetic-run-1` | `test-map-pe-resource-run-1.txt` | `0C141E9A1ECDDE95D41EC7E68080800BD2E00E26B499555F84798DFF3F476D9D` |
| `2026-10-21-resource-mapping-run-1` | `map-pe-resource-run-1-output.txt` | `7B7C0CA62C041A99270D8CD08BFE86E8C6458C12FECFEB54F1D361A7F1D6714B` |
| | `RUN-RECORD.md` | `635F318B2410D3EE4A109917150181FC2F74826FAB70D68B1336BE0A40DDE012` |

## Next question

The next question is **which code uses string 227, and what branch leads there**.

- **Proposal:** a code-analysis proposal (revision 2) was accepted by Work on 2026-10-21.
- **Tool:** Claude's checks had found no suitable installed disassembler. With the user's approval, Ghidra 12.1.4 and its required JDK 21 were downloaded, verified against the published checksums and extracted (Claude-reported). Neither has been run.
- **Now:** source preparation for a synthetic validation stage is authorized. Running the tools, and any analysis of the game file, need separate approval.
- **Done so far:** no code analysis.

## Sources

- Microsoft, "PE Format", section ".rsrc Section", https://learn.microsoft.com/en-us/windows/win32/debug/pe-format, accessed 2026-10-21.
- Microsoft, "STRINGTABLE resource", https://learn.microsoft.com/en-us/windows/win32/menurc/stringtable-resource, accessed 2026-10-21.
- Raymond Chen, "The format of string resources", *The Old New Thing* (Microsoft), https://devblogs.microsoft.com/oldnewthing/20040130-00/?p=40813, accessed 2026-10-21.
