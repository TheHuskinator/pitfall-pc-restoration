# Existing-account baseline 1 — `ASSETS\PITFALL.EXE`, Windows 11 (2026-10-17)

One supervised launch of the original executable, in the user's existing Windows account, unelevated, with no compatibility settings. Run by the user with the Work-accepted helper `baseline-run.ps1` revision 2 (SHA-256 `B9B56E5E…DEE2`). Claude read the local logs afterwards. Not independently reproduced by Work.

**Work review (2026-10-17): ACCEPT with minor documentation corrections, applied in this version.** The reviewed draft is preserved unchanged in the local review folder (SHA-256 `485AFE96…14B3`).

Labels: **verified** (by Claude, from the local run folder or the user's console transcript), **reported** (by the user, not independently checked), **assumption**.

**Result in one line:** the game started and showed the 256-colour warning, then a CD-ROM message (reported). After that message was dismissed, it closed by itself (reported), with **exit code 0 about 13.5 seconds after the process started** (verified). No game crash events were found in the observed window. The only difference found in the captured observations was a Windows `MuiCache` record. The **leading suspected blocker** is the CD-ROM check; it is not a proven cause.

## 1. Approval and conditions

- **User approval (2026-10-17, in the Claude session):** "Yes, I approve exactly one supervised baseline launch under the procedure above." This followed Work's ACCEPT of helper revision 2 and its installation (`3244803`).
- **Account** *(verified, helper)*: the user's own account, not elevated, at Medium integrity. The console prompt showed `C:\WINDOWS\system32` as its folder, which is often an administrator window. The helper's checks (no elevated token, Medium integrity) establish that this session was not elevated.
- **Defender** *(verified, helper)*: all protections on before, at launch and after; 0 detections throughout.
- **Executable** *(verified)*: SHA-256 matched the pinned inventory at launch; all 40 working-copy files were unchanged after the run.
- **Compatibility** *(verified)*: no compatibility entry for the game paths and `__COMPAT_LAYER` empty, before, at launch and after.
- **Network** *(verified)*: at launch, no physical network adapter was up.
  - The launch phase refused twice first ("networking is still connected"), because the wired Ethernet connection was still up. Nothing was started either time. The user then unplugged the cable.
  - Those refusals are the launch gate working as intended. They are not launches and did not use up the run.

## 2. What happened

### Verified (run folder `baseline-20261017-033013`, kept local)

| Item | Result |
|---|---|
| Launch requested | 2026-10-17 08:36:07.806 UTC, from `C:\PitfallTest\pitfall-cd\ASSETS` |
| Process start | 08:36:07.861 UTC; one `PITFALL.EXE` process, ID 12572; the process handle was held, so the exit code was read from the process itself |
| Process exit | 08:36:21.400 UTC, **exit code 0**; no `PITFALL.EXE` left running |
| Run time | helper shows `00:00:13` (see the timing note below) |
| 10-minute reminder | not reached |
| Crash, hang or error-report events | **none found** for the game, from 2 seconds before the launch request until the after phase |
| Helper results | before: COMPLETE; launch: started once; after: COMPLETE with one REVIEW item (below) |

**Timing note** *(verified from the helper source and the recorded values)*:
- The helper computes run time as process exit time minus process start time, from the two recorded timestamps. It then displays the result in whole seconds (`hh:mm:ss`), dropping the fraction.
- The recorded timestamps give 08:36:21.3997 − 08:36:07.8610 = **13.54 seconds**, which the helper displays as `00:00:13`.
- Rounding the timestamps to whole seconds (08:36:07 → 08:36:21) suggests 14 seconds. This difference comes only from the display format; the recorded values are unchanged.

### Reported by the user

1. The 256-colour message appeared first, as in session 1.
2. A message about the CD-ROM appeared second. The user recalls that it concerned the "CD-ROM"; its exact wording, title and buttons were not recorded, and no screenshot was taken.
3. After that message was dismissed, **the game closed by itself**. The user did not end it.

### Before/after comparison *(verified, within the captured observations only)*

- **The only difference found — REVIEW, Windows records:** two new game-named values in Explorer's `MuiCache`, the program's company and friendly name for `ASSETS\PITFALL.EXE`.
  - *Assumption:* this is Windows' normal record of a program that has been run through the shell, not something the game wrote. Session 1 showed the same kind of entry.
- **No difference found** in these captured observations:
  - game files;
  - compatibility entries;
  - game-named registry keys;
  - startup entries (`Run`/`RunOnce`, Startup folders, stored as hashes);
  - display, audio and input device state;
  - Defender status;
  - `WIN.INI`/`SYSTEM.INI` metadata;
  - DirectInput's "most recent application" record (not `PITFALL.EXE`, before and after).
- **No game-named `%TEMP%` items** written since the launch.
- These observations are deliberately narrow, game-named and partly hashed. They do not establish that nothing else on the system changed.

## 3. Interpretation (assumptions, to be tested)

- **B1 — the CD-ROM check is the leading suspected blocker.** With no compatibility settings, the game showed its two messages; after the CD-ROM message was dismissed, it closed by itself (reported). It exited with code 0, and no game crash events were found in the observed window (verified).
  - That the game *deliberately* ended itself after a failed check is an **inference**, not established.
  - The disc's data files are present on the hard drive, but there is no CD drive.
  - The confirmation run (below) is meant to capture the exact wording, title, buttons and order of both dialogs.
- **B2 — the session-1 crashes did not recur.** Without Windows 95 mode or reduced colour, no access-violation events were found: none in `AcGenral.DLL`, none in `winmmbase.dll`. This is consistent with them arising later in the program, or only under those settings. One run does not establish which.
- **B3 — input set-up is undetermined.** DirectInput's "most recent application" record was unchanged in this run, whereas session 1 set it to `PITFALL.EXE`. An unchanged record **does not establish** whether the game began or skipped input set-up.
- **The 256-colour message** is a warning in session 1's wording ("for optimum performance"). Whether it is also blocking is not established.

## 4. Measurable result

| Item | Result |
|---|---|
| Launch | Yes. Process started (verified); dialogs shown (reported) |
| Usable graphics | No (reported) |
| Keyboard input | Not tested; no gameplay reached |
| Minutes of gameplay | 0 |
| Sound effects | Not reported |
| CD music | Not exercised (no CD device) |
| Game crash events | None found in the observed window (verified) |
| How it ended | Exit code 0 about 13.5 s after the process start (verified); closed by itself after the CD-ROM message was dismissed (reported) |

## 5. Stop-rule status

- The approved single launch is **used**. No further launch is authorized by this record.
- No compatibility setting was changed, and no second launch was made.
- Raw logs stay in `C:\PitfallTest\logs\baseline-20261017-033013` and are not committed.
- **Next step (Work, 2026-10-17):** one unchanged confirmation launch, to capture the exact wording, title, buttons and order of the 256-colour and CD-ROM dialogs. It uses the same helper and conditions, and is launched and observed by the user. No new static-analysis project: the reviewed PE inspector cannot establish the CD-check control flow.
