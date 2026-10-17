# PROJECT STATUS — Pitfall: The Mayan Adventure (PC Restoration)

**Status:** First controlled Windows 11 launch-test preparation  
**Last updated:** 2026-10-16  
**Project target:** Faithful restoration of the Kinesoft Windows 95 PC edition for Windows 10/11, with an eventual browser port considered after the desktop restoration is stable.

## Goals and scope

### Primary goal

Create a legally sound, faithful, playable restoration of the Kinesoft Windows 95 PC release of *Pitfall: The Mayan Adventure* for current Windows systems.

### Working approach

- The user owns project direction, major risks, strategy and releases, and performs interactive playtesting.
- Claude Code is the primary local implementation and reverse-engineering agent.
- **Expanded delegated authority (user-approved 2026-10-16; see `CLAUDE.md` → Roles):** Work is the delegated technical project manager and independent reviewer. Work selects bounded milestones and may approve routine changes, synthetic tests, non-destructive validation, read-only static examination with reviewed local tools, commits, pushes, merges and related technical follow-ups.
- **Milestone handoff:** Work scopes and authorizes → Claude implements and reports → Work audits significant changes/results and authorizes the next in-scope step. Batch routine wording fixes; no separate user decision for each minor change.
- **Reserved for the user:** first game execution and runtime environment/boundaries; initial mounting/extraction; software/dependency downloads or installations; spending; releases or proprietary-content publication/upload; destructive actions, account/permission changes, materially elevated security risk, major strategy changes and external contact. Later non-destructive runtime tests may be approved by Work only inside the user's explicit runtime boundaries.
- The user's word overrides Work's. Approval does not establish independent verification or redistribution rights. Preserve original material and all evidence limitations.
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

**Phase:** first controlled Windows 11 launch-test preparation. Native compatibility testing is the selected next milestone; no restoration engine or implementation architecture has been chosen.

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
- executable analysis beyond static PE headers and imports of `PITFALL.EXE`, `PITSTART.EXE` and `KILLPIT.EXE`, and static headers, imports and exports of `WAIL32.DLL` (R2.3 accepted): no disassembly, general string scanning, resource contents or export-target decoding;
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

- **Export-reading enhancement: completed and merged (2026-10-16).**
  - `tools/inspect-pe.ps1` now also reports export tables. The deferred header-comment fixes are completed in the same change.
  - **History:** draft `4c1d42c` (Work: Accept with corrections), then `7dbe873` (Work: Accept for testing).
  - **Testing:** Claude's single synthetic run at `7dbe873` gave **73/73 PASS, exit 0** (Claude-reported). Work accepted this as closing the testing step.
  - **Merge:** merged into `main` by merge commit `4a7ab30` on Work's explicit recommendation, under delegated approval.
  - **Not done (at merge time):** independent reproduction of the run; any re-run of the export-enabled version on game files; any `WAIL32.DLL` examination. *(`WAIL32.DLL` was examined afterwards; see R2.3.)*
- **R2.3: accepted by Work and merged** (2026-10-16).
  - Report `docs/technical/wail32.md`: final ACCEPT of `aae2681` after one round of documentation corrections; fast-forward merged into `main` (`af720d7` → `aae2681`) on Work's explicit recommendation.
  - Examination baseline: `main` at `af720d7`, parser blob `3c334673…`.
  - The acceptance covers the documentation and its internal consistency. Its lists were transcribed manually from on-screen output and no run transcript was retained, so transcription accuracy is not established. This was the export-enabled parser's first game-file run: one invocation on Work's explicit recommendation (delegated approval), fingerprint verified before parsing, `RESULT: OK`. All results are Claude-reported.
  - `WAIL32.DLL` is a PE32 x86 **DLL** (ImageBase `0x20000000`, linker field 2.55, subsystem 4.0).
  - **104 export entries**, each with exactly one name (98 `AIL_…`, 4 `FILE_…`, 2 `MEM_…`); no aliases, forwarders or unused entries; all targets classified in `.text`.
  - **65 static imports** from KERNEL32, USER32 and WINMM, including `waveOut*` and `midiOut*`. No `LoadLibraryA`; `GetProcAddress` is imported.
  - None of the three earlier executables statically imports `WAIL32.DLL`. Whether the game uses it is **not tested**, and R2.3 is not evidence that it does.
  - 3,072 bytes follow the last section, and a Debug directory is declared; neither was examined.
  - Discrepancy D-EXE-3: the timestamp field 1995-07-10 03:26:55 UTC is 44 days before the disc's directory date. Not interpreted.

