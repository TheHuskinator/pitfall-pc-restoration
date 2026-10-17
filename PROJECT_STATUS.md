# PROJECT STATUS — Pitfall: The Mayan Adventure (PC Restoration)

**Status:** Planning and research  
**Last updated:** 2026-10-16  
**Project target:** Faithful restoration of the Kinesoft Windows 95 PC edition for Windows 10/11, with an eventual browser port considered after the desktop restoration is stable.

## Goals and scope

### Primary goal

Create a legally sound, faithful, playable restoration of the Kinesoft Windows 95 PC release of *Pitfall: The Mayan Adventure* for current Windows systems.

### Working approach

- The user directs priorities and performs testing.
- Claude Code is the primary implementation and reverse-engineering agent.
- **Two-agent workflow (from 2026-10-16; see `CLAUDE.md` → Roles):**
  - The user is the sole decision-maker.
  - Claude Code is the local developer and reverse-engineering agent, working within authorized scope.
  - ChatGPT Work ("Work") reviews research, sources, technical claims, code and QA, and helps prepare proposals and handoffs.
  - Handoff: Claude proposes → the user authorizes → Claude completes and reports → the user passes it to Work → Work reports to the user → the user decides.
  - **Delegated approval (from 2026-10-16):**
    - Actions Work explicitly recommends, in a review the user passes on, count as the user's approval within Work's stated boundaries. That includes edits, test runs, commits, pushes and merges into `main`.
    - Still reserved for the user's direct approval: running game software or mounting/extracting disc images; installing tools; contacting anyone outside the project; and anything Work leaves as the user's decision.
    - The user's word overrides Work's. See `CLAUDE.md` → Roles.
- **Transition note:** before 2026-10-16, records used the roles "ChatGPT Chat 1–4" and "Codex / ChatGPT Work". There are no active Chat 1–4 roles. Older records below keep their original labels. Reviews recorded as "Chat 2" and as "Work" should not be counted as separate independent verifications; multiple reviews in the same Work conversation are not independent reviewers.
- These roles operate under the user's direction and the approval rules in `CLAUDE.md`.
- Preserve the original game's gameplay, presentation, audio, controls, timing, and content as closely as practical.
- Treat a browser version as a later phase; it must not compromise the Windows restoration.

### Not currently in scope

- A confirmed commercial release, distribution plan, or licensing agreement.
- Recreating, redistributing, or publishing original game assets without verified permission.
- Choosing a final engine, language, or porting strategy before evidence and source materials are available.

## Current project status

> **This section is the authoritative current state (updated 2026-10-16).** Review labels such as "Chat 2" are kept as originally recorded; see the transition note under *Working approach*. The dated sections further down are historical snapshots. Where they conflict with this section, this section wins.

**Phase:** planning/research. No technical direction, toolchain or engine has been chosen.

**Reference media — MEDIA-001**, at `private/original-media/Pitfall_The_Mayan_Adventure_ISO/` (git-ignored):

- **Provenance — Reported (user):** made from a legitimate physical copy the user owned. The user also reports a scratched physical disc, currently unreadable.
- **Verified (Claude, 2026-10-15; arithmetic confirmed in reviews recorded as "Chat 2" and "ChatGPT Work", which are not counted as separate independent verifications):** a CloneCD-style raw image of 272,313 sectors. It is a single session: 1 Mode 1 data track plus 23 tracks declared as audio. CCD and CUE agree.
- **Examiner-reported, not independently reproduced:**
  - All 8,880 Mode 1 sectors pass header and EDC checks.
  - The ISO 9660 volume `PITFALL` lists 40 files (38 in `ASSETS`, 2 at the root), including `PITFALL.EXE`, `WAIL32.DLL`, `INIT.PH` and `LEVEL00`–`LEVEL23.PH`.
  - Per-file SHA-256 values are recorded in `docs/inventory/materials-inventory.md`.
