# MEDIA-001 audit tracker

**Created:** 2026-10-15
**Covers:** the two independent audits of Claude Code's MEDIA-001 examinations (commits `d0cd045` and `d906553`).
**Status meanings:**
- **Applied (uncommitted):** the correction is in the working tree, awaiting user authorization to commit.
- **Already addressed:** existing text already met the recommendation.
- **Open:** not done; needs a user decision or a separately approved task.
- **Outdated:** superseded by events.

| Audit | Source | Overall verdict |
| --- | --- | --- |
| Chat 2 | ChatGPT Chat 2 (research / technical-claim review), "Independent audit — MEDIA-001 examinations" | Accept with corrections |
| Work | ChatGPT Work, MEDIA-001 audit | Internally strong; scope-compliant within limits; one definite documentation error plus wording corrections |
| Work F01–F11 | "Repository readiness audit", referenced by the user | **Not received.** The text supplied on 2026-10-15 was the MEDIA-001 audit above, which has no F-numbered findings. Items cannot be tracked until it is provided. |

Neither auditor had access to the disc image. Hashes, raw-sector observations, Q readings and the EDC run therefore remain examiner-reported.

## Chat 2 — required corrections

| ID | Recommendation | Status | Where |
| --- | --- | --- | --- |
| C1 | Fix "39 in ASSETS" to 38 | Applied | `docs/technical/disc-contents.md`, summary |
| C2 | Narrow "intact / read without damage" to examiner-reported header+EDC pass; state what EDC does not prove; ECC not validated | Applied | `disc-contents.md` summary, *Sector integrity* and *Does*; `PROJECT_STATUS.md`; `docs/technical/README.md`; inventory |
| C3 | Document the EDC algorithm reproducibly: byte range, polynomial, init, final XOR, byte order, implementation, test case | Applied. Includes helper source and a test vector (`123456789` → `0x6EC2EDC4`), re-run 2026-10-15 without the image. The aggregate result is still not independently reproduced. | `disc-contents.md`, *EDC algorithm* |
| C4 | Relabel D2: the Q interpretation is an unvalidated observation pending CRC; keep the descriptor 9,030 vs Mode 1 8,880 distinction | Applied | `docs/technical/original-media-examination.md` §6 D2 (and D5 wording) |
| C5 | "No installer" → "no conventionally named installer identified"; filename guesses stay unverified; do not infer that dependencies come from Windows | Applied | `disc-contents.md`, *What the files appear to be*; `PROJECT_STATUS.md` |
| C6 | `PROJECT_STATUS.md`: one authoritative current state; older snapshots kept as dated history | Applied | `PROJECT_STATUS.md`, *Current project status*, plus historical markers |

## Chat 2 — other observations and optional items

| ID | Item | Status |
| --- | --- | --- |
| C-a | Claim C: clarify descriptor-defined vs physical data length for track 1 | Already addressed (footnote ¹ under the §3.4 track table); reinforced by the D2 rewrite |
| C-b | Distinguish ISO directory timestamps from verified manufacturing/release dates | Applied |
| C-c | Q-channel CRC validation; ADR-2 Media Catalog Number decoding; more pregap-boundary checks; ECC validation; careful audio-track examination | Open (needs separate approval) |
| C-d | Physical disc or box markings; comparison against a known reference | Open (needs user action) |
| C-e | Later, separately scoped inspection of `PITSTART.EXE` (launcher / CD-dependent startup) | Open (future proposal) |
| C-f | Next task: read-only PE header / static import summary of `PITFALL.EXE`, with stated limits (verify SHA-256; DOS/PE signatures, machine, bitness, subsystem, sections, entry point, imports; record a non-PE format as observed; no disassembly, decompilation, execution, resource extraction, downloads or patching) | **Done, approved 2026-10-15.** See `docs/technical/executable.md`. The hash was verified before parsing; the file is a valid PE32. Nothing was disassembled, executed or extracted. |
| C-g | Commit-state note: "not yet committed" was outdated once pushed | Outdated / already resolved (`origin/main` = `d906553` locally as of 2026-10-15) |
| C-h | Process lesson: future briefs should separate authorized reads, optional analysis, and operations needing renewed approval | Open (process; see *Proposed process change* below) |

## Work — recommendations

