# PROJECT STATUS — Pitfall: The Mayan Adventure (PC Restoration)

**Status:** CD-ROM message located as string-table entry 227 (accepted); Ghidra downloaded (not run); stage 1a source preparation authorized, not started  
**Last updated:** 2026-10-21  
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

> **This section is the authoritative current state (updated 2026-10-21).** Review labels such as "Chat 2" are kept as originally recorded; see the transition note under *Working approach*. The dated `##` sections further down are historical snapshots. Where they conflict with this section, this section wins. Within this section, milestone subsections are in date order, and a later subsection supersedes an earlier one. The current position is *Session handoff (2026-10-21)*, which summarizes *Start-up message location and resource mapping*.

**Phase:** native Windows 11 compatibility diagnosis.
- **Earlier exploratory session:** a separate-account session opened the game window but did not reach gameplay.
- **Existing-account runs:** three supervised launches in the user's own account, unelevated:
  - baseline 1;
  - a confirmation run;
  - a run with a data-only disc image mounted.
- **Where all three stopped:** each stopped after the message "Pitfall must be played using the CD-ROM." (user-reported) and exited with code 0 (verified). The mounted data-only disc did not get past the message; why is not established.
- **Where the message text is stored:** two read-only searches of `PITFALL.EXE` (accepted by Work, 2026-10-21) found the CD-ROM sentence stored once, as the complete text of string-table entry **227**. The 256-colour warning is entry **17**. This shows where the text is stored, not which code uses it. See [startup-messages.md](docs/technical/startup-messages.md).
- **Next step:** code analysis to locate uses of string 227.
  - **Proposal:** revision 2 was accepted by Work.
  - **Tools:** with the user's approval, Ghidra 12.1.4 and Temurin JDK 21 were downloaded, verified and extracted (Claude-reported). Neither has been run.
  - **Now:** Work has authorized *source preparation* for stage 1a: synthetic fixtures, the analysis script and a test harness, for review.
  - **Still awaiting separate approval:** any tool launch, synthetic execution and game-file analysis. No code analysis has been done.
- **Not chosen:** no restoration engine or implementation architecture has been chosen.

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
- executable analysis beyond static PE headers and imports of `PITFALL.EXE`, `PITSTART.EXE` and `KILLPIT.EXE`, static headers, imports and exports of `WAIL32.DLL` (R2.3 accepted), and (2026-10-21) a search for two fixed start-up sentences in `PITFALL.EXE` with metadata-only mapping of their resource locations: no disassembly, general string scanning, other resource contents or export-target decoding;
- a controlled, reproducible launch-to-gameplay success (the first exploratory execution is recorded below);
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

### Next milestone: one attributable baseline in the existing Windows account

**User decision (2026-10-16):** use the existing Windows account rather than a separate testing account. Preserve the completed separate-account session as evidence; do not restart media preparation. The account choice is accepted. **No new game launch is authorized by this plan update:** the first run in the changed environment requires the user's explicit approval of the bounded run below.

#### Evidence and review

- [Launch session 1](docs/testing/launch-attempt-1.md), originally published at `1322174`: the user ran `PITFALL.EXE` several times, initially without settings and then with Windows 95 / reduced-colour settings. `PITSTART.EXE` was not run.
- **Claude-reported:** staging succeeded and all 40 working-copy files matched the inventory; the original image remained unchanged; the single WAIL32 preflight matched R2.3. No re-extraction or repeated WAIL32 parsing is needed for this environment change.
- **Claude-observed / user-reported, not independently reproduced by Work:** the window and 256-colour dialog appeared; the user reported a CD-ROM message; a `dispdib.dll` dialog, four access-violation events (two each naming `AcGenral.DLL` and `winmmbase.dll`) and a freeze followed in the multi-launch session. No gameplay was reached. Per-launch settings and event correlation are unavailable.
- **Work verdict: ACCEPT WITH CORRECTIONS, applied to the report.** This is useful exploratory evidence, not one controlled attempt. A faulting module does not identify the root cause; named-key filtering cannot prove no game registry writes; unchanged captured areas cannot prove no harm elsewhere. COMPLETE snapshots are successful observations, not a safety certificate.
- **Open hypotheses:** whether the CD warning is the blocking check; whether reduced colour alone helps; whether Windows 95 mode changes the path leading to the DLL error; the cause of each crash. Do not present these as diagnoses or install a DLL on the strength of its name.
- Raw logs and screenshots stay local. Work's review covers the sanitized report and Claude handoff, not original files, screenshots or raw registry exports.

#### Existing-account environment and precautions

- Use the user's existing local account in a **normal, unelevated session**. Administrator-group membership alone is not elevation; the helper must reject an elevated process, not reject this account merely because it belongs to Administrators.
- Keep the working copy at `C:\PitfallTest\pitfall-cd`, tools under `C:\PitfallTest\tools`, and logs under `C:\PitfallTest\logs`. The previously user-approved private working-copy exception is retained. Keep them outside Git/cloud uploads; preserve original media read-only.
- No new account, reinstall, restaging, permission reset or account deletion is required. Leave the old `Pitfall Test` account and its compatibility settings/logs untouched.
- **Microsoft Defender stays enabled.** Check protection status read-only; do not add exclusions or disable/bypass detections. Stop if protection is disabled, its required status cannot be established, or it raises an alert; report rather than changing security configuration.
- Recommend confirming a current backup of important personal files. Prior backup/restore-point reports remain user-reported, not independently verified; a restore point is optional and is not a personal-file backup.
- The everyday account exposes more personal state than the test account. Close unrelated documents/apps as practical. Minimize logging: no full `HKCU\Software` export, personal-folder crawl or account-wide registry-value dump. Record exact game-path compatibility settings, relevant startup-change indicators and identified game-related keys; retain only locally and report sanitized differences. Unknown changes are not automatically attributed to the game.
- Preserve the offline baseline during the actual attempt: disconnect both Ethernet and Wi-Fi as applicable, then reconnect after the game has stopped. Defender remains enabled. Offline use does not isolate the filesystem; no firewall or permanent network configuration changes are requested.

#### Claude assignment — preparation authorized by Work

1. Safely synchronize with this documentation commit: inspect dirty/unpushed work and remote state, then fast-forward only if clean. Stop on divergence or conflicting work; do not discard anything.
2. Adapt the observation helper in scratch for the existing account: retain exact-account, unelevated-process, folder/link, no-overwrite and explicit failure checks; remove the standard-account membership requirement; replace the full personal-registry export with the narrow observations above. Scope crash events to the run's recorded start/end times, application path and PID/start time where available. Keep the output local.
3. Use source/grammar checks and harmless synthetic validation with mocked account/registry inputs as needed, without game execution or collection of broad personal data. Record the new helper fingerprint and a compact source-change summary. This is one safety-focused adaptation, not a new tooling project; Work checks the changed guards/privacy behavior before use.
4. Perform only essential read-only preflight using existing tools: correct account and non-elevation, Defender status, working-folder metadata/access, SHA-256 of the 40 existing working-copy files against the pinned inventory, and compatibility settings for the exact game/launcher paths in the current user's and machine-wide applicable locations plus `__COMPAT_LAYER`. Claude may hash the working copy locally; Work does not access game bytes.
5. Do not assume the old account's `WIN95/256COLOR` settings apply to the existing account. Record the effective explicit settings. Do not change either profile or machine-wide settings automatically. If any explicit layer affects the proposed baseline, stop and propose a precise, reversible per-application adjustment; no global reset or administrator workaround.
6. Report readiness for **one** existing-account direct launch, with no new installation or research prerequisite. Batch documentation corrections into `PROJECT_STATUS.md` and, if needed, the existing test report. Work authorizes one documentation-only commit/push after diff and state checks; preserve raw evidence and history.