- **Open:**
  - Exact release, region and revision.
  - Who made the image, and when.
  - Audio authenticity and completeness.
  - ECC and Q-channel CRC validation.
  - The track-2 index discrepancy (D2).
  - The game's external dependencies.
  - Independent reproduction of the EDC and listing results. These are now reproducible with `tools/verify-media001.ps1`. Claude's second run passed every check on 2026-10-15, but that is not an independent run.

**Not yet done:**
- executable analysis beyond static PE headers and imports of `PITFALL.EXE`, `PITSTART.EXE` and `KILLPIT.EXE` (no disassembly, strings, resources, exports, or other executables such as `WAIL32.DLL`);
- game execution and compatibility testing;
- a working build environment or restoration code.

**Done 2026-10-15:**
- The read-only verifier `tools/verify-media001.ps1` (tracker item W8) passes all checks, and its negative test fails as designed.
- Read-only PE header and static import summary of `ASSETS/PITFALL.EXE` (`docs/technical/executable.md`):
  - 32-bit x86 Windows GUI program (subsystem 4.0). Its PE timestamp field decodes to 1995-09-15 23:53:45 UTC; the actual build time is not established.
  - 6 statically imported DLLs, 180 functions, all standard Windows: KERNEL32, USER32, GDI32, WINMM, ADVAPI32 and COMCTL32.
  - No DirectX DLL or `WAIL32.DLL` is statically imported. Run-time loading via `LoadLibraryA` is possible and untested.
  - Discrepancy D-EXE-1: the PE timestamp field is 22 days 23:52:45 **after** the disc's 1995-08-24 00:01:00 directory dates. Not interpreted.
  - **R2.1 audit (Chat 2, 2026-10-15):** "Accept with corrections". All seven corrections were applied, and the **final review verdict is ACCEPT**. Chat 2 confirmed the arithmetic and internal consistency only; the parser's reading of the bytes has not been independently reproduced.
- **PE parser preserved and tested (developed on branch `draft/inspect-pe`; merged into `main` by fast-forward on 2026-10-16, user-approved):**
  - `tools/inspect-pe.ps1`, the reviewed and synthetic-tested replacement parser, is at commit `c389278`. ChatGPT Work did two source reviews and accepted it for testing.
  - Synthetic tests: **29/29 PASS** (user-approved run).
  - User-approved re-read of `PITFALL.EXE`: fingerprint matched; **all R2.1 values reproduced**, with display-order differences only. The original import order is now recorded (`executable.md` §10.3).
  - Work accepted this as a **Claude-reported reproduction**. Claude performed both examinations, so it is not an independent confirmation.
  - The documentation for this step was committed as `21fa6a2`. It includes a repair of the garbled characters that commit `50cf7d0` introduced into the audit tracker (30 sequences across 22 lines).
  - ChatGPT Work reviewed `21fa6a2`: **Accept with corrections**, documentation only, with no parser changes. The corrections are in `4ec4321`, which Work then reviewed: **ACCEPT**, no further corrections (2026-10-16).
  - Known, documented, non-blocking: two script header comments are out of date (see `tools/README.md`). They are deferred to a separately reviewed comment-only update.

