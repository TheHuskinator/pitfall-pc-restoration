# PROJECT STATUS — Pitfall: The Mayan Adventure (PC Restoration)

**Status:** First launch evidence reviewed; preparing an existing-account baseline  
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

**Phase:** native Windows 11 compatibility diagnosis. An exploratory separate-account session opened the game window but did not reach gameplay. The user has selected their existing account for the next bounded baseline; no restoration engine or implementation architecture has been chosen.

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

#### Next run — proposed, pending explicit user approval

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

**Current (2026-10-16):** follow *Next milestone: one attributable baseline in the existing Windows account* above.
1. Preserve the completed separate-account exploratory session. Work reviewed it with evidence-limit corrections; no need to redo staging or WAIL32 analysis.
2. ~~Claude completes the narrowly scoped account/privacy helper adaptation and read-only preflight, without requiring a separate Windows account.~~ Done: helper revision 2 accepted by Work and installed with a verified fingerprint (2026-10-17).
3. ~~Obtain explicit approval for the single existing-account baseline, then record that run before selecting any compatibility change.~~ Done 2026-10-17: baseline 1 run and accepted by Work. **Current:** one unchanged confirmation launch to capture the exact dialog text (see *Baseline 1 result and Work review*).
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
