# PROJECT STATUS — Pitfall: The Mayan Adventure (PC Restoration)

**Status:** Planning and research  
**Last updated:** 2026-10-15  
**Project target:** Faithful restoration of the Kinesoft Windows 95 PC edition for Windows 10/11, with an eventual browser port considered after the desktop restoration is stable.

## Goals and scope

### Primary goal

Create a legally sound, faithful, playable restoration of the Kinesoft Windows 95 PC release of *Pitfall: The Mayan Adventure* for current Windows systems.

### Working approach

- The user directs priorities and performs testing.
- Claude Code is the primary implementation and reverse-engineering agent.
- ChatGPT Chat 1 coordinates; Chat 2 reviews research; Chat 3 prepares development handoffs; Chat 4 handles QA planning and review. Codex / ChatGPT Work provides independent audit and backup support.
- These roles operate under the user's direction and the approval rules in `CLAUDE.md`.
- Preserve the original game's gameplay, presentation, audio, controls, timing, and content as closely as practical.
- Treat a browser version as a later phase; it must not compromise the Windows restoration.

### Not currently in scope

- A confirmed commercial release, distribution plan, or licensing agreement.
- Recreating, redistributing, or publishing original game assets without verified permission.
- Choosing a final engine, language, or porting strategy before evidence and source materials are available.

## Current project status

The project is at the planning/research stage, with Claude's first read-only media examination next. The user reports owning an original physical PC disc, currently unreadable because of scratches, and a four-file set intended for `private/original-media/`: `Pitfall.img`, `Pitfall.sub`, `Pitfall.ccd`, and `Pitfall.cue`. The local files have not been independently inspected in this audit; presence, provenance, permission for use, completeness, and exact release/region/build remain unverified. No readable reference installation, EXE, working build environment, or working restoration has yet been verified. No technical direction has been finalized.

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

### Next smallest testable task

Claude Code should read the repository instructions and rights policy, confirm the local checkout is current, verify all four `private/original-media/Pitfall.{img,sub,ccd,cue}` paths are ignored and no proprietary files are already tracked, then record filenames, byte sizes, and SHA-256 hashes. Inspect only descriptor text and headers/structure with existing trusted tools in read-only mode; report consistency, uncertainties, and a recommended next step. Record metadata and independently written findings in `docs/inventory/materials-inventory.md` and update this status file. Stop after the report. See `CLAUDE.md` for the complete first-task boundary.

### Remaining setup checklist

- [ ] Confirm the local GitHub Desktop checkout matches `main` and verify original files are excluded from version control.
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

**Still open:** The user now reports a four-file disc-image set (see current status), but it has not been independently inspected. No executable or `.PH` files have been verified or analyzed, and Chris's private research code is not in our possession. No working parser/decoder has been developed. Seeking clarification or permission from Chris is a follow-up, not a prerequisite for studying the public format notes.

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
- **Unknown:** who made the image and when (file timestamps 2007-03-31 — weak evidence), release/region/revision, audio authenticity/completeness, and data-sector error status (EDC/ECC not checked).
- **Next smallest proposed task (needs user approval):** a read-only ISO 9660 directory inventory of track 1. It would record names, sizes, dates and in-memory SHA-256 per file, plus volume descriptor fields, with no mounting or extraction to disk. Optionally it could also decode the Media Catalog Number and validate Q CRCs.

## Evidence, leads, and uncertainties

| Item | What is known | What remains uncertain / needed |
| --- | --- | --- |
| Target version | The intended reference is the Kinesoft Windows 95 PC edition. | Confirm exact release/region/build and obtain a lawful reference copy or media. |
| Technical lead | C++ with SDL3 is a possible implementation candidate. | This is not a decision; assess compatibility, architecture, tooling, and asset format first. |
| Historical research | Six technical posts and the author's roadmap indexed 2026-10-15; published PH-format observations extracted into `docs/technical/ph-resource-formats.md`. | Validate reported formats against authorized retail files; request his private MATLAB scripts and name maps with permission. |
| Original developer lead | Andy Glaister is identified as an original Kinesoft developer. | Verify role/contact details and determine whether outreach is appropriate and successful. |
| Communications | User reports awaiting Chris Heimlich's response to an email. | Email date, address, delivery, and response remain unverified in the project record; record details when confirmed. |
| Materials | User reports a scratched original physical PC disc. Four-file image set MEDIA-001, reported by the user as made from their own legitimate physical copy, present in `private/original-media/Pitfall_The_Mayan_Adventure_ISO/`; sizes, hashes and structure verified 2026-10-15 (single-session, 1 data + 23 audio tracks). | Provenance, permission for use, completeness, exact release identity, audio authenticity and data error status remain unverified. |

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

1. **Completed 2026-10-15:** first read-only media examination (see result section above). Chat 2 to review `docs/technical/original-media-examination.md`.
2. **Done 2026-10-15:** the user reported provenance (their own legitimate physical copy) and chose the real subfolder path. Next: the user approves (or not) the proposed read-only ISO 9660 directory inventory.
3. **Completed 2026-10-15:** Index six original-port-analysis articles and the author's roadmap with citations; extract reported findings. Next: validate using lawful local game files and follow up on private tools/permissions.
4. Verify the Andy Glaister lead and draft—not send—an outreach note unless the user explicitly authorizes contact.
5. Review Claude's report through Chat 2 (research), Chat 3 (next development handoff), and Chat 4 (QA) as appropriate, with Chat 1 coordinating. Obtain the applicable user approval before mounting, extraction, installation, game execution, tool installation, or implementation.
6. Do not commit to C++/SDL3 until the technical-discovery milestone produces a short recommendation.

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