- **R2.2 done 2026-10-16** (user-approved scope; report `docs/technical/startup-executables.md`, committed on `main` as `323a03c` and `e08d2dc`).
  - **Review:** the first audit, recorded at the time as "Chat 2", gave **Accept with corrections** (documentation only). The corrections are in `6629328`.
  - **Latest result:** **Work's follow-up ACCEPT** of the R2.2 corrections in `6629328`, reviewed on GitHub at `06ee277`, with no further technical corrections.
  - Under the two-agent workflow, these are reviews from the same reviewer role, not separate independent verifications.
  - Findings:
  - Both `PITSTART.EXE` and `ASSETS/KILLPIT.EXE` are PE32 x86 Windows GUI programs (subsystem 4.0, linker field 2.55). Fingerprints were verified before parsing; `RESULT: OK` for both.
  - `PITSTART.EXE`: 92 static imports from 6 DLLs, including `MSVFW32.dll!MCIWndCreateA` (Video for Windows). That DLL is absent from `PITFALL.EXE`'s recorded static imports. Its `.rsrc` section is 96% of the file (contents not examined).
  - `KILLPIT.EXE`: 24 static imports, from KERNEL32 (23) and USER32 (`MessageBoxA`). It declares no PE Resource directory and has no `.rsrc` section. It has no static imports of `OpenProcess` or `TerminateProcess`; its `ExitProcess` ends only its own process. Its static imports therefore do not support the filename guess that it "kills" the game process. Actual behavior is not tested.
  - Discrepancy D-EXE-2: PE timestamp fields of 1995-09-16 (`PITSTART.EXE`) and 1995-07-26 (`KILLPIT.EXE`), against the disc's 1995-08-24 directory date. Not interpreted.
  - All results are Claude-reported; roles are hypotheses only.

- **R2.2 final ACCEPT recorded (2026-10-16):** the R2.2 report, technical index, audit tracker (row R2.2-F) and this file now record Work's follow-up ACCEPT, with historical labels preserved.

**Next tasks:**
1. **Export-reading enhancement for `tools/inspect-pe.ps1`.** Authorized 2026-10-16 as a draft only:
   - code, synthetic tests and the deferred header-comment fixes, written on branch `draft/inspect-pe-exports`, committed and published for Work's source review;
   - **no tests run, no game files read, no merge**.
   - Running the tests, merging and any later push each need separate authorization.
2. *(Awaiting user decision)* Static exports/imports check of `WAIL32.DLL` (R2.3), after the export enhancement is reviewed, tested and merged.
3. *(Awaiting user decision)* Resource-type enumeration for `PITFALL.EXE` and `PITSTART.EXE` (no extraction).
4. *(Awaiting user decision)* Run-time dependencies: static string leads, or execution under its own approved test plan.

**2026-10-14 — repository setup:** Added `CLAUDE.md` (permanent agent rules), `.gitignore` (blocks original game files, disc images, media, credentials, and build output), a git-ignored `private/` folder for original material, and a `docs/` structure (research, inventory, legal, decisions, technical, testing). Remote confirmed as `TheHuskinator/pitfall-pc-restoration` (private). The setup files were committed to GitHub; this earlier pending-push note was superseded on 2026-10-15.

## 2026-10-15 — Setup audit and next technical workflow

- GitHub repository `TheHuskinator/pitfall-pc-restoration` is **private**, default branch `main`; three commits and the 11 initial setup/documentation files were observed on 2026-10-15. Latest checked commit: `f1903ddbd653a7c8256a7240e2b865fccc585e41` (`Initial Claude`). No GitHub issues were found at audit time.
- `CLAUDE.md`, `.gitignore`, `PROJECT_STATUS.md`, and documentation templates are committed. This does not establish that the local Windows checkout is synchronized, that `private/` exists locally, or that development tools are installed.
- The user reports owning an original physical disc but cannot currently read it because of scratches. The current priority is obtaining a **lawful, verifiable copy of the Kinesoft Windows 95 PC files**, preferably a recovered disc or authorized replacement. Do not assume a third-party archive is authorized or pristine.
- **Preferred investigation order (proposed, not an approved architecture):** (1) inventory files and record SHA-256 hashes; (2) inspect safely/read-only; (3) test unmodified original EXE on Windows 11; (4) try documented compatibility settings and DxWnd; (5) investigate targeted fixes; (6) consider full engine reconstruction only after measuring compatibility limitations.
- The original EXE alone may be insufficient. Seek associated DLLs, proprietary `.PH` data, and disc/CD-audio content. Preserve complete reference material privately and read-only; use copies for tests.
- **Claude Desktop/Claude Code setup (planned, not verified installed):** open the local repository in the Code workspace; confirm the agent reads `CLAUDE.md` and this file; check Node.js/npm, Ghidra, Java JDK, and `morluto/rea` (REA) availability. REA is a candidate bridge between Claude and reverse-engineering tools; **verify its exact Windows and 32-bit x86 PE support** with a harmless test binary before using it on Pitfall. No installation, toolchain or engine commitment has been approved here.
- Historical research: continue to evaluate Chris Heimlich's *The Modern Adventure* materials; user is awaiting a response. Verify communication details rather than declaring them sent in the evidence log. Also investigate the Andy Glaister lead independently without contacting anyone without authorization.
- Other sources under consideration include The Collection Chamber's Windows 95/DOSBox-X package and a modern-Windows DxWnd guide. They are **leads**, not verified retail binaries or evidence of redistribution rights. Prefer the unmodified original EXE for native compatibility tests.

