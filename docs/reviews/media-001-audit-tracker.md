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
| C1 | Fix "39 in ASSETS" to 38 | Applied (uncommitted) | `docs/technical/disc-contents.md`, summary |
| C2 | Narrow "intact / read without damage" to examiner-reported header+EDC pass; state what EDC does not prove; ECC not validated | Applied (uncommitted) | `disc-contents.md` summary, *Sector integrity* and *Does*; `PROJECT_STATUS.md`; `docs/technical/README.md`; inventory |
| C3 | Document the EDC algorithm reproducibly: byte range, polynomial, init, final XOR, byte order, implementation, test case | Applied (uncommitted). Includes helper source and a test vector (`123456789` → `0x6EC2EDC4`), re-run 2026-10-15 without the image. The aggregate result is still not independently reproduced. | `disc-contents.md`, *EDC algorithm* |
| C4 | Relabel D2: the Q interpretation is an unvalidated observation pending CRC; keep the descriptor 9,030 vs Mode 1 8,880 distinction | Applied (uncommitted) | `docs/technical/original-media-examination.md` §6 D2 (and D5 wording) |
| C5 | "No installer" → "no conventionally named installer identified"; filename guesses stay unverified; do not infer that dependencies come from Windows | Applied (uncommitted) | `disc-contents.md`, *What the files appear to be*; `PROJECT_STATUS.md` |
| C6 | `PROJECT_STATUS.md`: one authoritative current state; older snapshots kept as dated history | Applied (uncommitted) | `PROJECT_STATUS.md`, *Current project status*, plus historical markers |

## Chat 2 — other observations and optional items

| ID | Item | Status |
| --- | --- | --- |
| C-a | Claim C: clarify descriptor-defined vs physical data length for track 1 | Already addressed (footnote ¹ under the §3.4 track table); reinforced by the D2 rewrite |
| C-b | Distinguish ISO directory timestamps from verified manufacturing/release dates | Applied (uncommitted) |
| C-c | Q-channel CRC validation; ADR-2 Media Catalog Number decoding; more pregap-boundary checks; ECC validation; careful audio-track examination | Open (needs separate approval) |
| C-d | Physical disc or box markings; comparison against a known reference | Open (needs user action) |
| C-e | Later, separately scoped inspection of `PITSTART.EXE` (launcher / CD-dependent startup) | Open (future proposal) |
| C-f | Next task: read-only PE header / static import summary of `PITFALL.EXE`, with stated limits (verify SHA-256; DOS/PE signatures, machine, bitness, subsystem, sections, entry point, imports; record a non-PE format as observed; no disassembly, decompilation, execution, resource extraction, downloads or patching) | Open (awaiting user decision) |
| C-g | Commit-state note: "not yet committed" was outdated once pushed | Outdated / already resolved (`origin/main` = `d906553` locally as of 2026-10-15) |
| C-h | Process lesson: future briefs should separate authorized reads, optional analysis, and operations needing renewed approval | Open (process; see *Proposed process change* below) |

## Work — recommendations

| ID | Recommendation | Status |
| --- | --- | --- |
| W1 | Directory-record flag wording ("every directory and file record has flags 0x00") | Partly outdated: the committed text said "All **file** flags are `0x00`". The sentence sat beside "every directory and file record is dated", which made it ambiguous, so it was clarified anyway: file records `0x00`; `ASSETS` directory record `0x02`. The latter was read directly by the verifier on 2026-10-15. Committed in `8f881aa`; verifier observation uncommitted. |
| W2 | Replace "intact" with "all 8,880 observed Mode 1 sectors passed header and EDC validation" | Applied (uncommitted); same as C2 |
| W3 | "No installer" → "no `SETUP.EXE` or `INSTALL.EXE` listed" | Applied (uncommitted); same as C5 |
| W4 | "Other dependencies not shipped" → "external dependencies remain unknown" | Applied (uncommitted); same as C5 |
| W5 | Mark the "first examination next / not independently inspected" passage as historical | Applied (uncommitted); same as C6 |
| W6 | EDC coverage is 8,880 Mode 1 sectors, not all 9,030 descriptor-assigned track-1 sectors | Applied (uncommitted) in `disc-contents.md`, D5 and `PROJECT_STATUS.md` |
| W7 | Track-2 index finding stays "unvalidated Q-channel interpretation" | Applied (uncommitted); same as C4 |
| W8 | **Before** executable-import work: preserve a small, reviewable read-only verifier (or at least document the EDC polynomial and test vector), then do a second approved run confirming the EDC and directory results | **Done (uncommitted), approved 2026-10-15.** `tools/verify-media001.ps1` takes its expectations from the inventory. Second run: all checks PASS. Negative test: 2/2 planted errors caught, exit 1. Still open: a run by a party other than Claude, for independent confirmation. |

## Conflicting findings (not silently resolved)

| ID | Topic | Chat 2 | Work | Claude's position |
| --- | --- | --- | --- | --- |
| K1 | Proceeding when files were not at the brief's named paths | **Violation**: the brief's stop condition applied; later confirmation does not cure it | Scope-compliant ("pass with limits") | **Agrees with Chat 2.** The brief said to stop early if files were missing at the named paths. The correct action was to stop and ask, even though the subfolder was inside the approved folder. Handling of the files was unaffected. |
| K2 | Extra boundary scans, 12 full audio-sector reads, bundled EDC and `Add-Type` helper | **Concern** | Fit the approvals | **Agrees with Chat 2.** These exceeded a strict reading of "a few header reads" and of "the file listing". All were disclosed and read-only, but they should have been proposed rather than bundled. |
| K3 | What comes next | PE header/import summary of `PITFALL.EXE` | Preserve a verifier and confirm EDC/directory results first | No conflict on facts; this is an ordering choice for the user. Committing a small read-only verifier first improves reproducibility at low cost, but either order is defensible. |
| K4 | Claim B (track structure) | "Can't verify" (descriptor bytes unavailable) | "Pass" (on lead-out arithmetic) | Not a real conflict. The auditors checked different things, and both are accurate within their access. |

## Process change (approved and applied 2026-10-15)

`CLAUDE.md` *Working practices* now includes:

> "If a brief's stop condition is met, stop and ask, even when proceeding looks harmless. Operations beyond the approved list (extra scans, helpers, bundled checks) are proposed, not performed."

This closes C-h.