**Preparation stop conditions:** unexpected repository divergence; modified/missing working-copy files; wrong/elevated account; link/path mismatch; ambiguous compatibility state; security alert/disabled protection; need for new software, extraction/mounting, permission/account changes or broader personal-data collection. No live game run, new image conversion, full registry export, automatic cleanup, compatibility toggle or system change is included in this preparation authorization.

#### Preparation result (Claude, 2026-10-16) — ready for Work's check

All items below were checked by Claude on this PC, read-only unless stated. Nothing was launched, and no settings, permissions or files were changed outside Claude's scratch folder. Not independently reproduced by Work.

- **Sync:** fast-forwarded from `1322174` to `94967f8`. No local changes; no divergence.
- **Account** *(verified)*:
  - it is the user's existing account, at Medium integrity level, and is not elevated;
  - its Administrators membership is "deny only" in this session.
- **Microsoft Defender** *(verified, `Get-MpComputerStatus`)*:
  - service, antivirus, real-time, behaviour-monitoring and download-scanning protections are all on;
  - tamper protection is on, and the running mode is Normal;
  - signatures were updated on 2026-10-16;
  - no detections are on record, and Windows Security Center lists only Windows Defender.

  Nothing was changed.
- **Working copy** *(verified)*:
  - `C:\PitfallTest`, `pitfall-cd`, `ASSETS`, `tools` and `logs` are real folders, not links;
  - the permissions are unchanged (the same four entries); the user's account has Modify;
  - exactly 40 files are present, and all match the pinned inventory (`5cc516c`) by path, size and SHA-256, with no extras and no links;
  - `PITFALL.EXE` is `36047291…1E74BFFA86`;
  - no game process is running.
- **Compatibility settings for the user's account** *(verified)*:
  - no `AppCompatFlags\Layers` value for `ASSETS\PITFALL.EXE` or `PITSTART.EXE`, checked in both the per-user and machine-wide locations and both registry views;
  - no game-named `AppCompatFlags\Custom` entries;
  - `__COMPAT_LAYER` is empty in the process, user and machine environments;
  - no game-named Program Compatibility Assistant records.

  The `WIN95 256COLOR` layers exist only in the separate `Pitfall Test` account, which is untouched and does not affect this account.

  **Limitation:** Windows' built-in compatibility database (fixes Windows applies automatically to known programs) cannot be inspected with the existing tools, so a built-in fix for `PITFALL.EXE` is neither established nor ruled out.