### Next smallest testable task (historical — completed 2026-10-15)

Claude Code should read the repository instructions and rights policy, confirm the local checkout is current, verify all four `private/original-media/Pitfall.{img,sub,ccd,cue}` paths are ignored and no proprietary files are already tracked, then record filenames, byte sizes, and SHA-256 hashes. Inspect only descriptor text and headers/structure with existing trusted tools in read-only mode; report consistency, uncertainties, and a recommended next step. Record metadata and independently written findings in `docs/inventory/materials-inventory.md` and update this status file. Stop after the report. See `CLAUDE.md` for the complete first-task boundary.

### Remaining setup checklist

- [x] Confirm the local GitHub Desktop checkout matches `main` and verify original files are excluded from version control. On 2026-10-15, local HEAD `d906553` equalled `origin/main` after a GitHub Desktop fetch; `git check-ignore` confirmed the four media files are ignored; no `private/` paths are tracked.
- [ ] Add a root `README.md` with goals, phase, and document links.
- [ ] Capture Chris outreach date/method; **historical source citations logged** in `docs/research/sources.md` (2026-10-15).
- [x] Inventory the user-reported four-file media set read-only (done 2026-10-15). Provenance, permission for use, completeness, and release identity remain open. DLL, `.PH`, and CD-audio inspection remains a later scoped task.
- [ ] Create GitHub issues for research, media recovery, rights, compatibility, and tool validation if desired.
- [ ] Validate Claude Code / Ghidra / REA installation and x86 analysis support; do not assume tool readiness.
- [ ] Evaluate Windows 11 native execution, compatibility mode and DxWnd in a documented test environment.

## 2026-10-15 — Chris Heimlich research extraction

**Completed documentation-only milestone:** Reviewed six original-port-analysis posts and the author's roadmap and recorded sources **S001-S007** in `docs/research/sources.md`. Added a research entry to `docs/research/research-log.md`, a technical summary at `docs/technical/ph-resource-formats.md`, and a prioritized outreach checklist at `docs/research/chris-heimlich-request-list.md`. The docs map and technical index link these materials.

**High-value author-reported findings (NOT independently verified against original game files):**

- `INIT.PH` shared sprite/sound segments and level-specific `.PH` resources; embedded WAV effects and CD-based music are described (S001-S003).
- Two documented `4.V4` sprite formats; palette/index and transparency encoding; later interpretation of signed X/Y render offsets; 11,568 sprites reportedly extracted (S002, S003, S006).
- Level backgrounds use 8×8 indexed-color tiles, a pool and reference matrix, vertical/horizontal flip flags and provisional priority semantics; animated tiles/parallax were not solved by the 2019 post (S004).
- Dynamic/static/collision chunks use a 16×16 positional grid, a column-offset table, row/ID pairs, and `0xFF` column end markers. Published layout parser swaps 16-bit offsets, unlike the little-endian background reader; actual byte order requires testing (S005).
- Chris describes a **private MATLAB extraction project and mapping spreadsheets** in S005/S006. Those private materials are **not in our possession** and may require permission for access/use.

