# PROJECT STATUS — Pitfall: The Mayan Adventure (PC Restoration)

**Status:** Planning and research  
**Last updated:** 2026-10-14  
**Project target:** Faithful restoration of the Kinesoft Windows 95 PC edition for Windows 10/11, with an eventual browser port considered after the desktop restoration is stable.

## Goals and scope

### Primary goal

Create a legally sound, faithful, playable restoration of the Kinesoft Windows 95 PC release of *Pitfall: The Mayan Adventure* for current Windows systems.

### Working approach

- The user directs priorities and performs testing.
- Claude Code/Codex performs implementation work, documentation, analysis, and technical investigation under the user's direction.
- Preserve the original game's gameplay, presentation, audio, controls, timing, and content as closely as practical.
- Treat a browser version as a later phase; it must not compromise the Windows restoration.

### Not currently in scope

- A confirmed commercial release, distribution plan, or licensing agreement.
- Recreating, redistributing, or publishing original game assets without verified permission.
- Choosing a final engine, language, or porting strategy before evidence and source materials are available.

## Current project status

The project is at the planning/research stage. No local game media, source code, build environment, or working restoration has been confirmed available yet. No technical direction has been finalized.

**2026-10-14 — repository setup:** Added `CLAUDE.md` (permanent agent rules), `.gitignore` (blocks original game files, disc images, media, credentials, and build output), a git-ignored `private/` folder for original material, and a `docs/` structure (research, inventory, legal, decisions, technical, testing). Remote confirmed as `TheHuskinator/pitfall-pc-restoration` (private). Changes are not yet committed or pushed.

## Evidence, leads, and uncertainties

| Item | What is known | What remains uncertain / needed |
| --- | --- | --- |
| Target version | The intended reference is the Kinesoft Windows 95 PC edition. | Confirm exact release/region/build and obtain a lawful reference copy or media. |
| Technical lead | C++ with SDL3 is a possible implementation candidate. | This is not a decision; assess compatibility, architecture, tooling, and asset format first. |
| Historical research | Chris Heimlich's *The Modern Adventure* research is a useful lead. | Locate and review the relevant material; record citations and claims separately from verified facts. |
| Original developer lead | Andy Glaister is identified as an original Kinesoft developer. | Verify role/contact details and determine whether outreach is appropriate and successful. |
| Communications | Potential contact/research outreach has been discussed. | No communications are confirmed as sent; do not represent any contact as established. |
| Materials | No local media or code has been confirmed. | Inventory any user-supplied disc/image/install files, manuals, patches, screenshots, or notes when available. |

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

1. Ask the user to confirm whether they have any original PC media, disc images, installed files, manuals, patches, screenshots, or recordings.
2. Create a dated inventory of materials received; do not modify original source media.
3. Collect and cite the relevant *The Modern Adventure* material, clearly labeling unverified historical statements.
4. Verify the Andy Glaister lead and draft—not send—an outreach note unless the user explicitly authorizes contact.
5. Define a first research task: identify the exact executable/data layout and run behavior of a lawful reference copy.
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