- **Game-named registry keys:** `Software\Activision` exists in the per-user and machine-wide settings, holding only an unrelated `Call Of Duty` subkey. No Kinesoft keys, and no game-named registry VirtualStore keys.
- **New helper `baseline-run.ps1`, revision 1**: *superseded by revision 2 (see Helper correction batch below); Work found revision 1 not launch-ready.* (scratch only; **not executed**; for Work's check before use), SHA-256 `0BAD8EACB210784D4B4BD7A64D46D6283D7B2DCC36237456A35410CC27BA08D5`. Adapted from the separate-account snapshot helper, revision 3.
  - **Phases:** each runs once per run folder.
    - `before` creates a new run folder `logs\baseline-<time>`.
    - `launch` runs only after a COMPLETE `before`, only once per run, and only while no physical network adapter is up. It starts `PITFALL.EXE` once (`Start-Process`, working folder `ASSETS`, no layer), records the process ID and start time, waits for exit with a 10-minute reminder (it never ends the game itself), and records the exit time and code.
    - `after` runs only once no `PITFALL.EXE` is running. It repeats the observations, collects crash events and compares before with after.
  - **Kept guards:**
    - exact account (default: the user's own);
    - non-elevation (no elevated token and Medium integrity level);
    - link and folder checks; create-new-only writes;
    - explicit OK / EMPTY / UNAVAILABLE / FAILED per observation;
    - exit codes: 0 COMPLETE, 1 STOP, 2 precondition failed.
  - **Removed:** the standard-account (no Administrators membership) requirement.
  - **New guards:**
    - `__COMPAT_LAYER` must be empty in the process, user and machine environments;
    - no explicit layer may be set for `PITFALL.EXE`;
    - Defender's protections must be on;
    - `PITFALL.EXE` must match the pinned SHA-256;
    - only one launch per run.
  - **Privacy:** the full `HKCU\Software` export is replaced by narrow observations.
    - **Registry, stored as value-data SHA-256 hashes rather than values:**
      - game-path compatibility settings;
      - Activision and Kinesoft keys, per-user and machine-wide;
      - the per-user registry VirtualStore;
      - top-level `HKCU\Software` key **names**;
      - `Run`/`RunOnce` entries;
      - game-named `MuiCache`, Program Compatibility Assistant and DirectInput records.
    - **Files and devices:**
      - Startup-folder file names;
      - Windows `*.ini` metadata;
      - display, audio and input device state.
    - **Since the launch only:** `%TEMP%` and file-VirtualStore items written since the launch, capped at 100 each.
  - **Crash events:**
    - Application Error, Application Hang and Windows Error Reporting events from the launch time onwards;
    - each is classified as `run` (path, process ID and start time all match) or `name` (mentions `pitfall.exe` only).
  - **Before/after comparison verdicts:**
    - STOP: a changed compatibility setting, a changed startup entry, or a new Defender detection;
    - REVIEW: game files, game keys, Windows records or display/audio/input state changed. These are not attributed to the game automatically.
  - **Statically listed commands that can write:** creating the run folder, create-new file saves and the single `Start-Process`. There is no `Set-*`, `Remove-*` or `reg.exe`.
  - **Checks:** PowerShell grammar check, 0 errors. Synthetic tests `test-baseline-run.ps1` (SHA-256 `3E066731D497C8D4F2D07A9513B9C8F9CA32643025804C62C178E022B4135717`): **31/31 PASS**. They load only the helper's pure functions, using made-up inputs (no game run, no personal data). Covered: integrity levels including an unelevated Administrators member, the account and run-name patterns, layer matching, event attribution in both message formats, data hashing, the change verdicts, and refusing to overwrite a file.
- **Readiness:** no installation, extraction, account, permission or settings change, and no further research, is needed for the one baseline launch.
  - **Remaining steps before the user's approval request:** Work's check of the helper; then copying it to `C:\PitfallTest\tools` with its fingerprint verified.
  - **What the user does on the day:** close unrelated documents and apps; confirm a current backup; disconnect Wi-Fi and Ethernet before the `launch` phase; reconnect after the `after` phase.

#### Helper correction batch (Claude, 2026-10-17) — revision 2 for Work's independent review

Work's review of `1125fe6` found revision 1 **not launch-ready**, with four blockers. Revision 2 addresses them in one bounded batch, in scratch only. No game run, no game-file access, no installation and no settings change; the tests use mocks and synthetic fixtures only.

- **`baseline-run.ps1`, revision 2** (not executed): SHA-256 `B9B56E5E18088DD8EEE7B400E056CB674DB8D04EED25B432A349D7DE5575DEE2`. It supersedes revision 1 (`0BAD8EAC…`).
- **`test-baseline-run.ps1`**: SHA-256 `6C4953A74A7EB7886D179AFA15438B02209133266E082D8225445887FFB57A8A`. Result: **104/104 PASS**.

**Blocker 1 — narrower evidence:**
- **Removed:** reading the unrelated Activision subtree; the whole-subtree registry VirtualStore listing; the list of top-level `HKCU\Software` names; the recursive `%TEMP%` and file-VirtualStore scans; the clear-text `MostRecentApplication` value.
- **Registry kept, game-specific only:** only *game-named* subkeys are read. Game-named means matching pitfall, pitstart, killpit, mayan or kinesoft. They are looked for under `HKCU\Software`, `HKLM\SOFTWARE` (both views), the Activision vendor keys and the registry VirtualStore. Values are stored as SHA-256 hashes, and other subkey names are not recorded.
- **Startup checks kept:** `Run`/`RunOnce` and Startup-folder entries, stored as hashes of names and data. Game-named entries are also recorded by name.
- **Other observations kept:**
  - game-named Windows records (`MuiCache`, Program Compatibility Assistant and DirectInput entries);
  - `WIN.INI`/`SYSTEM.INI` metadata in the Windows folder and the per-user VirtualStore;
  - game-named top-level `%TEMP%` entries written since the launch.

**Blocker 2 — launch-time safety:**
- **Re-checked immediately before process creation:**
  - Defender protections: service, antivirus, real-time, behaviour monitoring, download scanning and on-access, plus Normal running mode;
  - Defender detections: none new since the before phase, and none naming the test folder;
  - compatibility state; network; running processes; the executable's hash.
- **STOP:** any game-named or ambiguous layer (another copy's path, or the launcher), any game-named `Custom` entry, any `__COMPAT_LAYER` value and any unreadable location.
- **Fail closed:** every launch-time check that throws or returns nothing blocks the launch. The gate logic is a separate pure function, which the tests exercise.

**Blocker 3 — evidence after the test:**
- **Still mandatory** (refuse and record nothing): the account, non-elevation and safe output paths.
- **Recorded as STOP, while the remaining safe observations continue:**
  - `__COMPAT_LAYER` or compatibility entries appearing after the launch;
  - Defender being turned off;
  - new detections;
  - unreadable sources.

**Blocker 4 — immediate exits and crashes:**
- **Before creation:** the launch-request time is saved before the process is created.
- **Process details:** the handle, ID, start time, exit time and exit code are each read separately, through their getter methods so the failure reason is kept. Anything not retrievable is recorded as "unavailable (reason)" and is never treated as zero.
- **Waiting:** if no handle is held, waiting falls back to polling by process name. Start-Process and wait failures are recorded.
- **Classification:** crash events are classed as `run`, `run (linked by report id)`, `uncertain` (path matches but process details are unavailable) or `name`. Uncertain attribution produces explicit REVIEW lines.
- **Format:** crash events are written as **structured fields** (application or program, versions, module, exception code, fault offset, process ID, start time, paths, hang type, event name, fault bucket, signature P1–P9 and report ID). If no field is recognised, only a message hash is kept. This replaces the 800-character truncation, and WER attached-file paths are not captured.

**Tests that actually ran (104):** they load only the helper's functions and constants, with mocked readers and temporary folders.
- **Kept from revision 1:** integrity levels, name patterns, hashing, the change verdicts and refusing to overwrite a file.
- **Compatibility and launch gate:**
  - 8 compatibility-blocker cases;
  - the gate passing when all checks pass;
  - 10 fail-closed cases (each launch-time check missing);
  - each Defender protection off, and passive mode;
  - a new detection, a test-folder detection, the network still up, and a compatibility blocker.
- **Launch refused before creation (16 flows):** each checks exit code 2, Start never called and no launch record. They cover:
  - protection or detection changes between the before phase and the launch;
  - unreadable or null Defender, detection, compatibility, network, running-process and hash checks;
  - ambiguous and custom entries, and `__COMPAT_LAYER`;
  - the game already running, a changed hash, and a missing before record.
- **Successful launch:** the request is persisted before creation, and a second launch in the same run is refused.
- **Process-detail edge cases:**
  - immediate exit with exit code `0xC0000005`;
  - all process details failing, or yielding nothing;
  - no process object returned;
  - Start-Process failing (relaunch then refused);
  - waiting failing.
- **Crash parsing:** Application Error, Hang and WER messages parsed; run, uncertain, name and none classification.
- **After phase:**
  - `__COMPAT_LAYER` appearing, Defender turned off with a new detection, and unreadable registry plus event log. In each case STOP is recorded and the remaining evidence is kept.
  - A startup change gives STOP; a new game key gives REVIEW only.
  - Unavailable process details give uncertain attribution.
  - WER events are linked by report ID, and unrelated events are omitted.
  - The after phase is refused while the game is running, when the running state is unknown, or without a launch record.
- **Mandatory account and folder failures:** a wrong account, elevation, unreadable identity, a link folder, unknown link state and an unreadable folder.

**Not tested (real readers only run on the actual launch day):**
- the registry, Defender, event-log, network and process readers against the real system;
- `Start-Process`;
- the real waiting loop and 10-minute reminder;
- the script's top-level `Stop-Pre` / `exit` path.

The mocks model real getter failures through getter methods. That this matches live `Process` behaviour was checked only on a harmless `FileInfo` object.

**Remaining limitations:**
- **Built-in compatibility database:** Windows' built-in shim database still cannot be inspected.
- **Differently named game data:** game data under names that don't match the pattern would not be seen. This is the accepted trade-off of the narrower collection.
- **Unattributed changes:** unknown changes are not attributed to the game.

**Readiness recommendation:** revision 2 is ready for Work's **independent source review**, not yet for use. After Work accepts it, Claude copies it to `C:\PitfallTest\tools`, verifies the fingerprint and asks the user for the separate, explicit approval of the first existing-account launch.

#### Work review of revision 2 and installation (2026-10-17)

- **Work verdict: ACCEPT** of `baseline-run.ps1` revision 2 for **one supervised existing-account baseline**, subject to the user's explicit launch approval. Passed on by the user.
  - Work checked both submitted scripts against their SHA-256 fingerprints in the local review folder.
  - Work confirmed that the review documentation was committed and pushed at `c972450`.
  - The 104/104 synthetic test result remains Claude-reported. Work's acceptance is a source review, not an independent run of the helper.
- **Review delivery:** from this batch on, files for Work's review are placed in the git-ignored `private/work-review/<date-topic>/`. Its `README.md` lists each batch with its fingerprints and status. Batches are never edited after listing; only Claude-written files go there, never game material, raw logs or personal data (user request, 2026-10-17).
- **Installed** *(verified by Claude)*: the reviewed copy was copied to `C:\PitfallTest\tools\baseline-run.ps1` with a copy that refuses to overwrite; no file of that name existed there before. Installed SHA-256 `B9B56E5E18088DD8EEE7B400E056CB674DB8D04EED25B432A349D7DE5575DEE2` (43,699 bytes) matches the reviewed file. The tools folder now holds this helper and the earlier separate-account `snapshot-test.ps1`, unchanged.
- **Operating limitations (from Work's review):**
  - **The 10-minute limit is a reminder, not an automatic stop.** The helper never ends the game. The user must watch the run and end only the identified `PITFALL.EXE` process if a stop condition is met or the limit is reached.
  - **Helper exit code 0 does not mean the game worked.** `SNAPSHOT RESULT: COMPLETE` means the helper's own observations succeeded. Whether the game reached graphics, input or gameplay is scored separately from the user's observations.
  - The real system readers, `Start-Process`, the waiting loop and the top-level exit path run for the first time on the launch day (see *Not tested* above).
- **Not done:** no game launch, restaging, installation, compatibility change or new investigation.

#### Baseline 1 result and Work review (2026-10-17)

- **Run:** the user approved and ran exactly one supervised launch with the installed helper (run `baseline-20261017-033013`, kept local). Report: [existing-account-baseline-1.md](docs/testing/existing-account-baseline-1.md).
- **Result:**
  - The 256-colour warning appeared, then a CD-ROM message; after that message was dismissed, the game closed by itself (reported).
  - The process ended with exit code 0 about 13.5 seconds after it started (verified). No game crash events were found in the observed window.
  - The only difference found in the captured observations was Windows' `MuiCache` record for the program.
- **Work verdict: ACCEPT with minor documentation corrections**, applied in the published report:
  - the CD-ROM check is the leading **suspected** blocker, not a proven cause;
  - a deliberate programmed exit is an inference;
  - the unchanged DirectInput record does not establish whether input set-up occurred;
  - the displayed 13 seconds is clarified against the timestamps (whole-second display of 13.54 s).
- **Next step (Work):** one **unchanged confirmation launch** to capture the exact wording, title, buttons and order of the 256-colour and CD-ROM dialogs. Work's assignment states it is the confirmation run Work already recommended, not an additional authorization. Conditions:
  - same helper revision 2, account, working copy and `ASSETS` working directory;
  - unelevated, offline, Defender on, no compatibility settings;
  - before and after observations;
  - the user launches and observes; at most 10 minutes, with the usual stop conditions;
  - no second launch, setting change, launcher, mounting, extraction, download, installation or replacement DLL.
- **No static-analysis project:** the reviewed PE inspector cannot establish the CD-check control flow.
- The result is to be delivered as a sanitized report in a new dated `private/work-review/` batch.

#### Confirmation run result and Work review (2026-10-17)

- **Run:** one unchanged confirmation launch (run `baseline-20261017-154823`, kept local). Report: [existing-account-confirmation-1.md](docs/testing/existing-account-confirmation-1.md).
- **Dialogs**, exact text copied from each message box, in this order:
  1. `Pitfall`: "Pitfall must be played in 256 color mode for optimum performance." [OK]
  2. `Pitfall`: "Pitfall must be played using the CD-ROM." [OK]
- **Ending:** after OK on the second dialog, the game closed by itself (reported), with exit code 0 and no game crash events found (verified). No difference was found in any captured observation. This reproduces baseline 1.
- **Work verdict: ACCEPT.** Work checked the report against its full SHA-256 and reviewed the sanitized report only. The exact media requirement remains unknown.

### Next milestone: data-only disc image and mounted-disc test (preparation only)

**Work recommendation (2026-10-17):** prepare a **data-only ISO** of the existing image's data track and **one mounted-disc launch**, rather than another unchanged launch or broader reverse engineering. Windows' built-in disc-image mounting means no virtual-drive software is needed.

- **Claude is authorized to prepare, not execute:**
  - a proposal and conversion-script source, based on the committed media documentation;
  - the conversion keeps the data track's filesystem and volume label;
  - source-integrity checks, a new private output file, no overwrites, and verification against the 40-file inventory;
  - one planned launch of the **same working-copy executable and working directory**, changing only the presence of the mounted disc.
- **Excluded from the plan:** AutoPlay, `PITSTART.EXE`, any installer and anything run from the mounted image.
- **Limitation:** this test **does not reproduce the audio tracks or test CD music**.
- **No original-media access** is authorized by this preparation assignment. The preparation goes to a new `private/work-review/` batch.
- **Reserved for the user:** creating the ISO, mounting it and testing in that changed environment each require the user's explicit approval.
- **Reading the outcome:** a pass would show that the mounted data disc satisfies the immediate requirement. A failure gives a specific reason to investigate the CD check. Neither outcome justifies downloading DLLs or rebuilding the engine.

#### Network-connected testing and helper revision 3 (2026-10-17)

- **User decision:** future tests run with the network connected. The helper's network-disconnection launch gate is removed, and network state is recorded as context.
  - Defender, unelevated execution, working-copy checks, narrow logging and all other stop conditions stay.
  - No firewall rules, exclusions or system changes.
  - If the game asks for network or firewall permission, or opens an online service, stop and report; do not approve it.
  - Baseline 1 and the confirmation run remain documented as **offline**. Future runs record **network connected**, so comparisons acknowledge the changed condition.
- **`baseline-run.ps1` revision 3** (`31524868…FDD90`; tests 107/107, Claude-reported).
  - **Work verdict: ACCEPT.** The diff is bounded: the gate is removed, connectivity is recorded and the prompt stop instruction is added. Other protections are unchanged.
  - Network status describes physical adapters, not proven internet access.
  - Not yet installed; how it is installed beside revision 2 is an open point in the mounted-disc proposal.

#### Mounted-disc preparation: review and correction (2026-10-17)

- **Revision 1** (local review batch `2026-10-17-mounted-disc-prep`). **Work verdict: corrections required before use.** The conversion approach was found reasonable; three findings:
  - **A. AutoPlay:** the check only rejected handler names containing "AutoRun" and treated absent values as safe. The post-mount process check is too late to prevent an automatic launch. AutoPlay safety must be established before mounting; any setting change needs the user's approval.
  - **B. Finalisation:** the ISO and its hash record were published before the final source-image check, so a failed conversion could leave an apparently usable ISO.
  - **C. Folders:** link and parent-folder protections were incomplete in the disc check (`private\derived`, `C:\PitfallTest`).
- **Revision 2** (batch `2026-10-17-mounted-disc-prep-r2`; tests 79/79, Claude-reported, synthetic only). Submitted for Work's review.
  - **A:** a new read-only `pre-mount` check accepts AutoPlay only if it is verifiably off: `DisableAutoplay = 1`, or a software-disc action of exactly "Take no action". Every other state is a STOP. The proposal asks the user to turn AutoPlay off in Settings for the test and back on afterwards.
  - **B:** the source is re-checked before publishing, and a completed-conversion record is written last. Any failure leaves an INCOMPLETE marker, and nothing is deleted. Both checks refuse an ISO without a valid record.
  - **C:** every folder in every phase is checked for links, outputs are confined, and the report is written only into a verified real logs folder. Testing showed revision 2's first draft wrote its report through a linked logs folder; this is fixed.
  - **Wording corrected:** Git ignores `private/`; staging checks must still exclude proprietary content.
- **Still reserved for the user:** creating the ISO, the AutoPlay switch, mounting and the launch.
- **Revision 2 review (Work):** A and B fixed. One path-safety correction was required: after rejecting a path, the error handler could still hash the source through it, and the disc check still read the ISO and its record.
- **Revision 3** (batch `2026-10-17-mounted-disc-prep-r3`):
  - Folder validation is a prerequisite to every read and write, and stops at the first rejected folder.
  - Tests 83/83 (Claude-reported, synthetic) assert zero source, ISO and record accesses and no report through rejected paths, with positive controls. Run against revision 2, the new tests fail 8 cases.
  - **Work verdict: ACCEPT for the proposed mounted-disc test, subject to the user's explicit approval.** Work reviewed the source and tests without running them or accessing original media.

| Accepted file (mounted-disc revision 3) | SHA-256 |
|---|---|
| `make-data-iso.ps1` | `1F8BD327D422770C0CA22E615C1CF811E01512569522D22D2AC68167DBBB3B61` |
| `test-make-data-iso.ps1` | `30C89F7CF93A4CB2E354A2871B74AE79C3AC8FADA5CBC1402A37A6EB73700A2D` |
| `mounted-disc-proposal.md` | `34F59F9FA9C504C0D08FDBC9A579C067442CAF0D8B9B2BA70B00A496128C9156` |

- **Helper revision 3 installed** *(verified by Claude, 2026-10-17)*: `C:\PitfallTest\tools\baseline-run-r3.ps1`, copied only because no file of that name existed. SHA-256 `315248685186A97ABED61573C3158233A0F3F41EBA1195D87EDB214A0B8FDD90` matches the accepted file. `baseline-run.ps1` (revision 2, `B9B56E5E…`) is untouched. All three phases of the next test use `baseline-run-r3.ps1`; its printed "Next:" hints still name revision 2 and are to be ignored.
- **`make-data-iso.ps1`** is run directly from its review batch folder, after its fingerprint is checked; it is not copied elsewhere.
- **The user's one combined approval** for the five actions below was given on 2026-10-17 ("yes, I approve all five"), used once, and is now spent. See *Mounted-disc result and Work review*. Work's acceptance did not itself authorize the actions.
  1. One data-only ISO creation.
  2. Switching AutoPlay off temporarily (the user does this).
  3. Mounting, only after the pre-mount check passes.
  4. One supervised launch, after the mounted-disc check and the before snapshot pass.
  5. Ejecting the ISO, then restoring the recorded previous AutoPlay setting.

  Conditions: network may stay connected, Defender stays on, everything runs unelevated, and any failed check, unexpected prompt or stop condition means stop, with no automatic retry. CD music remains outside this data-only test.

#### Mounted-disc result and Work review (2026-10-17 to 2026-10-19)

- **Run:** the five approved actions were completed once on 2026-10-17 (run `baseline-20261017-172712`, kept local). Report: [existing-account-mounted-disc-1.md](docs/testing/existing-account-mounted-disc-1.md), revision 3.
- **Result:**
  - A data-only ISO was mounted by Windows as `E:`, labelled `PITFALL`, with all 40 files matching (verified).
  - The game was started directly from the hard-disk working copy, not through `PITSTART.EXE`.
  - The same two dialogs appeared, and the game closed by itself (user-reported).
  - Exit code 0 after 25.84 s; no matching crash events in the observed window; no before/after difference in the captured observations (Claude-verified).
  - AutoPlay was restored, but its stored value is now absent where it was `0` before (recorded separately).
- **Interpretation:** the failure does **not** establish an audio-track requirement. Six candidate explanations (H1–H6) remain compatible with the outcome; this test does not distinguish them.
- **Work review:** revision 2 **ACCEPT WITH CORRECTIONS** (2026-10-19); revision 3 applies them and is **ACCEPTED** (2026-10-19), as a documentation review only. No independent reproduction of the game run. Work directed that the mounted-disc test is **not to be repeated**.
- **Research document:** `docs/research/cdrom-detection-research.md` (added by the user at `476675a`, written from `6638e7d`) gains a dated addendum and a pointer at its top, so its pending-approval wording is not read as current.
- **Next (preparation only):** Work authorized writing the source and synthetic tests of a small search helper, for review. It would locate the CD-ROM message and candidate references in the working-copy `PITFALL.EXE`, checking the file's full pinned hash before searching. Tracing the code that decides to show the message (decoding) is deferred.
  - **Work's source review of helper revision 1 (2026-10-19):** two corrections are required before any game-file use:
    - stop before stage B when neither CD-ROM target term is found;
    - bound the match and reference positions kept in memory while searching, not only those printed.

    Searching every ANSI match that has an address, whatever its section name, was found reasonable. Searching reference patterns across the whole file must be documented explicitly.
  - Revision 2 is being prepared as source for review. No helper or test run, game-file read, launch, mounting, installation or settings change is authorized. *(Later: done and run; see* Start-up message location and resource mapping *below.)*
- **Open user decision:** GitHub reports this repository as **public** (Claude's read-only check, 2026-10-17), although earlier records say private. No original game material is tracked. Making it private would restrict future access, but would not undo earlier exposure. This does not block the documentation review.

#### Start-up message location and resource mapping (2026-10-19 to 2026-10-21)

Report: [startup-messages.md](docs/technical/startup-messages.md), which lists every helper and evidence fingerprint. All results are **Claude-reported findings reviewed by Work**, not an independently reproduced examination.

**Text search**
- **The helper:** `find-pe-text.ps1` revision 2 (`0E581E33…45F2`) applies Work's two corrections. Work accepted it for testing on 2026-10-19.
- **Synthetic test:** one run, 72/72 PASS, on 2026-10-20.
- **Search run 1** (2026-10-21, one Work-authorized run on the working copy, exit 0):
  - each full sentence is stored once, in UTF-16LE, in `.rsrc`;
  - there is no single-byte (ANSI) copy.
- **Work verdict: accepted as location evidence,** with three interpretation corrections:
  - references were not searched, by design, which does not mean that none exist;
  - no reference-finding method was established yet;
  - the gap between the sentences shows distance only.

**Resource mapping**
- **The helper:** `map-pe-resource.ps1` (`EF66F9DD…5C89`). Work reviewed it as source only, then accepted it for one synthetic run: 55/55 PASS. Work checked the saved log's fingerprint without re-running the tests, and authorized one run on the working copy.
- **Mapping run 1** (2026-10-21, one run, exit 0):
  - The CD-ROM sentence is the whole of string-table (RT_STRING) block 15, entry 3: **string ID 227**.
  - The colour warning is the whole of block 2, entry 1: **string ID 17**.
  - Both are US English (`0x0409`), and each mapping is unique.
- **Work verdict: ACCEPT** (2026-10-21). Work checked the evidence and helper fingerprints and the printed arithmetic. Work's qualifications:
  - "unique mapping" means exactly one resource contains each specified range; how many copies of each sentence exist comes from the search;
  - an exact string-table entry does not prove that the displayed message is never modified or combined at run time;
  - the mapping cannot establish the start-up check logic, and `LoadStringA` is not assumed to be the loading route.

**Next (Work, 2026-10-21; preparation only)**
- **Prepare** this documentation update and a code-analysis proposal. The proposal locates uses of string 227, with 17 as a comparison. It names a disassembler and anything that needs the user's approval, and it defines the boundary, metadata-only reporting, evidence classes and stop conditions.
- **Not authorized:** new helper implementation, game-file reads, disassembly, runtime tests, mounting, downloads, installations, settings changes, commits or pushes.
- **Work's framing:** the next substantive question is which code uses string 227 and what branch leads there, not whether audio tracks are required.
- **Tool availability** (Claude's read-only checks, 2026-10-21): no suitable installed disassembler, Java runtime, Python or Visual Studio tools were found. This does not prove that none exists anywhere on the PC. Any analysis tool needs the user's approval to download and use, and a decision record (`CLAUDE.md` rule 6).
- **Work review of the first proposal (2026-10-21):**
  - **Documentation:** accepted with small wording corrections, applied here.
  - **Proposal:** to be revised:
    - string 17 is a comparison, not a guaranteed positive control;
    - access to resource block 15 is not by itself a reference to string 227;
    - "confirmed" means an established static call target and argument, not proof of run-time reachability;
    - all output and analysis must be bounded;
    - release requirements must come from the selected release's tagged documentation.
  - **Work's preferred plan:** Ghidra 12.1.4 and its required JDK only, with radare2 deferred and stage 2 kept separate.
- ~~**Current:** the revised proposal is under Work's review. The download and extraction decision then goes to the user. Synthetic validation and the first game-file analysis each need separate Work authorization after that.~~ *(Superseded the same day; see below.)*
- **Proposal revision 2: ACCEPT** (Work, 2026-10-21) for the download-and-extraction request to go to the user. This was not approval to run either tool. Work's two limitations:
  - network polling every 10 seconds is observation, not isolation;
  - settings, cache and temporary-file redirection and external-library loading are assumptions until validated. They are not proven safeguards.
- **Download and extraction** (user approval "yes to all 4", 2026-10-21; Claude-reported; Work ACCEPT of the record):
  - **Ghidra 12.1.4:** `ghidra_12.1.4_PUBLIC_20260921.zip`, 569,649,598 bytes, SHA-256 `ddac49f9…d4db`.
  - **Temurin JDK 21.0.12.1+1:** `OpenJDK21U-jdk_x64_windows_hotspot_21.0.12.1_1.zip`, 205,073,461 bytes, SHA-256 `f9d6e191…8b4e`.
  - **Checks:** both sizes and checksums matched the published values.
  - **Location:** extracted unelevated into `C:\PitfallTest\analysis-tools\` (5,219 and 490 files); the downloads are kept in `C:\PitfallTest\downloads\`.
  - **Security:** no Defender detection or prompt occurred. Nothing was installed, registered or run.

  Work did not rehash the installed files or reproduce the security checks.
- **Current:** stage 1a **source preparation** is authorized (Work, 2026-10-21):
  - synthetic fixtures and their expected results;
  - the Java analysis script;
  - a bounded launch and test harness;
  - checks of redirection, library loading, timeouts and output limits.

  All of it stops for source review. **Not yet authorized:** Java or Ghidra launch, compilation, fixture generation, synthetic execution or game-file access. A `docs/decisions/` record for the new tool dependency (`CLAUDE.md` rule 6) is still to be written.
- **Open user decision:** repository visibility (see the previous subsection).

#### Session handoff (2026-10-21)

The user asked for a clean handoff before a new Claude Code conversation. **Start here.** This subsection summarizes the state above; where they differ, the dated entries above give the detail.

**Repository:**
- `main` = `origin/main`, clean. The documentation commit `c9fab8c` holds the accepted start-up message results; this handoff commit follows it.
- Nothing proprietary is tracked.
- Local review files are in the git-ignored `private/work-review/`. Its `README.md` lists every batch with fingerprints and status.

**Completed and accepted** (all Claude-reported unless stated):

| Item | Result | Evidence |
|---|---|---|
| Three existing-account launches (baseline, confirmation, mounted data-only disc) | Each stopped at "Pitfall must be played using the CD-ROM."; exit code 0 | `docs/testing/` reports |
| Text-search helper `find-pe-text.ps1` revision 2 | Synthetic 72/72 PASS (2026-10-20). One run on `PITFALL.EXE`: each sentence stored once, UTF-16LE, in `.rsrc` | [startup-messages.md](docs/technical/startup-messages.md) |
| Resource-mapping helper `map-pe-resource.ps1` | Synthetic 55/55 PASS. One run: CD-ROM message = string **227** (block 15, entry 3); colour warning = string **17** (block 2, entry 1); US English | same |
| Download and extraction of Ghidra and its JDK (user-approved) | Both sizes and SHA-256 values matched; extracted unelevated; **not run** | `private/work-review/2026-10-21-tool-download-1/RECORD.md` (`8181EF66…9DCB`) |

The two helpers and their tests live only in local review batches, not in `tools/`.

**Installed analysis tools** (Claude-reported; re-hashed read-only at handoff, all unchanged):

| Tool | Version | Location | Fingerprints |
|---|---|---|---|
| Ghidra | 12.1.4 PUBLIC (`application.java.min=21`) | `C:\PitfallTest\analysis-tools\ghidra_12.1.4_PUBLIC\` (5,219 files) | zip `ghidra_12.1.4_PUBLIC_20260921.zip`, 569,649,598 bytes, `ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db`. `support\analyzeHeadless.bat` `DD7B9D17…AE07`; `support\launch.bat` `4B3C3A6A…9434`; `support\launch.properties` `5A0FA484…AE83`; `ghidraRun.bat` `9374C936…1357` |
| Eclipse Temurin JDK | 21.0.12.1+1-LTS, x86_64 | `C:\PitfallTest\analysis-tools\jdk-21.0.12.1+1\` (490 files) | zip `OpenJDK21U-jdk_x64_windows_hotspot_21.0.12.1_1.zip`, 205,073,461 bytes, `f9d6e191ab098c0d416e7d588a24420a8621cd2f4720dab2459b8b7b2d2d8b4e`. `bin\java.exe` `82051FDA…1D55` |

- **Downloads** are kept in `C:\PitfallTest\downloads\`.
- **Full file manifest:** `private/work-review/2026-10-21-tool-download-1/analysis-tools-manifest.txt` (`6A8E3373…68F8`, 5,709 files).
- **Nothing registered with Windows:** no PATH, registry, service or file-association change.
- **Validation of the tools: none yet.** Neither Java nor Ghidra has ever been launched. The only checks were download integrity, file counts and version labels read from text files.
- `C:\PitfallTest\analysis-work\` and `C:\PitfallTest\analysis\` do not exist yet.

**Not done:**

| Work | Status |
|---|---|
| **Stage 1a source preparation:** synthetic fixtures and expected results, the Java analysis script, a bounded launch and test harness, and checks of settings, cache and temporary-file redirection, external-library loading, timeouts and output limits | **Authorized by Work (2026-10-21), not started.** No files exist yet. It must stop for Work's source review. |
| Stage 1a execution: launching Java or Ghidra, compilation, fixture generation, the synthetic run | **Not authorized.** Needs Work's authorization after the source review. |
| Stage 1b: one headless analysis of the working-copy `PITFALL.EXE` | **Not authorized.** Needs Work's authorization after stage 1a. This would be the first disassembly of game code. |
| Stage 2: the immediate context of confirmed references | **Not authorized.** Separate Work decision after 1b. |
| `docs/decisions/` record for the Ghidra and JDK dependency (`CLAUDE.md` rule 6) | Not written |
| Adding the two helpers to `tools/` | Not proposed; would be a separate reviewed change |
| Repository visibility (GitHub reports **public**) | Open user decision |

**The plan to follow:** proposal revision 2, `private/work-review/2026-10-21-docs-and-code-analysis-proposal-r2/code-analysis-proposal.md` (`37BE7BF0…53CA`). It defines:
- routes R1–R5;
- evidence classes:
  - **C1** confirmed *static* reference, not proof of run-time reachability;
  - **B** block-level only (block 15 ≠ string 227 without evidence of entry 3);
  - **C2** probable;
  - **U** unresolved, never "coincidence";
  - **N** not found (complete analysis only);
- string 17 as a comparison only;
- the bounds: 1,800 s analysis timeout, 60 min wall clock, `-max-cpu 2`, wrapper depth 2, 200 call sites per import slot, C1 ≤ 10 per string, B ≤ 10, C2 ≤ 25, 150 listed lines, 64 KB report;
- process-scoped redirection to `C:\PitfallTest\analysis-work`;
- metadata-only reporting.

**Limitations to keep explicit** (Work, 2026-10-21):
- **Network polling** (every 10 s) is observation, not isolation.
- **Unvalidated assumptions:** settings, cache and temporary-file redirection and external-library loading are assumptions until stage 1a validates them. They are not proven safeguards.

**Stop conditions** (proposal revision 2, section 10). Stop, preserve the evidence, do not retry, and report on:
- a tool, script or game-file fingerprint mismatch;
- a Defender alert, or an elevation, SmartScreen, network or firewall prompt;
- a non-loopback connection by the Ghidra Java process;
- any write outside the declared folders, including new items in `%APPDATA%\ghidra`, `%LOCALAPPDATA%\ghidra`, `%TEMP%` (Ghidra or `hsperfdata`), `%USERPROFILE%\.ghidra` or `HKCU\Software\JavaSoft`; all were absent at handoff;
- a PE layout or import-slot disagreement with `executable.md`, or external libraries being loaded;
- any `LIMIT`;
- any step that would execute, debug, emulate or patch game code, or read another game file;
- output that would need raw bytes, listings or decompiler text.

**Standing requirements:**
- **Reserved for the user:** downloads and installations, first execution and the runtime environment, mounting and extraction, and external contact.
- **Work's authorization is needed** for each later stage.
- **Defender stays on,** with no exclusions; everything runs unelevated.
- **Originals stay read-only;** no original material is committed.
- **Commits and pushes** happen only within explicit authorization, never force-pushed.

#### Baseline run procedure (historical, 2026-10-16; used for baseline 1 and the confirmation run)

- **Subject:** exactly one `ASSETS\PITFALL.EXE` launch from the already staged copy, under the existing account, unelevated, with `ASSETS` explicitly set as the working directory. No Windows 95 mode, reduced-colour setting, wrapper, replacement DLL, launcher or installer in this baseline.
- **Duration:** at most 10 minutes; stop sooner on a blocking dialog, crash, security alert, instability, unexpected administrator/install/system-change request or two minutes without response. Cancel elevation/install prompts. End only the identified test process if needed; never use `KILLPIT.EXE`.
- Record the exact settings, account context, executable hash, working directory, display/audio/input baseline, start/end times and process identifier before associating events with the run. Capture exact dialog wording and order. For a nonblocking warning, record it; do not change settings mid-run or silently count another launch as the same attempt.
- Capture narrow before/after observations and application-error events. Failed essential observations or unexpected unrelated changes stop further testing. A quiet event log is not proof of success.
- Score launch, graphics/palette/fullscreen behavior, keyboard/controller input, minutes of responsive gameplay, sound effects, music and crashes separately. Aim for five minutes of gameplay if it gets that far. CD music remains **not exercised** while no CD device is available.
- Stop after the one result and let Work select the smallest next test. Do not consume the old attempt-2/3 slots or stack several compatibility changes.

#### Follow-up authority and priorities

Once the user approves the changed environment and a safe, repeatable procedure is established, Work may approve bounded non-destructive follow-up tests within those exact limits. Record the variable, expected evidence and stop condition for each batch; do not ask the user about routine wording or in-scope technical details. Crashes and mixed settings in session 1 do not yet establish that procedure.

Prioritize the earliest reproducible blocker. Reduced colour **without** Windows 95 mode is a possible later one-variable experiment, not an approved action here. Converting a data track to ISO or mounting media still requires direct user approval and would not recreate the mixed-mode disc's CD-audio tracks. Do not install wrappers, download DLLs, modify system files or choose engine reconstruction based on this session.

#### Preserved preparation history

- The old package, its user approval and separate-account setup are preserved at [`1322174`](https://github.com/TheHuskinator/pitfall-pc-restoration/blob/13221746b18a07b4d6416625e573b4881df63aee/PROJECT_STATUS.md) and in session 1.
- Reviewed staging revision 3: `7C3BDA91659076C68A9D66C68A907BE17E6054F248BBC12729FCF9C081FAA7DD`; inventory pin `5cc516c228a0719d20842b78b18d62c80ec56775`.
- Separate-account snapshot revision 3: `DE761EE73890426C70133576C4300F1122F0F4DD745D78E265CA569D748DFEEC`, source-accepted by Work before use. It is **not** the helper for the existing-account test.
- Staging, preflight and snapshot execution results remain Claude-reported. Do not reclassify them as independent reproduction.

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

**Current (2026-10-21):** see *Session handoff (2026-10-21)* above.
1. Preserve the completed separate-account exploratory session. Work reviewed it with evidence-limit corrections; no need to redo staging or WAIL32 analysis.
2. ~~Claude completes the narrowly scoped account/privacy helper adaptation and read-only preflight, without requiring a separate Windows account.~~ Done: helper revision 2 accepted by Work and installed with a verified fingerprint (2026-10-17).
3. ~~Obtain explicit approval for the single existing-account baseline, then record that run before selecting any compatibility change.~~ Done 2026-10-17: baseline 1 and the confirmation run, both accepted by Work. ~~The mounted-disc test awaits the user's combined approval.~~ Done 2026-10-17: the CD-ROM message was unchanged; the report (revision 3) is accepted by Work, and the test is not to be repeated. ~~**Current:** revision 2 of the stage-A/B search helper (source and synthetic tests) is being prepared for Work's review, with Work's two corrections; nothing is run.~~ Done 2026-10-21: the search and resource-mapping runs are accepted by Work. The CD-ROM message is string-table entry 227 (`docs/technical/startup-messages.md`). ~~**Current:** a revised code-analysis proposal to locate uses of string 227 is under Work's review. Any disassembler download needs the user's approval.~~ Done 2026-10-21: proposal revision 2 accepted, and Ghidra 12.1.4 and JDK 21 downloaded and extracted with the user's approval (not run). **Current:** stage 1a source preparation (fixtures, analysis script and harness) for Work's review. Execution and game-file analysis await separate approval.
4. Keep Defender enabled, originals read-only and personal data out of reports. Defer tooling, mounting/conversion and deeper reverse engineering until evidence justifies them.

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
| 2026-10-16 | Use the existing account, unelevated, for the next planned test; separate account no longer required absent a specific technical need. | User direction | Preserve session 1 and existing working copy. Defender remains enabled; no full personal-registry export. First launch in changed environment still requires explicit approval. |
| 2026-10-16 | Review exploratory session 1 and select one attributable existing-account baseline. | Work review and delegated preparation assignment | Evidence-limit corrections applied to the report; faults are not causally attributed. Helper adaptation/read-only preflight authorized, no new game launch or media conversion. |
| 2026-10-17 | Accept `baseline-run.ps1` revision 2 (`B9B56E5E…DEE2`) for one supervised existing-account baseline; install it to `C:\PitfallTest\tools`. | Work review (delegated) | Source acceptance only. The 10-minute limit is a reminder, not an automatic stop; exit code 0 does not mean gameplay worked. The launch itself still needs the user's explicit approval. |
| 2026-10-17 | Deliver files for Work's review through the git-ignored `private/work-review/` folder. | User request | Claude-written files only; dated batches, fingerprints listed in its README, never edited after listing. |
| 2026-10-17 | Accept existing-account baseline 1; next, one unchanged confirmation launch to capture the exact dialog text. | Work review (delegated) after the user-approved run | CD-ROM check is the leading suspected blocker, not a proven cause. No static-analysis project. The confirmation run is launched and observed by the user. |
| 2026-10-17 | Accept the confirmation run; next, prepare a data-only ISO and one mounted-disc launch. | Work review and preparation assignment (delegated) | Preparation only, with no original-media access. Creating the ISO, mounting it and the launch each need the user's explicit approval. Does not test CD audio. |
| 2026-10-17 | Run future tests with the network connected; remove the helper's network gate (revision 3). | User decision; Work ACCEPT of revision 3 | Network recorded as context; network or firewall prompts are a stop condition. Earlier runs stay documented as offline. |
| 2026-10-17 | Mounted-disc preparation revision 1: corrections required (AutoPlay before mounting, finalisation, link checks); revision 2 submitted. | Work review (delegated) | Revision 2 proposes a user-approved temporary AutoPlay switch-off. Nothing created, mounted or launched. |
| 2026-10-17 | Accept mounted-disc revision 3 (`make-data-iso.ps1` `1F8BD327…`); install helper revision 3 as `baseline-run-r3.ps1`. | Work review (delegated) | Subject to the user's explicit combined approval of ISO creation, the AutoPlay switch-off, mounting, one launch, eject and restore. |
| 2026-10-17 | Approve the five mounted-disc actions; they were completed once. | User approval ("yes, I approve all five") | The CD-ROM message was unchanged (reported); exit 0 (verified). The approval is spent. |
| 2026-10-19 | Mounted-disc report revision 2: ACCEPT WITH CORRECTIONS. Do not repeat the mounted-disc test. Add a dated addendum to the research document. Prepare a stage-A/B text-search helper (source and synthetic tests only). | Work review and preparation assignment (delegated) | The failure does not establish an audio-track requirement. No helper or test execution, game-file read, launch, mounting, installation, settings change, commit or push is authorized. Repository visibility is a separate user decision. |
| 2026-10-19 | Accept mounted-disc report revision 3. Publish it with the research addendum and this status update in one documentation-only commit and push. Helper revision 1 needs two corrections (no-target stop before stage B; bounded retained positions). | Work review (delegated) | Documentation review only; no independent reproduction. Helper revision 2 is source-only for review; no execution or game-file access is authorized. |
| 2026-10-19 to 2026-10-21 | Accept search helper revision 2 for testing; after its synthetic run (72/72), authorize one search run on the working-copy `PITFALL.EXE`. | Work review and authorization (delegated) | One run, exit 0. Accepted as location evidence with three interpretation corrections. |
| 2026-10-21 | Authorize a source-only resource-mapping helper. Accept it for one synthetic run (55/55), then authorize one mapping run on the working copy. | Work review and authorization (delegated) | One run, exit 0: the CD-ROM message is string 227 and the colour warning is string 17. |
| 2026-10-21 | Accept the mapping results. Authorize documentation and a code-analysis proposal (preparation only). | Work review (delegated) | Claude-reported findings reviewed by Work, not independently reproduced. No disassembly, download, installation, commit or push authorized. A disassembler download is reserved for the user. |
| 2026-10-21 | Documentation accepted with small corrections. The proposal is to be revised. Preferred tool: Ghidra 12.1.4 with its required JDK 21 only; radare2 deferred; stage 2 kept separate. | Work review and recommendation (delegated) | Preparation only. The download and extraction decision is the user's. Synthetic validation and the first game-file analysis need separate Work authorization. |
| 2026-10-21 | Accept proposal revision 2 and send its download request to the user. Approve downloading, verifying and extracting the pinned Ghidra 12.1.4 and Temurin JDK 21.0.12.1+1 zips. | Work ACCEPT; user approval ("yes to all 4") | Completed once; both hashes matched; nothing run (Claude-reported). Running either tool was excluded. |
| 2026-10-21 | Accept the download record. Authorize stage 1a source preparation, and one documentation-only commit and push of the accepted diff with a minimal current-state correction. | Work review and authorization (delegated) | No Java or Ghidra launch, compilation, fixture generation, synthetic execution, game-file access, download, installation or settings change. |
| 2026-10-21 | Prepare a clean session handoff in `PROJECT_STATUS.md` and commit and push it. | User request | Documentation only. No testing, execution, installation or configuration change. Stage 1a source preparation remains authorized but not started. |