**Still open (historical; the disc image was subsequently examined on 2026-10-15 — see Current project status):** The user now reports a four-file disc-image set, but it has not been independently inspected. No executable or `.PH` files have been verified or analyzed, and Chris's private research code is not in our possession. No working parser/decoder has been developed. Seeking clarification or permission from Chris is a follow-up, not a prerequisite for studying the public format notes.

**Later technical follow-up:** After the first read-only media report and approval of the next scoped task, consider executable/dependency inventory and validation of one representative `.PH` sprite and background segment. Consult `docs/technical/ph-resource-formats.md` for test cases. Original-EXE Windows 11 compatibility testing requires separate approval before execution.

## 2026-10-15 — Agent responsibilities and first media examination

- **User-approved responsibilities:** Claude Code is the primary implementation/reverse-engineering agent; ChatGPT Chat 1 coordinates, Chat 2 reviews research, Chat 3 prepares development handoffs, Chat 4 handles QA, and Codex / ChatGPT Work provides independent audit and backup. Role assignment grants no additional action permissions.
- **Repository audit:** Reviewed `main` at `58de426df74d518774ac0ab5c88d34455426e3fd`. The complete tracked tree contains documentation and `.gitignore`, with no tracked `private/` paths or original-media files observed. The local checkout and private files were not inspected.
- **Git exclusion verified from repository rules:** `/private/` covers `private/original-media/` and all contents; `*.img`, `*.sub`, `*.ccd`, and `*.cue` provide additional coverage. No `.gitignore` change is needed. Claude must still check the actual local ignore and tracked-file state before examination.
- **First-task boundary:** Metadata, SHA-256 hashes, descriptor text, and header/structure inspection only. No media modification, mounting, extraction, game/installer execution, upload, tool installation, architecture choice, or implementation. Only metadata, hashes, and independently written findings belong in repository documentation.
- **Approval preserved:** The user approved this two-file documentation update to `main`. That approval does not authorize future commits or pushes, contact, tools, or game execution. Each future push requires specific user approval under `CLAUDE.md`.
- Earlier compatibility and tooling proposals remain later possibilities, not authorization to proceed. This first-media task supersedes the earlier immediate tasks to obtain files or begin executable/PH analysis.

## 2026-10-15 — First read-only media examination: result

Full report: `docs/technical/original-media-examination.md`. Hashes: `docs/inventory/materials-inventory.md` (MEDIA-001).

- **Location:** the four files are in `private/original-media/Pitfall_The_Mayan_Adventure_ISO/`. The user confirmed this as the canonical path on 2026-10-15, and `CLAUDE.md` was updated. All four are git-ignored (`/private/`), and nothing under `private/` is tracked.
- **Provenance — Reported (user, 2026-10-15):** made from a legitimate physical copy the user owned.
- **Verified:** a structurally consistent CloneCD-style raw image.
  - IMG and SUB both hold exactly 272,313 sectors, which equals the CCD lead-out.
  - CCD and CUE agree on all 24 tracks.
  - The layout is **single-session mixed-mode**: track 1 is Mode 1 data (valid sync/headers at sampled sectors; ISO 9660 identifier present); tracks 2–24 are declared CD audio and contain non-silent sample data at sampled points.
  - SHA-256 hashes were identical before and after the examination.
- **Discrepancies:**
  - Both descriptors omit track 2's INDEX 00, while the (unvalidated) subchannel shows a 149-sector track-2 pregap. The 150 sectors involved are all zero.
  - Pregaps for tracks 3–24 are 148 sectors, consistent across all sources.
- **Unknown at the time:** who made the image and when (file timestamps 2007-03-31 — weak evidence), release/region/revision, audio authenticity/completeness, and data-sector error status (EDC/ECC not checked). *EDC was later reported passing for all 8,880 Mode 1 sectors; see the next section.*
- **Next smallest proposed task (needs user approval):** a read-only ISO 9660 directory inventory of track 1. It would record names, sizes, dates and in-memory SHA-256 per file, plus volume descriptor fields, with no mounting or extraction to disk. Optionally it could also decode the Media Catalog Number and validate Q CRCs.

