# CD-ROM detection research — reviewed draft

> **Update (2026-10-19): read the [dated addendum](#addendum-2026-10-19-mounted-disc-test-completed-after-this-documents-baseline) first.**
> - The mounted-disc test discussed below has since been run once, and its approval is spent.
> - Work has directed that it is not to be repeated.
> - This document's statements about a pending approval, and its "next experimental decision", describe the state at commit `6638e7d`. They are not current instructions.

Date: 2026-10-17. Scope: Kinesoft Windows 95 PC edition on Windows 11.

**Disposition:** documentation draft for Work/Claude review. No scripts executed or approved; no game execution, media creation/mounting, installation or settings changes performed. This workspace is a synced project mirror, not a Git checkout. This new document does not alter synced references and has not been committed or pushed.

## Conclusion

The CD-ROM dialog is the leading suspected startup blocker. MCI is a useful investigation lead, but the import of `mciSendCommandA` does not establish that MCI causes the dialog. A data-only mounted-disc failure would not prove an audio-track check. Preserve the already prepared bounded test; the research does not justify adding an unreviewed probe or committing to a virtual-drive product, logger, shim or engine rebuild.

## Provenance and current baseline

Reviewed input: user-uploaded **Kinesoft Pitfall: The Mayan Adventure CD-ROM Detection on Windows 11**, `Pasted text.txt`, 729 lines; SHA-256 `61C4635D8452C0EA587D53C6F0A1A79C62E5ED7ECFA00250DB5F5CB805E3A93F`. The conversation attachment supplied the local copy corresponding to the requested `/mnt/data/Pasted text.txt`.

Repository baseline: [`6638e7ddf933bdc3a21fa5360d78c5ab7c99e277`](https://github.com/TheHuskinator/pitfall-pc-restoration/commit/6638e7ddf933bdc3a21fa5360d78c5ab7c99e277), latest returned commit on review. Recent history also reviewed: [`a985bf2`](https://github.com/TheHuskinator/pitfall-pc-restoration/commit/a985bf2314c7f0af24c9699e6d364b5fa57df1df) (network-connected future testing and preparation corrections), [`88cca27`](https://github.com/TheHuskinator/pitfall-pc-restoration/commit/88cca27e0e4d0a5c9f82d1a276e282639b4826a4) (confirmation result), and `3e57437` (baseline result).

The dated 2026-10-17 entries in [PROJECT_STATUS.md][P1] supersede its stale top-level baseline-preparation summary. Work accepted mounted-disc preparation revision 3; `baseline-run-r3.ps1` was installed according to Claude. The record still awaits the user's combined approval for ISO creation, temporary AutoPlay switch-off, mounting, one launch, eject and restoration. **No mounted-disc outcome is recorded at this baseline.** The report's statement that no reviewed conversion procedure exists is stale.

Future tests may be network-connected; the baseline and confirmation were offline. Record this additional changed condition when interpreting comparisons. The planned executable and working directory remain the existing HDD working copy, not the mounted image. [P1]

[CLAUDE.md][P2] names Claude as local implementer; [AGENTS.md][P3] names Codex. Both preserve Work's bounded delegation and the user's reserved decisions. This draft follows the requested Work/Claude handoff without changing those role files. Repository metadata returned `public`, whereas the request and historical documentation say private; visibility is unresolved here and must not be relied on for protecting content. No visibility change or proprietary upload was made.

## Project observations and their limits

“Verified in project record” below retains the original examiner's meaning. This review checked documentation, not game bytes, local logs or screenshots; it is not independent reproduction.

| Observation | Evidence and qualification |
|---|---|
| Confirmation displayed the 256-colour advisory, then the CD-ROM requirement; both titled `Pitfall`, with one OK button. | [Confirmation report][P4]: exact text verified by Claude from user-copied text; clicks and self-closure user-reported. Exit code 0 and no matching crash events recorded. No gameplay. Deliberate prerequisite exit remains an inference. |
| The program continued after the colour advisory. | [P4]. Does not establish later rendering compatibility or complete independence of colour and media handling. |
| `PITFALL.EXE` is PE32 x86 and imports `mciSendCommandA`, auxiliary-volume functions, file I/O, `LoadLibraryA` and `GetProcAddress`. | [Executable report][P5], including Claude's parser reproduction. No runtime call sequence or arguments established. |
| `GetDriveTypeA`, `GetVolumeInformationA` and `DeviceIoControl` are absent from the recorded static imports. | [P5]. Dynamic resolution or indirect library calls remain possible, not demonstrated. |
| MEDIA-001 has one Mode 1 data track and 23 tracks declared audio in one session. | [Media examination][P6]; descriptor agreement and sampled structure, with authenticity/completeness and track-2 index discrepancy unresolved. Volume label `PITFALL` and 40-file inventory are examiner-reported in [P1]. |

## External API facts

These describe Windows interfaces, not observed Pitfall behavior. Sources were accessed 2026-10-17; author/publisher is Microsoft unless stated otherwise.

- [`mciSendCommand`][S1] sends numeric command messages with device identifiers, flags and parameter structures; [`mciSendString`][S2] sends textual commands. Both expose ANSI and Unicode variants and return MCI error codes. Semantic overlap does not establish identical application call paths.
- [`MCI_STATUS`][S3] supports readiness, media presence, track count and CD track type. Track-type queries require `MCI_STATUS_ITEM`, `MCI_TRACK` and a valid track number; results distinguish audio from other. Actual driver responses remain measurements to obtain.
- [`GetDriveTypeA`][S6] distinguishes optical (`DRIVE_CDROM`, 5) from fixed storage. [`GetVolumeInformationA`][S7] returns volume information; the volume serial is not the hardware manufacturer's serial. [`Win32_CDROMDrive`][S8] supplies device/media metadata, not proof of MCI compatibility.
- [`Mount-DiskImage`][S9] documents mounting ISO/VHD images. A data-only image derived from track 1 omits the separate audio tracks by construction. Neither its `.iso` suffix nor this API promises the MCI view of a particular mount.

## Audit of causal claims

| Claim in pasted research | Assessment |
|---|---|
| MCI is the strongest explanation of startup gating. | **Hypothesis, overstated ranking.** Imports and mixed-mode media make MCI music control plausible. MCI could be used only after startup, for another device type, or on a path never reached. Auxiliary-volume APIs do not identify the gate. Establish relevant calls and the branch leading to the dialog before causal attribution. |
| Failure with a data-only ISO sharply identifies an audio/TOC requirement. | **Not established.** Failure also fits wrong/default drive selection, a hard-coded letter, executable/current-directory checks, file/label/serial expectations, device readiness or virtual-driver differences. The planned launch remains on HDD, so it cannot eliminate a requirement to execute from optical media. |
| Success with the data-only mount identifies the mechanism. | It would show that this configuration satisfies the immediate requirement, conditional on recorded differences. It would not identify the API or show that music works. Absence of audio tracks would argue against a strict audio-track requirement on that observed startup path, provided another drive did not satisfy it. |
| Success with full mixed-mode emulation proves CDDA/TOC causation. | The emulator also changes device implementation, identity, enumeration and possibly drive letter. Success supports a working configuration; isolate differences or examine control flow before naming the cause. |
| The API immediately before the dialog reveals the failing check. | Temporal proximity is insufficient: a call may succeed, be unrelated, or precede another condition. Correlate arguments, return values and the consuming branch. [Microsoft Detours][S12] is an instrumentation option, not an approved dependency or guaranteed diagnosis. |

Drive/file discovery and MCI remain plausible peers. Label/serial and low-level device checks are unconfirmed. A single-session layout does not itself exclude TOC or subchannel checks. Microsoft's [obsolete READ_TOC guidance][S13] concerns that interface; it does not establish that all modern TOC queries or CD audio are unavailable.

## Sample-script audit — source review only

The pasted snippets are **not ready for adoption**. None was run, compiled, installed or authorized here.

1. **MCI interface mismatch (lines 449–485).** Unicode P/Invoke selects the string interface, ordinarily `mciSendStringW`; the game's recorded import is `mciSendCommandA`. PowerShell process bitness is unspecified, while Pitfall is x86. This can characterize one host MCI configuration, but cannot reproduce the game's unknown flags, structures, sharing policy, command order or selected device. A future command-interface probe would require reviewed ABI layouts and pointer widths. [S1], [S2]
2. **Unspecified drive (line 494).** `open cdaudio …` supplies no explicit optical target. The alias `pitcd` names the opened MCI instance; it does not bind it to the ISO or to the drive Pitfall selects. A future design must record target identity and distinguish explicit-drive measurements from default-device behavior.
3. **Command syntax defects.** The sample uses `shareable`; Microsoft's [open command][S4] documents `sharable`. Its track query (line 518) omits the `cdaudio` qualifier documented in [`status`][S5]: the documented request is `cdaudio type track number`. Treat both as defects pending correction and validation; an error cannot be interpreted as absent audio tracks.
4. **Cleanup and error handling.** Device close lacks `try/finally`; exceptions can skip cleanup. Error codes are folded into strings, parsing/query failure can resemble an empty track list, and track counts are not bounded. Output writes and native command exits lack consistent failure handling. Preserve numeric return codes separately from returned values, explicitly mark incomplete results and close only the instance successfully opened by the probe. Opening a device initializes runtime state; “read-only” here does not mean side-effect-free. [S2], [S3], [S4]
5. **Host inventory (lines 405–440).** `Get-Volume` and drive enumeration include unrelated volumes; PNP identifiers and labels may disclose host details. Scope any later collector to the approved optical device. Timestamp directories alone lack the project's parent/link and no-overwrite protections. The shown `vol D:` is CMD syntax, not a portable PowerShell cmdlet invocation; review shell context before adopting it. [S8], [S10]
6. **Mount snippet (lines 561–581).** Mounting changes state and can trigger AutoPlay. The snippet lacks the accepted pre-mount guards, source/output verification and complete finalisation protocol. It must not replace revision 3's reviewed procedure. A placeholder path is not evidence that an ISO exists. [P1], [S9]
7. **Registry snippets (lines 594–608).** Literal `WOW6432Node` plus an unspecified caller architecture does not reliably demonstrate both registry views were queried. Use explicit view selection in any reviewed implementation; [`reg query`][S11] documents `/reg:32` and `/reg:64`. The sample compatibility query also omits other state already covered by the accepted helper. Do not duplicate or broaden that collection.

The proposed 24-track result is a descriptor-derived expectation, not a host result or an authenticity test. Query errors, no device, no media and zero tracks must remain distinct outcomes. No playback command is present, but that alone does not validate the probe's safety or correctness.

## Small proposed Work/Claude handoff

**Scope:** integrate this research as documentation only. Claude checks current branch/remote state and applicable instructions, reconciles any newer results, and proposes adding this file plus one short status/index link. Preserve unrelated work; stop on conflicting changes, newer evidence that invalidates the draft, or any need to access proprietary bytes or expand the milestone. Work reviews the resulting diff and explicitly scopes any commit/push under existing delegation. This draft itself grants no runtime or script approval.

**Next experimental decision:** retain the already accepted mounted-disc proposal and its outstanding user approval. Do not make the pasted MCI probe a new prerequisite. After the authorized result is available, Work should select one discriminating follow-up. If MCI measurement is warranted, request a source-only design with explicit drive identity, x86/interface comparability, structured errors and cleanup, then review it before considering execution. Static dialog references or API logging are later alternatives, not automatic next actions.

Keep originals and raw evidence private, Defender enabled, and tests within the exact approved environment. Media creation/mounting, game execution, software installation and settings changes remain reserved as specified in [P1], [P2], [P3]. No original content, raw report, game assets or screenshots belong in this documentation change. The report's legal discussion is not a project permission or rights determination; retain the repository rights policy.

## Addendum (2026-10-19): mounted-disc test completed after this document's baseline

This document was written from repository commit `6638e7d`. At that commit, the mounted-disc test was prepared but not run. The user added the document at commit `476675a`. The sections above are left unchanged as a record of that baseline; this addendum records what happened after it.

- **The test has been run.** The user approved five actions on 2026-10-17:
  - ISO creation;
  - a temporary AutoPlay switch-off;
  - mounting;
  - one supervised launch;
  - eject and AutoPlay restore.

  All five were completed once. The approval is spent; it is no longer "outstanding" as stated above.
- **Result.** Windows mounted a data-only ISO as `E:`, labelled `PITFALL`, with all 40 inventory files matching. The game was started directly from the hard-disk working copy, not from the disc and not through `PITSTART.EXE`.
  - **User-reported:** the same 256-colour and CD-ROM dialogs appeared as before, and the game then closed by itself.
  - **Claude-verified from the helper's records:** exit code 0, 25.84 s after the process started; no matching crash, hang or error-report events in the observed window; no difference between the before and after snapshots in the captured observations.
  - A separately recorded AutoPlay stored-value difference followed the user's restore.

  See [existing-account-mounted-disc-1.md](../testing/existing-account-mounted-disc-1.md).
- **Consistency with this document's audit.** The result is consistent with the second row of *Audit of causal claims*: a data-only failure does not establish an audio-track or TOC requirement. The result report lists candidate explanations H1–H6, without ranking them:
  - audio tracks or track layout;
  - drive selection;
  - the executable's location;
  - file, label or serial expectations;
  - virtual-drive differences;
  - launcher set-up.

  Each remains compatible with the outcome under further assumptions. This test does not distinguish them.
- **The "next experimental decision" above is superseded.** Work has directed that the mounted-disc test is **not to be repeated**. Work has authorized preparing, for review only, a small search helper to locate the CD-ROM message in `PITFALL.EXE`. Nothing has been run. The other constraints in that paragraph still stand:
  - the sample MCI probe is not a prerequisite;
  - any MCI measurement first needs a reviewed source-only design;
  - API logging is not an automatic next action.
- **Disposition note:** the *Disposition* paragraph's statement that this document "has not been committed or pushed" described its draft state. It was committed at `476675a`.
- **Repository visibility:** the observation in *Provenance and current baseline* was confirmed read-only by Claude on 2026-10-17: GitHub reports the repository as **public**. No tracked file is original game material. Visibility is the user's decision and is tracked separately. Making the repository private would restrict future access, but would not undo earlier public exposure.

## Citation handling and sources

The upload contains opaque ChatGPT citation tokens without a recoverable URL bibliography. They were removed rather than copied into this draft. Project claims were remapped to repository documents; retained API claims were checked against the primary links below. These are replacement supporting sources, not a claim to have recovered the exact original token targets. Unresolved original links are **unverified/unavailable**; no target has been invented. The omitted historical/display/legal detail has not been promoted into verified findings.

[P1]: https://github.com/TheHuskinator/pitfall-pc-restoration/blob/6638e7ddf933bdc3a21fa5360d78c5ab7c99e277/PROJECT_STATUS.md
[P2]: https://github.com/TheHuskinator/pitfall-pc-restoration/blob/6638e7ddf933bdc3a21fa5360d78c5ab7c99e277/CLAUDE.md
[P3]: https://github.com/TheHuskinator/pitfall-pc-restoration/blob/6638e7ddf933bdc3a21fa5360d78c5ab7c99e277/AGENTS.md
[P4]: https://github.com/TheHuskinator/pitfall-pc-restoration/blob/6638e7ddf933bdc3a21fa5360d78c5ab7c99e277/docs/testing/existing-account-confirmation-1.md
[P5]: https://github.com/TheHuskinator/pitfall-pc-restoration/blob/6638e7ddf933bdc3a21fa5360d78c5ab7c99e277/docs/technical/executable.md
[P6]: https://github.com/TheHuskinator/pitfall-pc-restoration/blob/6638e7ddf933bdc3a21fa5360d78c5ab7c99e277/docs/technical/original-media-examination.md
[S1]: https://learn.microsoft.com/en-us/previous-versions/dd757160(v=vs.85)
[S2]: https://learn.microsoft.com/en-us/previous-versions/dd757161(v=vs.85)
[S3]: https://learn.microsoft.com/en-us/windows/win32/multimedia/mci-status
[S4]: https://learn.microsoft.com/en-us/windows/win32/multimedia/open
[S5]: https://learn.microsoft.com/en-us/windows/win32/multimedia/status
[S6]: https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getdrivetypea
[S7]: https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getvolumeinformationa
[S8]: https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-cdromdrive
[S9]: https://learn.microsoft.com/en-us/powershell/module/storage/mount-diskimage
[S10]: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/vol
[S11]: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-query
[S12]: https://github.com/microsoft/Detours
[S13]: https://learn.microsoft.com/nb-no/windows-hardware/drivers/ddi/ntddcdrm/ni-ntddcdrm-ioctl_cdrom_read_toc
