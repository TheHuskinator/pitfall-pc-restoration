# Existing-account mounted-disc run 1 — `ASSETS\PITFALL.EXE` with the data-only ISO mounted (2026-10-17)

*Revision 3 (2026-10-19). **Work review (2026-10-19): ACCEPT**, as a documentation review only. Work did not independently reproduce the run, and its records and observations remain Claude-verified or user-reported as labelled below.*

**Revision history.** Earlier revisions are kept unchanged in their review batches.

| Revision | Review batch | SHA-256 | Outcome |
|---|---|---|---|
| 1 | `2026-10-17-mounted-disc-run-result` | `2FFD645DDAB8CD67C7B015014DC64EC552CFA6A07134D97DF0570350D4377376` | superseded |
| 2 | `2026-10-19-mounted-disc-run-result-r2` | `A61DA547AAB169794B60F1E3D8794D3E08ABDBC90D69CC2CB70853954FF9E883` | ACCEPT WITH CORRECTIONS (Work) |

The observations are the same in all three revisions. Revision 3 makes four corrections:
- it describes the actual direct launch without calling it abnormal;
- it says the hypotheses remain compatible with the outcome, rather than that they predict it;
- it keeps who observed what: user-reported versus Claude-verified;
- it limits "no difference" to the captured observations and their time window.

The test is the user-approved mounted-disc test from the Work-accepted proposal (mounted-disc revision 3, `make-data-iso.ps1` `1F8BD327…`, recorded at `6638e7d`). **Purpose:** find out whether presenting the game's own data track as a CD-ROM drive gets past the message "Pitfall must be played using the CD-ROM." The user ran every step and observed the game; Claude ran the preflight and read the local records afterwards. Not independently reproduced by Work.