## 2026-10-15 — Data-track file inventory (user-approved)

Full notes: `docs/technical/disc-contents.md`. Per-file hashes: `docs/inventory/materials-inventory.md`.

- **Examiner-reported (not independently reproduced):**
  - All 8,880 Mode 1 sectors (LBA 0–8879) pass header and EDC checks. This is strong consistency evidence, not proof of bit-perfect equivalence or authenticity. The zero-filled sectors 8880–9029 were not EDC-checked, and ECC was not validated.
  - The ISO 9660 volume is `PITFALL`, with no Joliet descriptor and blank publisher/date fields.
  - It holds 40 files (38 in `ASSETS`, 2 at the root), all with directory timestamps of 1995-08-24 (not a verified release date): `ASSETS/PITFALL.EXE`, `WAIL32.DLL`, `INIT.PH`, `LEVEL00`–`LEVEL23.PH`, `INTRO.AVI`, `KILLPIT.EXE`, `PITSTART.WAV`, four `.HLP` and four `.WRI` files, plus root `PITSTART.EXE` and `AUTORUN.INF`.
  - Every file was hashed in memory. Nothing was extracted, opened or executed.
- **Matches research:** `PITFALL.EXE`, `INIT.PH`, the `LEVEL*.PH` naming and `WAIL32.DLL` are all present, as S001 and the request checklist describe.
- **New observations:**
  - There are 24 level files.
  - No conventionally named installer is listed. Launcher and installation behavior is untested.
  - `WAIL32.DLL` is the only `.DLL` listed. External dependencies remain unknown.
- **Still unknown:** exact release, region and revision. The volume metadata is blank, so this needs a hash comparison with another known copy or markings on the physical disc/box.
- **Next proposed task (needs approval):** a read-only header and import-table summary of `ASSETS/PITFALL.EXE`, read in memory from the image. *(Historical: completed 2026-10-15; see Current project status.)*

## Evidence, leads, and uncertainties

| Item | What is known | What remains uncertain / needed |
| --- | --- | --- |
| Target version | The intended reference is the Kinesoft Windows 95 PC edition. | Confirm exact release/region/build and obtain a lawful reference copy or media. |
| Technical lead | C++ with SDL3 is a possible implementation candidate. | This is not a decision; assess compatibility, architecture, tooling, and asset format first. |
| Historical research | Six technical posts and the author's roadmap indexed 2026-10-15; published PH-format observations extracted into `docs/technical/ph-resource-formats.md`. | Validate reported formats against authorized retail files; request his private MATLAB scripts and name maps with permission. |
| Original developer lead | Andy Glaister is identified as an original Kinesoft developer. | Verify role/contact details and determine whether outreach is appropriate and successful. |
| Communications | User reports awaiting Chris Heimlich's response to an email. | Email date, address, delivery, and response remain unverified in the project record; record details when confirmed. |
| Materials | User reports a scratched original physical PC disc. Four-file image set MEDIA-001, reported by the user as made from their own legitimate physical copy, present in `private/original-media/Pitfall_The_Mayan_Adventure_ISO/`.<br>• Verified 2026-10-15: sizes, hashes and structure (single session, 1 data + 23 audio tracks).<br>• Reported: all Mode 1 sectors pass EDC.<br>• Reported: a 40-file ISO listing. | Exact release identity, completeness, audio authenticity, ECC/Q-CRC status and independent reproduction of the EDC and listing results remain open. Provenance is user-reported. |

## Sources, ownership, and rights

