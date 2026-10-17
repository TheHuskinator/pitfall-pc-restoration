# Existing-account confirmation run 1 — `ASSETS\PITFALL.EXE`, Windows 11 (2026-10-17)

The unchanged confirmation launch Work assigned after accepting [baseline 1](existing-account-baseline-1.md) (`3e57437`). **Purpose:** capture the exact wording, title, buttons and order of the 256-colour and CD-ROM dialogs. The user launched and observed; Claude read the local logs and the user's notes afterwards. Not independently reproduced by Work.

**Work review (2026-10-17): ACCEPT.** Work checked the report against its full SHA-256 and reviewed the sanitized report, not the raw logs or screenshot. The reviewed draft is preserved unchanged in the local review folder (SHA-256 `550E51B2…F372`); this published copy differs only by this paragraph replacing its draft banner.

Labels: **verified** (by Claude, from the local run folder, the user's copied dialog text or the user's screenshot), **reported** (by the user, not independently checked), **assumption**.

**Result in one line:** two dialogs appeared, in this order: the 256-colour warning, then the CD-ROM message. Each was titled `Pitfall` with a single `OK` button. After the user clicked OK on the CD-ROM message, the game closed by itself, with exit code 0, 56.8 seconds after it started. No game crash events were found, and no difference was found in any captured observation. This matches baseline 1.

## 1. Conditions (verified, helper and Claude's preflight)

| Condition | Result |
|---|---|
| Helper | `baseline-run.ps1` revision 2, SHA-256 `B9B56E5E…DEE2`, unchanged |
| Account | the user's own, unelevated, Medium integrity |
| Executable | `ASSETS\PITFALL.EXE`, SHA-256 matches the pinned inventory; all 40 working-copy files unchanged after the run |
| Working directory | `C:\PitfallTest\pitfall-cd\ASSETS` |
| Compatibility | no game-named setting in the per-user and machine-wide locations (both registry views); `__COMPAT_LAYER` empty, before, at launch and after |
| Defender | all six protections on, Normal mode, 0 detections, before, at launch and after |
| Network | no physical adapter up at launch (Ethernet unplugged) |
| Run folder | `baseline-20261017-154823` (kept local) |

The before and after phases were both COMPLETE. The launch gate passed first time.

## 2. Dialogs

**Order** *(verified)*: the user's notes list the dialogs in this order, each followed by "clicked OK".

**Exact text:** copied with Ctrl+C from each Windows message box *(verified from the user's notes)*.

| # | Title | Text | Buttons | Clicked | Icon |
|---|---|---|---|---|---|
| 1 | `Pitfall` | `Pitfall must be played in 256 color mode for optimum performance.` | `OK` | OK (reported) | reported as identical to dialog 2; no screenshot |
| 2 | `Pitfall` | `Pitfall must be played using the CD-ROM.` | `OK` | OK (reported) | red error icon (verified, screenshot) |

**Also seen in the screenshot, taken while dialog 2 was open** *(verified)*:
- The game window `Pitfall: The Mayan Adventure`, with `File` and `Help` menus, a black client area and a status bar.
- A "Loading..." box with the game's icon inside the game window.
- This run had no compatibility settings. Session 1's record noted the "Loading..." box only while Windows 95 mode was in use.

The screenshot also shows unrelated personal windows, so it stays local and is not shared. Only the dialog details above are transcribed from it.

**After dialog 2:** the user clicked OK, and **the game closed by itself** (reported). The user did not end it.

## 3. Process and evidence (verified, run folder)

| Item | Result |
|---|---|
| Launch requested | 2026-10-17 20:50:02.917 UTC |
| Process start | 20:50:02.972 UTC, process ID 45796, handle held |
| Process exit | 20:50:59.772 UTC, **exit code 0**; no `PITFALL.EXE` left running |
| Run time | helper shows `00:00:56` (whole seconds); the timestamps give 56.80 s |
| 10-minute reminder | not reached |
| Game crash, hang or error-report events | none found, from 2 s before the launch request to the after phase |
| `%TEMP%` | no game-named items written since the launch |
| Before/after comparison | **no difference found** in any captured observation: game files, compatibility entries, game-named keys, startup entries, Windows records (including `MuiCache`, already present from baseline 1), display/audio/input state, Defender |

**Timing:**
- The user's screenshot was saved at 20:50:41 UTC, about 39 s after the process started, while dialog 2 was open.
- Baseline 1 took 13.54 s. This run includes the time the user spent copying text and taking the screenshot before clicking OK.
- The duration therefore reflects how long the dialogs stayed open, not anything measured about the game itself. Neither run measures how long the game takes between dialogs.

These observations are deliberately narrow, game-named and partly hashed. They do not establish that nothing else on the system changed.

## 4. Comparison with baseline 1

| Item | Baseline 1 | Confirmation run |
|---|---|---|
| Dialog order | 256-colour, then CD-ROM (reported) | same (verified from copied text) |
| Exact text | not captured | captured (above) |
| Ending | closed by itself after the CD-ROM OK (reported); exit code 0 | same |
| Game crash events | none found | none found |
| Differences found | `MuiCache` record created | none |

The result reproduced under the same conditions.

## 5. Interpretation (assumptions, to be tested)

- **The CD-ROM check remains the leading suspected blocker.** The wording "must be played using the CD-ROM" fits a check that fails because no CD-ROM is present. Which check the game performs is **not established**: for example, a drive type, a volume label or a file on a CD drive. That the game exits deliberately after this dialog is still an inference.
- **The 256-colour dialog reads as advice** ("for optimum performance"), and the game continued to the CD-ROM dialog after OK. Whether colour depth matters later is not established.
- **The "Loading..." box appears without compatibility settings**, so it is not specific to Windows 95 mode.

## 6. Stop-rule status

- One launch, as assigned; no second launch, no setting change, no launcher, mounting, extraction, download, installation or replacement DLL.
- Raw logs stay in `C:\PitfallTest\logs\baseline-20261017-154823`. The user's notes and screenshot stay local and are not committed.
- No further launch is authorized by this record. **Work selects the next step from the dialog text.**