| ID | Recommendation | Status |
| --- | --- | --- |
| W1 | Directory-record flag wording ("every directory and file record has flags 0x00") | Partly outdated: the committed text said "All **file** flags are `0x00`". The sentence sat beside "every directory and file record is dated", which made it ambiguous, so it was clarified anyway: file records `0x00`; `ASSETS` directory record `0x02`. The latter was read directly by the verifier on 2026-10-15. Committed in `8f881aa`; verifier observation committed in `5aa4a29`. |
| W2 | Replace "intact" with "all 8,880 observed Mode 1 sectors passed header and EDC validation" | Applied; same as C2 |
| W3 | "No installer" → "no `SETUP.EXE` or `INSTALL.EXE` listed" | Applied; same as C5 |
| W4 | "Other dependencies not shipped" → "external dependencies remain unknown" | Applied; same as C5 |
| W5 | Mark the "first examination next / not independently inspected" passage as historical | Applied; same as C6 |
| W6 | EDC coverage is 8,880 Mode 1 sectors, not all 9,030 descriptor-assigned track-1 sectors | Applied in `disc-contents.md`, D5 and `PROJECT_STATUS.md` |
| W7 | Track-2 index finding stays "unvalidated Q-channel interpretation" | Applied; same as C4 |
| W8 | **Before** executable-import work: preserve a small, reviewable read-only verifier (or at least document the EDC polynomial and test vector), then do a second approved run confirming the EDC and directory results | **Done, approved 2026-10-15.** `tools/verify-media001.ps1` takes its expectations from the inventory. Second run: all checks PASS. Negative test: 2/2 planted errors caught, exit 1. Still open: a run by a party other than Claude, for independent confirmation. |

## Conflicting findings (not silently resolved)

| ID | Topic | Chat 2 | Work | Claude's position |
| --- | --- | --- | --- | --- |
| K1 | Proceeding when files were not at the brief's named paths | **Violation**: the brief's stop condition applied; later confirmation does not cure it | Scope-compliant ("pass with limits") | **Agrees with Chat 2.** The brief said to stop early if files were missing at the named paths. The correct action was to stop and ask, even though the subfolder was inside the approved folder. Handling of the files was unaffected. |
| K2 | Extra boundary scans, 12 full audio-sector reads, bundled EDC and `Add-Type` helper | **Concern** | Fit the approvals | **Agrees with Chat 2.** These exceeded a strict reading of "a few header reads" and of "the file listing". All were disclosed and read-only, but they should have been proposed rather than bundled. |
| K3 | What comes next | PE header/import summary of `PITFALL.EXE` | Preserve a verifier and confirm EDC/directory results first | No conflict on facts; this is an ordering choice for the user. Committing a small read-only verifier first improves reproducibility at low cost, but either order is defensible. |
| K4 | Claim B (track structure) | "Can't verify" (descriptor bytes unavailable) | "Pass" (on lead-out arithmetic) | Not a real conflict. The auditors checked different things, and both are accurate within their access. |

## R2.1 audit — `PITFALL.EXE` static analysis (Chat 2, 2026-10-15)

**Verdict:** Accept with corrections. **Final review: ACCEPT** (Chat 2, 2026-10-15). All seven corrections were verified, and no further documentation corrections are required.
- **Confirmed:** claims A–G (identity, offsets, COFF and optional headers, sections, entry point, the 180 imports).
- **Mislabeled:** claim H, on timestamp and Q1 wording.
- **Scope:** questions 1, 3 and 5 OK; questions 2, 4 and 6 Concern; no Violation.
- **Limits:** Chat 2 checked arithmetic and consistency against the report and the PE specification. It did not reproduce anything from the binary.

| ID | Required correction | Status |
| --- | --- | --- |
| R2.1-C1 | Timestamp is a recorded field value, not an established build time | Applied: `executable.md` summary, §2.2, D-EXE-1 title; `PROJECT_STATUS.md`; `docs/technical/README.md` |
| R2.1-C2 | Security directory: "no embedded Authenticode certificate table declared" (external catalog signatures not addressed) | Applied: §2.4 |
| R2.1-C3 | `.bss` → SizeOfUninitializedData is an observed relationship, not a required PE invariant | Applied: §5 |
| R2.1-C4 | Import lists are not strictly sorted; the original thunk order was not retained | Applied: §6 |
| R2.1-C5 | Q1 worded as a conditional hypothesis | Applied: §7 Q1 |
| R2.1-C6 | D-EXE-1: give the exact difference (22 d 23 h 52 m 45 s) or call it a calendar-date difference | Applied: §7 D-EXE-1; `PROJECT_STATUS.md` |
| R2.1-C7 | §9: results recalculable but not independently reproduced; preserve the parser in a future approved task | Applied: §9 |