- Do not assume that owning a disc, image, or installed copy grants rights to distribute game code, assets, music, video, or trademarks.
- Keep all acquired original material private and use it only in a manner authorized by the rights holder and applicable law.
- Maintain a source log for every artifact: origin, date obtained, version/identifier, known license or ownership information, hash when practical, and permitted use.
- Separate independent code and newly created replacement assets from original material. Do not add original assets to a public repository unless rights are verified.
- Before public release, distribution, fundraising, or use of names/logos in promotion, identify the present rights holders and obtain appropriate legal guidance or written permission.

## Milestones

- [ ] **0. Establish evidence base:** Confirm target PC release; create source/media inventory and research log.
- [ ] **1. Rights and contact research:** Identify likely rights holders; prepare a factual contact brief; record outreach only after it is sent.
- [ ] **2. Preservation setup:** Obtain a lawful reference installation/media; document behavior with screenshots, video, save files, and test notes.
- [ ] **3. Technical discovery:** Inspect executable/install behavior and data formats; determine whether compatibility, reimplementation, or another approach is viable.
- [ ] **4. Technical decision:** Choose language/framework/build tooling based on discovery. C++/SDL3 remains one candidate only.
- [ ] **5. Windows prototype:** Establish launch, display, input, audio, file loading, and repeatable builds on Windows 10/11.
- [ ] **6. Restoration implementation:** Reproduce game systems incrementally with comparison-based testing against the reference.
- [ ] **7. Quality and packaging:** Verify full-playthrough behavior, compatibility, accessibility/basic controls, installer/packaging, and documentation.
- [ ] **8. Browser feasibility:** After Windows parity is acceptable, evaluate web packaging and browser-specific constraints as a separate project phase.

## Immediate next actions

**Current (2026-10-16)** — the authoritative technical list is *Next proposed tasks* in *Current project status* above:
1. Export-reading enhancement draft (authorized 2026-10-16; draft only, see *Next tasks* above), then Work's source review. The user decides whether the tests may run.
2. Verify the Andy Glaister lead and draft—not send—an outreach note unless the user explicitly authorizes contact.
3. Follow the two-agent handoff: Claude proposes → the user authorizes → Claude reports → the user passes it to Work → Work reports to the user → the user decides. Obtain the applicable user approval before mounting, extraction, installation, game execution, tool installation, implementation, commits or pushes.
4. Do not commit to C++/SDL3 until the technical-discovery milestone produces a short recommendation.

**Completed (historical):**
- 2026-10-15: first read-only media examination (`docs/technical/original-media-examination.md`), audited by Chat 2 and ChatGPT Work.
- 2026-10-15: provenance reported by the user; real subfolder path adopted; read-only ISO 9660 directory inventory completed.
- 2026-10-15: `PITFALL.EXE` header/import summary (R2.1), accepted by Chat 2. Reproduced with the reviewed replacement parser (§10 of `docs/technical/executable.md`).
- 2026-10-16: PE parser milestone (`tools/inspect-pe.ps1`, its tests and documentation) accepted by ChatGPT Work. `draft/inspect-pe` was fast-forward merged into `main` (`50cf7d0` → `4ec4321`).
- 2026-10-16: R2.2 (`PITSTART.EXE`, `KILLPIT.EXE`) completed. Its first audit is recorded as "Chat 2"; final result: Work's follow-up ACCEPT of the corrections in `6629328`, reviewed at `06ee277`.
- 2026-10-15: six original-port-analysis articles and the author's roadmap indexed with citations; reported findings extracted. Still open: validating them against local game files, and following up on private tools/permissions.

## Key risks

- **Rights uncertainty:** Lack of permission could prevent public distribution or use of original assets.
- **Missing reference material:** Without a verified PC build, fidelity claims cannot be tested.
- **Platform differences:** Windows 95 timing, graphics, codecs, input, and legacy dependencies may not translate directly to Windows 10/11.
- **Scope creep:** A browser port, enhancements, or replacement content could distract from faithful Windows restoration.
- **Incomplete historical information:** Developer recollections and secondary sources are valuable but must be corroborated.
- **Single-person testing bottleneck:** User-led testing needs clear build notes and small, testable milestones.

