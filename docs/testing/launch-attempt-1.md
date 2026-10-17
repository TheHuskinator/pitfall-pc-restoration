# Launch attempt 1 — `ASSETS\PITFALL.EXE`, Windows 11 (2026-10-16)

First execution of original game software, under the user's approval of the launch package (Claude session, 2026-10-16). The original package and its boundaries are preserved in [PROJECT_STATUS.md at the examination-report commit](https://github.com/TheHuskinator/pitfall-pc-restoration/blob/13221746b18a07b4d6416625e573b4881df63aee/PROJECT_STATUS.md) (*Launch-readiness handoff*); the current status file contains the superseding plan. The user ran the game; Claude did the preparation and the log review.

**Result in one line:** this mixed-configuration session did not reach gameplay. Claude reports screenshots of the game window, a 256-colour warning and a `Bad or missing dispdib.dll - error 2` dialog; the user reported a CD-ROM message. Four access-violation events and a freeze were reported across several launches. Exact per-launch settings and causal order were not captured.

**Work review (2026-10-16): ACCEPT WITH CORRECTIONS, applied in this update.** Useful exploratory evidence, not a controlled single-launch baseline. Work reviewed the committed report and user-provided Claude handoff, not the raw snapshots, screenshots or game bytes. Below, "verified" means verified by Claude from the cited local evidence, not independently reproduced by Work.

Labels: **verified** (with source), **reported** (by the user, not independently checked), **assumption**.

## 1. Environment and preparation (verified by Claude unless marked)

- Windows 11 Home 25H2 (build 26200), x64. No CD/DVD drive.
- **Test account:** `Pitfall Test`, a local standard user. It is not in the Administrators group and ran unelevated (snapshot `account` = OK).
- **Working copy:** `C:\PitfallTest\pitfall-cd`.
  - Staged once by the reviewed staging script, revision 3: exit code 0, `RESULT: OK`, no incomplete marker.
  - All 40 files were re-verified against the pinned inventory, and the disc image was unchanged afterwards.
- **WAIL32 preflight on the staged copy** (`tools/inspect-pe.ps1`, blob `3c334673…`): SHA-256 matches the inventory; x86 DLL; 65 imports; 104 exports; `RESULT: OK`. This is the same as R2.3. The output is kept in `private/test-logs/`.
- **Snapshot helper:** revision 3, SHA-256 `DE761EE7…D748DFEEC`, verified by the user before use (screenshot).
- **Networking:** reported disconnected during the attempt (Airplane mode), per the package.
- **Recovery:** reported. A restore point was created, and important files are backed up.

## 2. What happened

### Verified from the user's screenshots

**First screenshot:**
- The game window titled "Pitfall: The Mayan Adventure" appeared at a small size, with a black client area, `File` and `Help` menus, and a status bar.
- A dialog titled "Pitfall" said the game must be played in 256 colour mode for optimum performance.

**Second screenshot:**
- A "Loading..." box with the game's icon appeared inside the game window.
- A dialog titled "Pitfall" said **`Bad or missing dispdib.dll - error 2`**.

Several identical `Start-Process` launch commands are visible in the console history.

### Reported by the user

1. **Without compatibility settings:** a message said the game must be played from a CD-ROM, together with the 256-colour message.
2. **Compatibility settings:** the user then set **Windows 95 compatibility mode** and **Reduced colour mode** on both `PITFALL.EXE` and `PITSTART.EXE`.
   - The CD-ROM message eventually stopped appearing.
   - The 256-colour message persisted.
   - The `dispdib.dll` error appeared after Windows 95 mode was turned on.
3. **Repeated launches:** the game was launched several times with the same errors.
4. **Last launch:** after the errors were dismissed, the small game window stayed open but froze, and was ended in Task Manager.

`PITSTART.EXE` was **not** launched. Only its compatibility setting was changed.

### Verified from the before/after snapshots (both `SNAPSHOT RESULT: COMPLETE`)

**Application log:** four `Application Error` (ID 1000) events, all for `pitfall.exe` (version 1.0.0.1, timestamp `0x305a1209`), all with exception code `0xc0000005`. That code means an access violation: the program touched memory it was not allowed to.

| Time (UTC) | Faulting module | Fault offset |
|---|---|---|
| 2026-10-17 03:55:32 | `AcGenral.DLL` 10.0.26100.9549 | `0x000b594f` |
| 2026-10-17 03:57:30 | `winmmbase.dll` 10.0.26100.9549 | `0x00005ab3` |
| 2026-10-17 03:57:48 | `winmmbase.dll` 10.0.26100.9549 | `0x00005ab3` |
| 2026-10-17 04:00:18 | `AcGenral.DLL` 10.0.26100.9549 | `0x000b594f` |

Which launch produced which event, and which settings were active for each, was not recorded.

