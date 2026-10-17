# Launch attempt 1 — `ASSETS\PITFALL.EXE`, Windows 11 (2026-10-16)

First execution of original game software, under the user's approval of the launch package (Claude session, 2026-10-16). The package and its boundaries are in [PROJECT_STATUS.md](../../PROJECT_STATUS.md) (*Launch-readiness handoff*). The user ran the game; Claude did the preparation and the log review.

**Result in one line:** the game starts and shows its window, but does not reach gameplay. The original configuration stops at startup checks for a CD-ROM and a 256-colour display. With Windows 95 compatibility mode, it then fails on a missing `dispdib.dll` and crashes or freezes.

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
- **No game-written settings:** no key containing "Pitfall", "Activision" or "Kinesoft" was created by the game.

**Other changes:**
- About 2,500 other new keys appeared in the account. They are consistent with Windows finishing setup of a brand-new account (Store-app registrations, content delivery). The only other app-related change is a Snipping Tool entry from the user's screenshots.
- **Game files:** all 40 are unchanged (same sizes, times and SHA-256).
- **Unchanged elsewhere:** startup (`Run`/`RunOnce`) entries, the VirtualStore (empty before and after) and the `%TEMP%` file names.

**Concerning changes:** none found within the captured areas. There are no new startup entries, and nothing indicates changes to unrelated programs.

## 3. Interpretation (assumptions, to be tested)

- **A1 — the program has explicit startup checks for a CD-ROM drive and a 256-colour display.** These are consistent with the statically imported `GetDeviceCaps` and `GetVersion` (R2.1). Which exact checks the program makes is not established.
- **A2 — `AcGenral.DLL` is part of Windows' compatibility-fix engine,** which is loaded when compatibility modes are applied. Its crashes are therefore likely tied to the compatibility settings, not to the unmodified program.
- **A3 — the `winmmbase.dll` crashes are in Windows' multimedia layer.** That layer handles `mciSendCommand`, `aux*`, `joy*` and `waveOut*`; R2.1 lists the game's WINMM imports. Without a CD device, MCI CD-audio or `aux` volume calls are candidates; this is not tested.
- **A4 — DISPDIB.DLL is a Windows 3.x/9x-era library for full-screen low-resolution display, and it is not part of Windows 11.**
  - **Compatibility mode effect:** Windows 95 mode probably makes the game take a Windows 95 code path that loads it at run time. `LoadLibraryA` is imported, and DISPDIB is not a static import.
  - **Error code:** "error 2" is consistent with "file not found".
  - **Status:** the library's role is general Windows knowledge; its use by this game is not verified.
- **A5 — the CD-ROM message disappearing under Windows 95 mode is not explained.** It may be a different code path rather than a satisfied check.

## 4. Deviations from the approved boundaries (recorded factually)

The approved package specified no compatibility settings, and one launch per attempt. During attempt 1, the user:
- applied Windows 95 and Reduced colour compatibility modes to `PITFALL.EXE` and `PITSTART.EXE`;
- launched `PITFALL.EXE` several times.

These are the user's own actions as project owner, and no unrelated system changes resulted. However, as a consequence:
- the four crash events cannot be matched to specific settings;
- planned attempt 2 (`PITSTART.EXE`, "unchanged") would no longer run in the originally approved conditions while the compatibility layers remain.

## 5. Stop-rule status

- **This attempt:** stopped correctly after crashes and a freeze.
- **Further attempts:** no stop condition is triggered. Both snapshots are COMPLETE, and no concerning changes were found.
- Attempts 2 and 3 have **not** been run. They are paused pending Work's review and the user's decision on the compatibility layers.

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