## Technical decisions pending

- Exact target build(s) and whether multiple regional/revision variants will be supported.
- Legal and practical restoration strategy: compatibility wrapper, clean-room reimplementation, port of authorized source, or another method.
- Programming language/framework (including whether C++/SDL3 is appropriate).
- Windows toolchain, minimum supported versions, rendering/audio/input layers, and packaging method.
- Asset handling, extraction policy, data format documentation, and whether replacement assets are required.
- Browser-port feasibility, toolchain, and whether it can legally and technically reuse the Windows work.

## Handoff protocol

Each work session should leave the project easier to resume:

1. Update this file with the milestone state, decisions, open questions, and the next smallest testable task.
2. Record evidence separately from assumptions. Include source, date, version, and confidence level for significant findings.
3. Keep original/reference files read-only; work on copies and retain hashes or checksums where useful.
4. For every code change, record how to build, run, and test it, plus the user-observed result.
5. Do not send external messages, publish materials, or redistribute original content without explicit user authorization and appropriate rights confirmation.
6. When a decision is proposed, document alternatives, evidence, tradeoffs, owner, and the date of approval.

## Decision log

| Date | Decision | Status | Notes |
| --- | --- | --- | --- |
| 2026-10-14 | Target the Kinesoft Windows 95 PC edition for a Windows 10/11 restoration. | Working direction | Browser port is deferred. |
| 2026-10-14 | C++/SDL3 identified as a candidate. | Pending | No implementation commitment. |
| 2026-10-14 | User directs and tests; coding agent implements under direction. | Active | Applies throughout the project. |
| 2026-10-14 | Original/proprietary material kept only in git-ignored `private/`; docs hold metadata and hashes only. | Active | See `docs/legal/rights-and-provenance.md`. |
| 2026-10-15 | Prioritize testing native Windows 11 compatibility of the original EXE before choosing full reimplementation. | Proposed workflow | DxWnd and targeted fixes to be evaluated; no engine or dependency selected. |
| 2026-10-15 | Evaluate Claude Code + Ghidra + REA for investigative work. | Proposed tooling | Windows 32-bit x86 interoperability requires validation; nothing confirmed installed. |
| 2026-10-15 | Claude Code primary; Chat 1 coordination, Chat 2 research review, Chat 3 development handoffs, Chat 4 QA; Codex / ChatGPT Work independent audit/backup. | User-approved | Responsibilities do not expand action permissions. |
| 2026-10-15 | First examine `private/original-media/Pitfall.{img,sub,ccd,cue}` read-only and stop after a metadata/structure report. | User-approved task scope | Presence, provenance, permission for use, completeness, and release identity remain to be verified; no mounting, extraction, installation, or game execution. |
| 2026-10-16 | Replace the numbered-chat roles with a two-agent workflow: the user (sole decision-maker), Claude Code (developer and reverse-engineering agent) and ChatGPT Work (independent reviewer, proposal and handoff help). | User decision | Supersedes the 2026-10-15 role entry above, which is kept as history. Historical review labels are unchanged. Reviews in one Work conversation are not separate independent reviewers. A Work verdict is not permission to act. |
| 2026-10-16 | Delegated approval: actions ChatGPT Work explicitly recommends (in reviews the user passes on) count as the user's approval, including edits, test runs, commits, pushes and merges into `main`. | User decision | Amends the workflow entry above. Still reserved for the user directly: game execution, mounting or extracting disc images; installing tools; external contact; anything Work leaves to the user. The user's word overrides Work's. |
| 2026-10-16 | Merge the reviewed PE parser milestone (`draft/inspect-pe`) into `main` by fast-forward, keeping every reviewed commit ID in `main`'s history. | User-approved | ChatGPT Work ACCEPT of `4ec4321`. Tool results remain Claude-reported; independent byte verification is still open. |