**Registry changes in the test account (`HKCU\Software`) that relate to the game:**
- **Compatibility layers:** `AppCompatFlags\Layers` holds `~ 256COLOR WIN95` for both `ASSETS\PITFALL.EXE` and `PITSTART.EXE`. This is the user's setting, and it is still in place.
- **Windows bookkeeping:**
  - an Explorer `MuiCache` entry for `PITFALL.EXE` (company "Activision");
  - `DirectInput\MostRecentApplication` set to `PITFALL.EXE`;
  - new `Multimedia\Audio` keys.
- **No identified game-specific keys by this name filter:** Claude did not identify new keys containing "Pitfall", "Activision" or "Kinesoft" as game-created settings. Key-name filtering does not establish that the game wrote no registry values, modified no existing keys, or used no differently named locations.

**Other changes:**
- About 2,500 other new keys appeared in the account. They are consistent with Windows finishing setup of a brand-new account (Store-app registrations, content delivery). The only other app-related change is a Snipping Tool entry from the user's screenshots.
- **Game files:** all 40 are unchanged (same sizes, times and SHA-256).
- **Unchanged in the reported snapshots:** the selected startup (`Run`/`RunOnce`) entries, the VirtualStore listing (empty before and after) and the captured top-level `%TEMP%` names. These observations do not cover all startup mechanisms, temporary-file contents, every subfolder or unrelated filesystem locations.

**Concerning changes:** none found within the captured areas. There are no new startup entries, and nothing indicates changes to unrelated programs.

## 3. Interpretation (assumptions, to be tested)

- **A1 — startup messages concern CD media and display colour depth.** Exact checks and whether each dialog is a warning or a blocking condition are not established. The R2.1 imports provide possible API leads, not proof of the code path or failure cause.
- **A2 — the two events naming `AcGenral.DLL` are consistent with compatibility processing being involved.** They do not prove the compatibility setting caused the crash or exonerate the original program. A faulting module identifies where an exception surfaced, not necessarily where the defect originated. See [Microsoft crash-troubleshooting guidance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/performance/troubleshoot-application-service-crashing-behavior).
- **A3 — two events name `winmmbase.dll`.** R2.1's WINMM imports make multimedia calls relevant leads, but no call stack or matched per-launch trace establishes the failing API. Missing CD media, audio/volume handling, invalid application state and compatibility interactions remain hypotheses; no particular cause is selected.
- **A4 — the dialog names `dispdib.dll`; the required module/version and loading path are unverified.**
  - Windows 95 compatibility mode changing a version-dependent path is a hypothesis, not a demonstrated trace. R2.1 records a `GetVersion` import, but an import alone does not establish how the result is used.
  - Win32 system error 2 means file not found ([Microsoft error codes](https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-)), but the source and interpretation of the game's displayed number have not been verified.
  - The earlier assertion that this library is absent from Windows 11 was not supported by a host check in this report. A missing/bad-module dialog does not prove that downloading or copying a DLL is a valid or safe fix. No DLL download, replacement or registration is proposed here.
- **A5 — the CD-ROM message disappearing under Windows 95 mode is not explained.** It may be a different code path rather than a satisfied check.

## 4. Deviations from the approved boundaries (recorded factually)

The approved package specified no compatibility settings, and one launch per attempt. During attempt 1, the user:
- applied Windows 95 and Reduced colour compatibility modes to `PITFALL.EXE` and `PITSTART.EXE`;
- launched `PITFALL.EXE` several times.

These were the user's own actions, not unauthorized execution by Claude. No concerning changes were reported within the captured areas; absence of unrelated changes or harm system-wide is not established. As a consequence:
- the four crash events cannot be matched to specific settings;
- planned attempt 2 (`PITSTART.EXE`, "unchanged") would no longer run in the originally approved conditions while the compatibility layers remain.

## 5. Stop-rule status

- **This session:** the final frozen process was reportedly ended in Task Manager. The record does not establish that each earlier stop condition was followed or the duration of the freeze.
- **Further attempts:** remain paused. COMPLETE snapshots mean the configured observations succeeded, not that the program is safe or stable. Crashes/freezing and changed test conditions require a revised bounded plan; the unused attempt slots are not automatic permission to continue.
- `PITSTART.EXE` has not been launched. The existing-account baseline plan in `PROJECT_STATUS.md` supersedes the old attempts 2–3; preserve this session as historical evidence.

## 6. Measurable result

| Item | Result |
|---|---|
| Launch | Window and dialogs appear (verified); "Loading..." shown with Windows 95 mode (verified) |
| Usable graphics | No; black client area only |
| Keyboard input | Not reached |
| Five minutes of gameplay | No; 0 minutes |
| Sound effects | Not reported |
| CD music | Not exercised (no CD device) |
| Failure details | CD-ROM check (reported), 256-colour check (verified), missing `dispdib.dll` under Windows 95 mode (verified), 4 access violations (verified), one freeze (reported) |

Raw logs (`C:\PitfallTest\logs\before-1-…`, `after-1-…`) and screenshots stay local and are not committed.