| ID | Optional item | Status |
| --- | --- | --- |
| R2.1-O1 | §8 additions: no independent PE parser or known-PE validation; no current-Windows export comparison; no certificate table declared; indirect dependencies unknown | Applied: §8 |
| R2.1-O2 | Research notes on COMCTL32 ordinal resolution and legacy WinHelp availability | Applied as hypotheses Q7, Q8 |
| R2.1-O3 | Record the original thunk order; validate the parser against a harmless known PE; distinguish names from ordinals in future comparisons | **Done (draft branch, pending review), 2026-10-15:**<br>• original order recorded in `executable.md` §10.3;<br>• parser validated against 29 synthetic PE32 files;<br>• the tool tracks name and ordinal entries separately. |
| R2.1-N | Next-task order: parser → R2.2 (`PITSTART.EXE`, `KILLPIT.EXE`) → `WAIL32.DLL` → resources → run-time dependencies | Parser step done (see below). R2.2 is next, awaiting user decision. |

## PE parser review, tests and R2.1 reproduction (ChatGPT Work, 2026-10-15)

| Step | What happened | Outcome |
| --- | --- | --- |
| P1 | Work's source-only review of the session-local scratch parser (SHA-256 `0CBB6CE2…`) | 5 findings: failed lookup returned `-1` and could become a name; missing bounds checks; unbounded import traversal; silent name truncation; failures returned normally. |
| P2 | Draft replacement `tools/inspect-pe.ps1` plus 24 synthetic tests (branch `draft/inspect-pe`, commit `6a583bc`) | Work: substantial improvement, with 3 corrections plus 1 test addition: enforce the import-directory size, reject overlapping sections, require `SizeOfHeaders` ≥ end of section table, and add multi-sector image coverage. |
| P3 | Revision `c389278`: all 4 items, 29 tests, VirtualSize policy documented | Work: **ACCEPT for testing** (source only; not run). |
| P4 | Synthetic test run (user-approved) at `c389278` | **29/29 PASS**, exit 0. Code confirmed identical to `c389278` by Git blob ID; working-tree hashes differed only by CRLF line endings. |
| P5 | `PITFALL.EXE` re-read (user-approved) at `c389278` | Fingerprint matched before parsing; `RESULT: OK`. All R2.1 values reproduced; display-order differences only. Original order recorded. |
| P6 | Work's review of the P5 report | **Accepted as a Claude-reported reproduction**, with one wording correction: describe the tool as "the reviewed and synthetic-tested replacement parser", not as built separately, and keep the statement that Claude performed both examinations. Work independently compared all 180 reported imports with R2.1 and checked the arithmetic; it did not inspect bytes. |
| P7 | Documentation update (`executable.md` §10, `tools/README.md`, this tracker, `PROJECT_STATUS.md`) | Applied on `draft/inspect-pe`, uncommitted. The P6 wording correction is used in all new text. **Pending review before any merge.** |

**Evidence limit:** Claude wrote the tool and performed every run. These results are reproducible by anyone with the image, but no independent party has run them yet.

## Repository hygiene: tracker character-encoding repair (2026-10-15)

- **The problem:** commit `50cf7d0` saved this tracker with garbled characters: 21 sequences such as `â€”` for "—" and `Â§` for "§". The cause was a Claude bulk edit, run in Windows PowerShell 5.1, that read the UTF-8 file as Windows-1252 and wrote it back as UTF-8. Earlier commits (`8f881aa`, `5aa4a29`) were clean, and no other repository file was affected.
- **The fix:** applied on `draft/inspect-pe`, uncommitted. The exact mistake was reversed: the text was re-encoded as Windows-1252 and decoded as UTF-8.
- **Verified:** the result has no replacement characters; re-applying the faulty conversion reproduces the damaged text exactly; and its non-ASCII characters (§ ¹ – — →) match those of the last clean version.
- **Not changed:** no wording. Neither review noticed the problem; it was found while preparing this update.

## Process change (approved and applied 2026-10-15)

`CLAUDE.md` *Working practices* now includes:

> "If a brief's stop condition is met, stop and ask, even when proceeding looks harmless. Operations beyond the approved list (extra scans, helpers, bundled checks) are proposed, not performed."

This closes C-h.