Labels: **verified** (by Claude, from local records or the user's console transcript), **reported** (by the user, not independently checked), **assumption** or **hypothesis** (an interpretation that has not been tested).

**Result in brief:**
- **Reported:** with a CD-ROM drive `E:` labelled `PITFALL` holding all 40 inventory files, the user saw the same two dialogs in the same order, and the game then closed by itself.
- **Verified:** the helper's records show the process ended with exit code 0, 25.84 seconds after it started.
- **No matching events:** no game crash, hang or error-report events were found in the observed window.
- **No difference** was found between the helper's before and after snapshots, in the observations they capture.

**The result does not show why the game did not continue** (section 5).

---

## Part A — Observations

### 1. Approval and conditions

- **User approval (2026-10-17):** "yes, I approve all five". This covered:
  1. one data-only ISO creation;
  2. switching AutoPlay off temporarily (the user did this);
  3. mounting, after the pre-mount check passed;
  4. one supervised launch, after the mounted-disc check and the before snapshot passed;
  5. ejecting, then restoring the recorded AutoPlay setting.

  The approval was used once and is now spent. Work has directed that this test is not to be repeated.
- **Preflight (Claude, read-only, before step 1)** *(verified)*:
  - Fingerprints matched for `make-data-iso.ps1` revision 3, `baseline-run-r3.ps1` (`31524868…`) and `PITFALL.EXE`.
  - Defender: all six protections on, Normal mode, 0 detections.
  - No game-related compatibility settings, and `__COMPAT_LAYER` empty.
  - AutoPlay recorded as **on** (`DisableAutoplay = 0`), with no software-disc action chosen.
  - No CD-ROM drive, and no game or launcher running.

| Condition | Value |
|---|---|
| Executable / working directory | `C:\PitfallTest\pitfall-cd\ASSETS\PITFALL.EXE`, working folder `ASSETS`, both on the hard disk; nothing was run from the disc |
| How it was started | directly by the helper. `PITSTART.EXE` was not used, no command-line arguments were added, and no installation or set-up step was performed |
| Account | the user's own, unelevated, Medium integrity |
| Compatibility | none; `__COMPAT_LAYER` empty, before, at launch and after |
| Defender | on; 0 detections, before, at launch and after |
| Network | **connected** (1 physical adapter up), recorded as context. The two earlier runs were offline. |
| AutoPlay | **off** during the test (`DisableAutoplay = 1`, verified by both disc checks) |
| CD-ROM drive | **`E:`**, Windows' built-in mount of the data-only ISO, labelled `PITFALL`. Windows chose the letter. |

### 2. Steps and checks (verified, user's transcript and local reports)

1. **ISO created:** `RESULT: OK`. The source was validated (image SHA-256, 8,880-sector header check, label, volume size, 40 files), and the original image's SHA-256 was unchanged afterwards.
   - The ISO is `private/derived/MEDIA-001-track1-data.iso`: 18,186,240 bytes, read-only, SHA-256 `247D4E171BF2F098E249D246D6BAED25B0B12DDA7B77CC772DCCF77E567BE954`.
   - It holds **only the data track** (track 1). The 23 tracks recorded as audio on the original image are not in it, by design.
   - The completed-conversion record is valid, and there is no INCOMPLETE marker or `.partial` file. Claude re-checked these afterwards, including the original image's fingerprint.
2. **AutoPlay switched off** by the user.
3. **Pre-mount check:** `DISC CHECK: OK - ready to mount`. The conversion was complete, AutoPlay was verifiably off (`DisableAutoplay = 1`), there were no CD-ROM drives, and no game or launcher was running.
4. **Mounted** by the user in Explorer. No prompt or automatic start was reported.
5. **Mounted-disc check:** `DISC CHECK: OK (E:\)`. Exactly one ready CD-ROM drive, labelled `PITFALL`; 40 files, all matching the inventory (path, size, SHA-256); AutoPlay still off; nothing running.
6. **Before snapshot** (run `baseline-20261017-172712`): COMPLETE; network connected recorded.
7. **Launch:** one process, ID 29668. The launch-time checks passed, and the network was connected at launch.
8. **After snapshot:** COMPLETE.
9. **Ejected:** no CD-ROM drive present afterwards (verified). **AutoPlay restored** by the user (reported "back on, same as before"). Claude re-read the setting:
   - AutoPlay is on, with no software-disc action chosen.
   - **Stored-value difference (verified):** before the test the value was stored as `DisableAutoplay = 0`; after it was switched back on in Settings, the value is **absent**.
   - AutoPlay is not among the helper's captured observations, and the restore happened after the after snapshot. This difference is therefore recorded here, separately from the snapshot comparison.
   - *Assumption:* an absent value is Windows' default, AutoPlay on. That is consistent with the Settings switch showing On. The behaviour is equivalent, though not stored identically.

**Deviation, recorded factually:**
- After the game had exited, the launch command was entered a **second time**.
- The helper refused it ("this run already has a launch record (one launch per run)"). **Nothing was started** and no file was written.
- The once-per-run guard held. It was not a second launch.

### 3. What happened

#### Verified by Claude (run folder `baseline-20261017-172712`, kept local)

| Item | Result |
|---|---|
| Launch requested | 22:28:13.165 UTC |
| Process start | 22:28:13.215 UTC, ID 29668, handle held |
| Process exit | 22:28:39.057 UTC, **exit code 0**; no `PITFALL.EXE` left running |
| Run time | the helper shows `00:00:25` (whole seconds); the timestamps give 25.84 s |
| Game crash, hang or error-report events | no matching events found in the observed window: from 2 s before the launch request to the after phase |
| `%TEMP%` | no game-named items written since the launch |
| Before/after snapshots | **no difference found** in the captured observations, including network context. Things the helper does not capture are not covered (for example AutoPlay, see step 9). |

#### Reported by the user

- The same two dialogs appeared, in the same order as in baseline 1 and confirmation 1:
  1. the 256-colour warning;
  2. the CD-ROM message.
- The game then closed by itself.
- The exact text was not re-copied in this run. For reference, confirmation run 1 captured it exactly: "Pitfall must be played in 256 color mode for optimum performance." [OK], then "Pitfall must be played using the CD-ROM." [OK].
- Whether the wording was character-for-character identical this time is reported, not verified.

#### Not observed or not recorded

- Which drives, files, registry values or devices the game examined. No API or file-activity logging was done.
- Whether the game tried to use the CD-audio device (MCI) at all.
- The volume serial number Windows reported for `E:`, and the drive's device identity.
- What happened inside the game between the two dialogs.

### 4. Comparison

| Item | Baseline 1 | Confirmation 1 | Mounted-disc 1 |
|---|---|---|---|
| CD-ROM drive | none | none | **`E:` labelled `PITFALL`, 40 matching files, data track only** |
| Network | offline | offline | **connected** |
| AutoPlay | on (no disc) | on (no disc) | **off** |
| Executable location | `C:` working copy | same | same |
| Started by | the helper, directly | same | same |
| Dialogs (reported) | 256-colour, then CD-ROM | same; text captured | same |
| Self-closure (reported) | yes | yes | yes |
| Exit code (verified) | 0 | 0 | 0 |
| Matching crash events in the observed window | none found | none found | none found |

---

## Part B — Interpretation

### 5. What this result establishes, and what it does not

**Established**, from the user's report of the dialogs and Claude's verification of the exit record: in this exact configuration the game did not get past the CD-ROM message. The configuration was:
- Windows' built-in mount of a data-only ISO, presented as `E:`;
- the correct label, and all 40 data files present and correct;
- the game started directly from the hard-disk working copy.

**Not established:** *why* the game did not continue. In particular, **this failure does not establish that the game requires the audio tracks.** The tested set-up differed from the original disc in more ways than the missing audio, and the way the game was started is only one of several possible ways:

1. **The missing audio tracks were only one difference.** Compared with the original disc in a physical drive, the mount also differed in:
   - its track layout (one data track instead of 24 tracks);
   - the device behind the drive letter (Windows' virtual disc driver rather than a physical drive);
   - possibly how the drive answers status and media queries.

   Any of these could matter on its own.
2. **The game was started directly from the hard disk**, without `PITSTART.EXE`, without added arguments and with no installation or set-up step. How the game was intended to be installed and launched has not been established, so it is unknown whether any of these differences matters.
3. **An import is a capability, not a cause.** `PITFALL.EXE` imports `mciSendCommandA`, which can query CD audio. The program might use it only for music after start-up, or on a path never reached. The import shows that the program can call the function, not that the start-up check does.
4. **This test does not distinguish the candidates.** Each hypothesis in section 6 remains compatible with the outcome, given further assumptions about how the check works. The result does not favour one over another, and does not show that they are equally likely.

A *success* would not have identified the mechanism either. It would only have shown that this configuration was enough.

### 6. Candidate explanations (hypotheses; none is established)

They are not mutually exclusive: the check could combine several conditions. The order is not a ranking.

| # | Hypothesis | How it could be compatible with this result | Basis | What could tell it apart |
|---|---|---|---|---|
| H1 | **The check needs the audio tracks or the track layout**, e.g. it uses MCI to look for a CD-audio disc with the expected track count | the ISO has no audio tracks | `mciSendCommandA` import (static); 23 audio tracks on the original image | static examination of the code before the message; or a later test with the full mixed-mode disc |
| H2 | **It looks at a particular drive**: a fixed letter, the first optical drive it finds, or a drive or path recorded during set-up | Windows chose `E:`, and no set-up step was performed | registry functions imported by `PITFALL.EXE` and `PITSTART.EXE`; `GetCommandLineA` imported | static examination (registry value names, drive-letter strings) |
| H3 | **It checks where the program itself is running from**, e.g. its own folder or the current folder must be on the CD | the game ran from `C:` | `GetModuleFileNameA` imported | static examination; or a later test run from the mounted disc |
| H4 | **It expects a particular file, label or volume serial number** | the label and all 40 files matched, but the serial number Windows reported for `E:` was not recorded. A file check could still fail if it looks on a different drive (H2). | none specific | static examination (file-name strings, comparisons) |
| H5 | **It finds the drive in a way the virtual drive does not satisfy**, e.g. a device query, drive-type check or readiness check through a function loaded at run time | Windows' mount is a different device from a physical drive | `LoadLibraryA` and `GetProcAddress` imported, so functions not in the import list could still be used | static examination; run-time API logging (would need its own approval) |
| H6 | **It expects to be started by `PITSTART.EXE`**, which might pass an argument, write a setting or copy a file first | the game was started directly | `PITSTART.EXE` imports `CreateProcessA`, `CopyFileA`, `GetWindowsDirectoryA` and registry functions | static examination of both programs; a launcher test would need its own approval |

**Changed conditions:** the network being connected and AutoPlay being off. They are considered unlikely to matter (*assumption*), but they are recorded as differences and not ruled out.

### 7. Stop-rule status

- **The approved five actions are complete:** one ISO created, one mount, one launch, ejected, AutoPlay restored.
- **Nothing further is authorized:** no further launch, mount or setting change. Work has directed that the mounted-disc test is not to be repeated.
- **Not done:** no compatibility setting, no launcher run, nothing run from the disc, no API logging, no downloads, installations or replacement DLLs.
- **Kept local, not committed:**
  - raw logs: `C:\PitfallTest\logs\baseline-20261017-172712`, `disc-premount-20261017-172514.txt` and `disc-check-20261017-172646.txt`;
  - the ISO, which is derived proprietary material in `private/derived/`.
- **CD music** remains untested; the ISO has no audio tracks.
- **Next step:** Work has authorized preparing, for review only, a small search helper that would locate the CD-ROM message in `PITFALL.EXE`. Nothing has been run.