### Next milestone: first controlled Windows 11 launch evidence

**Decision (Work, under the user's expanded delegation, 2026-10-16):** prioritize a bounded native launch test over further speculative reverse engineering. R2.1–R2.3 establish static structure and reported dependencies, not Windows 11 compatibility. No original game execution has been reported.

**Preparation evidence from the current handoff:**
- **Claude-reported, not independently reproduced:** Windows 11 Home x64; the named 32-bit Windows components are present; no CD drive or existing Pitfall installation was found by the described checks. Presence does not prove runtime compatibility.
- **Source-reviewed by Work, not executed:** scratch staging script revision 2, SHA-256 `2D1AFE08F9F7EDD2D7A673DDC36760EA43FC123B0309CC557C5DBA2C5935AF09`. Accepted for the narrowly scoped current repository-private destination, subject to the user's extraction approval. This is not proof of successful staging.
- The script uses inventory pinned at `5cc516c228a0719d20842b78b18d62c80ec56775`, validates the unique 40-file set and hashes before writing, uses create-new-only writes and checks the image afterward. Launch requires exit 0, RESULT: OK and no incomplete marker; marker absence alone is insufficient.
- A separate standard local test account is Work's recommended environment, not yet selected or created by this authorization. That option needs a bounded destination adaptation and source check; the current script writes inside the repository. A shared private test location outside the repository requires the user's explicit exception to the default private-folder policy, with access controls and no Git/cloud upload. No such exception is granted here.
- The account choice, backups/recovery arrangement, initial extraction and first execution still await the user's explicit approval. This delegation update is not that approval.

**Claude assignment — preparation only, explicitly authorized by Work:**
1. Synchronize the local checkout with the documentation update using a clean fast-forward only. First inspect local changes and ahead/behind state; preserve unrelated or unpushed work. Stop and report if the update would require resolving divergence, overwriting work or bypassing repository protections.
2. Consolidate the existing preparation into one concise launch-readiness handoff. Do not repeat completed static investigations or add tooling. Finalize the proposed account/destination arrangement; source-only adaptation of the scratch stager and narrowly scoped before/after observation helpers is allowed. Do not create accounts, change permissions or access game bytes.
3. Define observation of game-related settings, relevant file changes and application-error logs; keep raw snapshots private and share sanitized findings only. Do not grant blanket permission for arbitrary HKCU changes. State snapshot limitations and label the launcher test as sequential.
4. Prepare the single user-approval package: environment/account and recovery choice; one verified staging operation; one reviewed WAIL32 preflight on the staged copy with retained local metadata output; up to three launch attempts, at most ten minutes each (direct game, launcher if appropriate, and one useful unchanged confirmation).
5. Batch any necessary readiness documentation into `PROJECT_STATUS.md`; Work authorizes one documentation-only commit and push to `main` if needed after a clean synchronization and exact diff review. No proprietary content, credentials, raw registry dumps or absolute personal paths. Do not create a new review cycle for wording-only corrections.

**Preparation stop conditions:** unexpected local/remote divergence or conflicting work; any need for original-file access, staging, mounting, execution, installation, account/permission changes, destructive operations or a broader investigation. Report to Work; reserved decisions go to the user. Grammar-only source checks are allowed; do not execute the staging or observation scripts in this preparation assignment.

#### Launch-readiness handoff (Claude, 2026-10-16; updated after Work's source acceptance)

**Status: AWAITING THE USER'S SINGLE APPROVAL.** Nothing has been staged, mounted, extracted or executed. No game bytes were accessed for this handoff.

**Work's review (2026-10-16):**
- **What Work checked:** the actual snapshot helper (revision 2) and the setup package. Both script fingerprints matched Claude's report, and GitHub `main` was confirmed at `3b0d55d`.
- **Verdict:** both scripts are accepted for the proposed bounded use, subject to the user's setup and execution approval. Work ran neither, and source acceptance does not guarantee they work.
- **Authorized under delegation:** this status update, consolidating the approval into one package, and one documentation-only commit and push.

**Environment set up by the user (account and permission changes made by the user, not Claude):**
- **Recovery** *(reported by the user, 2026-10-16)*: a restore point was created, and important files are backed up.
- **Test account `Pitfall Test`** *(verified by Claude, read-only)*. Its name contains a space; it replaces the earlier working name `pitfalltest`.
  - It is a local, enabled account.
  - It is not a member of the Administrators group.
- **Folder `C:\PitfallTest`** *(verified by Claude, read-only)*:
  - it is a real, empty directory, not a link;
  - it is owned by the user's own account;
  - it has exactly four permission entries, all applied to subfolders and files: SYSTEM (Full control), Administrators (Full control), the user's own account (Modify) and `Pitfall Test` (Modify);
  - it has no inherited entries, and no Everyone, Users or Authenticated Users entries.

**Scripts** (held in Claude's session scratch folder, outside the repository; **neither executed**):
- **Staging script, revision 3**, SHA-256 `7C3BDA91659076C68A9D66C68A907BE17E6054F248BBC12729FCF9C081FAA7DD`. Work accepted its source.
  - The destination is fixed at `C:\PitfallTest\pitfall-cd`. The script must create it, and refuses to run if it already exists.
  - It refuses links (including junctions) and destinations under the user-profiles folder.
  - The inventory it checks against is pinned at `5cc516c`. It validates all 40 files and their fingerprints before writing anything, and only ever creates new files.
  - The disc image is checked before and after.
  - **Launch gate:** exit code 0, the line `RESULT: OK`, and no `STAGING-INCOMPLETE.txt` marker. All three are required.
- **Observation helper `snapshot-test.ps1`, revision 3**, SHA-256 `DE761EE73890426C70133576C4300F1122F0F4DD745D78E265CA569D748DFEEC`.
  - Revision 2 (`E67005F05DAE138F747BC615440B7A058497EF2730BD3264E225D0A8A182463C`) is the one Work accepted.
  - **Revision 3 changes only the account check:** the expected account is `Pitfall Test`, and the name may contain spaces, but not at the start or end. The user authorized this correction on 2026-10-16. It passes PowerShell's grammar check with 0 errors and has not been re-reviewed by Work.
  - **Who runs it and what it writes:** the user runs it inside the test account, unelevated, before and after each attempt. It reads only, and writes a new folder `C:\PitfallTest\logs\<label>-<time>\`.
  - **It refuses to run (exit code 2) when:**
    - it is the wrong account, or elevated, or the account is in the Administrators group;
    - a folder involved is a link or junction;
    - a snapshot folder with that name already exists.
  - **What it records:**
    - the account and its elevation status;
    - game-folder files with their SHA-256;
    - an export of `HKCU\Software`;
    - startup (`Run`/`RunOnce`) entries;
    - per-user VirtualStore files and `%TEMP%`;
    - Application-log errors from the last three hours.
  - **How results are reported:**
    - each observation is reported as OK, EMPTY, UNAVAILABLE or FAILED;
    - "No matching events" is kept distinct from "could not read the log";
    - the final line is `SNAPSHOT RESULT: COMPLETE` (exit code 0) or `INCOMPLETE` (exit code 1).
  - **Limits:** these are point-in-time snapshots, not continuous monitoring. Areas outside the captured locations are not observed.

**Private working-copy exception** (pending the user's approval):
- **What it covers:** the default policy keeps original material only in `private/`. The exception allows one staged copy at `C:\PitfallTest\pitfall-cd`, plus raw logs in `C:\PitfallTest\logs`.
- **Where it may live:** outside the repository, outside every user profile, and not in OneDrive or any cloud-synced folder. Access is limited to the four permission entries above.
- **Sharing:** the copy and the logs, including the full registry exports, are never committed, uploaded, shared or pasted into a chat. Only sanitized findings are shared.
- **Lifetime:** kept until this milestone ends. Deleting it later is a destructive operation, so it needs the user's direct approval at that time.

**Operating instructions** (Work's adjustments included):
1. **Folder:** setup is done and verified. Any later error or unexpected permission entry means stop.
2. **Before every use of the helper:** confirm its SHA-256 matches revision 3.
3. **Network:** the package does not technically block connections, so the user disconnects networking (for example, Airplane mode) for each game attempt. The user reconnects afterwards to pass on sanitized findings.
4. **Per attempt, inside the `Pitfall Test` account:**
   1. Disconnect networking.
   2. Take the "before" snapshot:
      ```powershell
      powershell -NoProfile -ExecutionPolicy Bypass -File C:\PitfallTest\tools\snapshot-test.ps1 -Label before-N
      ```
      Continue only on `SNAPSHOT RESULT: COMPLETE`.
   3. Launch with an explicit working folder (not by double-clicking):
      - **Attempt 1 (direct):**
        ```powershell
        Start-Process -FilePath 'C:\PitfallTest\pitfall-cd\ASSETS\PITFALL.EXE' -WorkingDirectory 'C:\PitfallTest\pitfall-cd\ASSETS'
        ```
      - **Attempt 2 (launcher, sequential**, because it inherits attempt 1's settings):
        ```powershell
        Start-Process -FilePath 'C:\PitfallTest\pitfall-cd\PITSTART.EXE' -WorkingDirectory 'C:\PitfallTest\pitfall-cd'
        ```
      - **Attempt 3:** one useful, unchanged confirmation of whichever attempt got further.
   4. Observe for at most 10 minutes, then close the game.
   5. Take the "after" snapshot with `-Label after-N`.
   6. Reconnect networking.
   7. Claude compares the before and after evidence **before the next launch**.
5. **Stop the attempt if any of these happens:**
   - a security alert;
   - instability;
   - an unexpected installation or elevation prompt (answer **No**);
   - any download or online request;
   - two minutes of unresponsiveness. End the program in Task Manager, not with `KILLPIT.EXE`.
6. **Stop further attempts if:**
   - a snapshot is not `COMPLETE`;
   - concerning changes appear, such as a new startup entry or changes to an unrelated program's settings or files.

   Changes that are allowed: the game folder, `%TEMP%`, the per-user VirtualStore, and game-related settings under the test account's `HKCU\Software`.
7. **Record:**
   - whether it launched;
   - whether graphics are usable;
   - keyboard and controller input;
   - minutes of responsive gameplay;
   - sound effects;
   - exact error text. Screenshots stay local.

   CD music is **not exercised**.

**The user's single approval** covers the items below. The user may approve only part of it.
1. Using the account and folder above as the test environment.
2. The private working-copy exception.
3. Claude's local steps:
   - copying the helper (revision 3) into `C:\PitfallTest\tools` and verifying its fingerprint;
   - one staging run, as the user's own account, unelevated;
   - one WAIL32 preflight on the staged copy with the reviewed parser (blob `3c334673…`). Its output stays in `private/test-logs`, and it is compared with R2.3: x86 DLL, 65 imports, 104 exports.
4. Up to three launch attempts by the user under the instructions above.
5. Claude examining the logs locally and reporting sanitized findings.

**Planned execution, not authorized by this entry:** after direct user approval, keep originals read-only; run only from the verified working copy, unelevated, without wrappers, compatibility settings or manual registry fixes. Stop on validation/preflight disagreement, an installation/elevation prompt, security alert, instability, observed unrelated changes or two minutes of unresponsiveness. No automatic fixes or repeated failed launches. Work may approve subsequent tests only inside the actual user-approved environment and limits, not simply because the first run occurred.

**Measurable result:** separately record launch, usable graphics, keyboard input, five minutes of responsive gameplay, sound effects and exact failure details/crash-log metadata. Without a CD device, CD music is **not exercised**, not a demonstrated compatibility failure. The next substantive Work review is launch evidence or a material safety/code change.

**Deferred unless a concrete launch failure makes them necessary:** resource enumeration, debug/trailing-byte analysis (Q16), deeper WAIL32 usage investigation (Q14), CD-audio setup, new reverse-engineering tools and engine reconstruction. Q15's audio behavior is tested through the approved runtime milestone, not inferred from imports.

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

**Current (2026-10-16):** follow *Next milestone: first controlled Windows 11 launch evidence* above.
1. Done: the preparation handoff (*Launch-readiness handoff* above). Work accepted the scripts for bounded use, and the user has set up the test account, the test folder and recovery.
2. Obtain the user's environment, extraction and first-execution approval as one bounded package. Work selects technical follow-ups; the user retains reserved decisions.
3. Gather launch evidence, then let Work prioritize the smallest evidence-backed compatibility fix. Do not choose an engine or add tooling before a concrete need is established.
4. Historical research leads remain deferred; no external contact is authorized.

**Completed (historical):**
- 2026-10-15: first read-only media examination (`docs/technical/original-media-examination.md`), audited by Chat 2 and ChatGPT Work.
- 2026-10-15: provenance reported by the user; real subfolder path adopted; read-only ISO 9660 directory inventory completed.
- 2026-10-15: `PITFALL.EXE` header/import summary (R2.1), accepted by Chat 2. Reproduced with the reviewed replacement parser (§10 of `docs/technical/executable.md`).
- 2026-10-16: PE parser milestone (`tools/inspect-pe.ps1`, its tests and documentation) accepted by ChatGPT Work. `draft/inspect-pe` was fast-forward merged into `main` (`50cf7d0` → `4ec4321`).
- 2026-10-16: R2.3 (`WAIL32.DLL` headers, imports and exports) examined by Claude (Claude-reported), accepted by Work (`aae2681`) and fast-forward merged into `main`.
- 2026-10-16: export-reading enhancement to `tools/inspect-pe.ps1` reviewed by Work, synthetic-tested (73/73 PASS, Claude-reported) and merged into `main` (`4a7ab30`).
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
4. For each meaningful code milestone, record how to build, run and test it, plus actual results and who observed them. Batch minor corrections.
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
| 2026-10-16 | Merge the reviewed export enhancement (`draft/inspect-pe-exports` at `7dbe873`) into `main` with a normal merge commit (`4a7ab30`), keeping both reviewed draft commits. | Work recommendation (delegated approval) | Work: Accept for testing; Claude-reported 73/73 PASS. Not re-run on game files; no independent reproduction. |
| 2026-10-16 | Merge the reviewed PE parser milestone (`draft/inspect-pe`) into `main` by fast-forward, keeping every reviewed commit ID in `main`'s history. | User-approved | ChatGPT Work ACCEPT of `4ec4321`. Tool results remain Claude-reported; independent byte verification is still open. |
| 2026-10-16 | Expand Work's role to delegated technical project manager: choose milestones and approve routine technical work, commits, pushes and merges; audit at milestone boundaries. | User-approved | Supersedes earlier per-task approval wording. Reserved decisions remain with the user; later non-destructive runtime tests require a user-approved environment and boundaries. Approval is not independent verification. |
| 2026-10-16 | Select first controlled Windows 11 launch evidence as the next milestone; authorize bounded preparation only. | Work decision under expanded delegation | See the current milestone assignment. No extraction, game execution, account changes or installations authorized. Defer nonessential reverse engineering. |
| 2026-10-16 | Accept staging revision 3 and snapshot helper revision 2 for the bounded first launch; the user authorizes correcting the helper's expected account to `Pitfall Test` (revision 3). | Work review (delegated) + user authorization | Source acceptance only; nothing run. The test environment, the working-copy exception, staging, the preflight and the launch attempts still await the user's single approval. |
