# R2.2 — `PITSTART.EXE` and `KILLPIT.EXE` static analysis: PE headers and static imports

**Report ID:** R2.2
**Status:** draft for independent audit by ChatGPT Chat 2. **Not committed.**
**Examination date:** 2026-10-16
**Examiner:** Claude Code (the only examiner; all results are Claude-reported)
**Approval:** user-approved R2.2 scope (2026-10-16). It covers only these two files; the reviewed parser; fingerprints verified before parsing; signatures, headers, sections, entry points and static imports only; stop on a mismatch, unsupported format, malformed result or error.
**Companion report:** R2.1, [`executable.md`](executable.md) (`ASSETS/PITFALL.EXE`), which is used as the comparison baseline in §4.

| Subject | Size | ISO extent and sectors | SHA-256 (matches [materials-inventory.md](../inventory/materials-inventory.md)) |
| --- | --- | --- | --- |
| `PITSTART.EXE` (disc root) | 570,368 bytes | 8449; 279 blocks, LBA 8449–8727 | `601FA7E7BEEF140D3D626F5B9CFD010386C76438850DDA30D4F8E637380C0257` |
| `ASSETS/KILLPIT.EXE` | 11,776 bytes | 4214; 6 blocks, LBA 4214–4219 | `5807EA8603F5A15624CF2C10D94809E0846D4602C82C6D7680E43028925B4AF6` |

## Evidence labels used

| Label | Meaning in this report |
| --- | --- |
| **Verified** | Printed by the reviewed parser from the file bytes with the hash above, or derived by arithmetic from such values. Claude-reported: Claude ran the parser. |
| **Reported** | Stated by an outside source (cited) and not checked here. |
| **Assumption** | An interpretation, e.g. from function or file names. It may be wrong. |
| **Not tested** | Outside this task's scope or not attempted. |

## Plain-English summary

- **Both files are 32-bit Windows programs (PE32, x86), marked as Windows GUI programs.** **Verified.** Neither is a 16-bit or DOS program.
- **`PITSTART.EXE`:**
  - It statically imports 92 functions from 6 Windows DLLs. **Verified.**
  - One DLL is not used by `PITFALL.EXE`: `MSVFW32.dll` (Video for Windows), from which it imports only `MCIWndCreateA`. **Verified.**
  - About 96% of its bytes are in its resource section. Those resources were **not examined**.
- **`KILLPIT.EXE`:**
  - A small program that imports 24 functions from just 2 DLLs: 23 from KERNEL32 and `MessageBoxA` from USER32. **Verified.**
  - It has no resource section. **Verified.**
  - Every function it imports also appears in `PITFALL.EXE`'s imports. **Verified.**
- **Not established:** what either program does. Interpretations from function names are labeled **Assumption** in §5. Nothing was run, and nothing in this report is a compatibility result.

## 1. Scope and method

**Pre-check** (no game data read):
- The checkout was clean on `main` at `29589a7`.
- `tools/inspect-pe.ps1` had Git blob `1299ce51c5f69d1c5ed1612291a35e89e27cbb07`, the reviewed version.
- Its LF-normalized SHA-256 was `81FDEB05637DB9C35072EB768EEAF2FFFF3105749771A516F534CE23A13C193C`, the reviewed value.

**Runs** (Windows PowerShell 5.1.26100.9444, `-NoProfile -NonInteractive`), in this order:
1. `inspect-pe.ps1 -Image <MEDIA-001 image> -Extent 8449 -Size 570368 -ExpectedSha256 601FA7E7…0C0257`
   - fingerprint matched before parsing; `RESULT: OK`, exit code 0.
2. `inspect-pe.ps1 -Image <MEDIA-001 image> -Extent 4214 -Size 11776 -ExpectedSha256 5807EA86…ADE3A`
   - fingerprint matched before parsing; `RESULT: OK`, exit code 0.

(The second command used the full 64-character hash shown in the subject table; both are abbreviated here.)

**Structural checks the parser enforced, all passed for both files:**
- end of the section table ≤ `SizeOfHeaders` ≤ file size;
- no overlapping sections;
- section data inside the file;
- the import directory inside one stored region;
- the descriptor terminator within the declared directory size;
- all names terminated and printable.

**After the runs:** arithmetic checks by hand on the printed values (§2.5, §3.5), and a comparison with R2.1's committed `PITFALL.EXE` import lists (§4).

**Not done:**
- No other game file was read.
- No original game code was executed; only the read-only parser was run.
- No game bytes were written to disk; parser output stayed in memory and on screen, with the image path masked.
- No disassembly, string search, resource parsing, export parsing or parser changes.

See §7 for the full not-tested list.

## 2. `PITSTART.EXE` (Verified)

### 2.1 Headers

| Field | Value |
| --- | --- |
| DOS header / PE signature | `MZ`; `e_lfanew` = `0x80`; signature `50 45 00 00` |
| Machine | `0x014C` (x86) |
| NumberOfSections | 7 |
| TimeDateStamp | `0x305A5B9C` = 811,228,060. Decodes to **1995-09-16 05:07:40 UTC**; this is a field value, and the actual build time is not established. |
| Symbol table | none (pointer 0, count 0) |
| SizeOfOptionalHeader | 224 |
| Characteristics | `0x010E`: executable image, line numbers stripped, local symbols stripped, 32-bit machine. Relocations are not stripped. |
| Magic | `0x10B` (PE32) |
| Linker version | 2.55 (value only; toolchain not identified) |
| SizeOfCode / InitializedData / UninitializedData | 10,752 / 558,592 / 2,048 |
| AddressOfEntryPoint | `0x24BA` |
| BaseOfCode / BaseOfData | `0x1000` / `0x4000` |
| ImageBase | `0x00400000` |
| Section / file alignment | `0x1000` / `0x200` |
| OS / image / subsystem version | 1.0 / **0.0** / 4.0 |
| Win32VersionValue | 0 |
| SizeOfImage / SizeOfHeaders | `0x90000` / `0x400` |
| CheckSum | `0x00000000` |
| Subsystem | 2 (Windows GUI) |
| DllCharacteristics | `0x0000` |
| Stack reserve / commit; heap reserve / commit | `0x100000` / `0x1000`; `0x100000` / `0x1000` |
| LoaderFlags / NumberOfRvaAndSizes | 0 / 16 |

### 2.2 Data directories

Only three are non-empty:

| Directory | RVA | Size | Location |
| --- | --- | --- | --- |
| Import | `0x7000` | `0x9D0` | exactly `.idata` |
| Resource | `0x8000` | `0x86050` (548,944 B ≈ 536.1 KiB) | exactly `.rsrc` |
| Base relocation | `0x8F000` | `0x4AC` | within `.reloc` |

All other directories are empty: export, debug, TLS, delay-import, bound-import, load-config, security (no embedded certificate table is declared), and the rest.

### 2.3 Sections

| # | Name | VirtualAddress | VirtualSize | PointerToRawData | SizeOfRawData | Characteristics |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `.text` | `0x1000` | `0x28D4` | `0x400` | `0x2A00` | `0x60000020` code, execute, read |
| 2 | `.bss` | `0x4000` | `0x650` | — | 0 | `0xC0000080` uninitialized data, read, write |
| 3 | `.rdata` | `0x5000` | `0xC` | `0x2E00` | `0x200` | `0x40000040` initialized data, read |
| 4 | `.data` | `0x6000` | `0xB24` | `0x3000` | `0xC00` | `0xC0000040` initialized data, read, write |
| 5 | `.idata` | `0x7000` | `0x9D0` | `0x3C00` | `0xA00` | `0xC0000040` initialized data, read, write |
| 6 | `.rsrc` | `0x8000` | `0x86050` | `0x4600` | `0x86200` | `0x40000040` initialized data, read |
| 7 | `.reloc` | `0x8F000` | `0xAE6` | `0x8A800` | `0xC00` | `0x42000040` initialized data, read, discardable |

- Raw data ends at `0x8B400` = 570,368 bytes, the file size, so **there is no overlay**.
- The `.rsrc` raw data (`0x86200` = 549,376 bytes) is **96.3%** of the file.

### 2.4 Entry point

- RVA `0x24BA` → VA `0x004024BA`.
- It lies in `.text`: `0x1000 ≤ 0x24BA < 0x1000 + 0x28D4 = 0x38D4`.
- File offset `0x24BA − 0x1000 + 0x400` = **`0x18BA`**.
- The code at the entry point was not examined.

### 2.5 Internal consistency checks (arithmetic)

- **Section boundaries:** each section's virtual end, rounded up to `0x1000`, equals the next section's VirtualAddress. The last equals SizeOfImage `0x90000`. Pass ×7.
- **Raw layout:** the raw sections are contiguous, and the last ends at the file size. Pass.
- **Header area:** section-table end `0x178 + 7×40 = 0x290` ≤ SizeOfHeaders `0x400` = first raw pointer. Pass.
- **Size fields:**
  - SizeOfCode 10,752 = `.text` raw `0x2A00`. Pass.
  - SizeOfInitializedData 558,592 = raw sizes of `.rdata` + `.data` + `.idata` + `.rsrc` + `.reloc` (512 + 3,072 + 2,560 + 549,376 + 3,072). Pass.
  - SizeOfUninitializedData 2,048 = `.bss` VirtualSize `0x650` rounded up to `0x200`. This is an observed relationship, not a PE requirement.
- **Directories:** Import and Resource coincide exactly with `.idata` and `.rsrc`; Base relocation lies within `.reloc`. Pass.
- **Import count:** 34 + 33 + 12 + 8 + 1 + 4 = 92.

### 2.6 Static imports (6 DLLs, 92 functions; all by name)

| DLL (descriptor order) | Count | OriginalFirstThunk | FirstThunk |
| --- | ---: | --- | --- |
| `KERNEL32.dll` | 34 | `0x70E4` | `0x726C` |
| `USER32.dll` | 33 | `0x7178` | `0x7300` |
| `GDI32.dll` | 12 | `0x70B0` | `0x7238` |
| `ADVAPI32.dll` | 8 | `0x708C` | `0x7214` |
| `MSVFW32.dll` | 1 | `0x7170` | `0x72F8` |
| `WINMM.dll` | 4 | `0x7200` | `0x7388` |

All 6 descriptors have TimeDateStamp 0 (not pre-bound) and ForwarderChain 0. All were read via OriginalFirstThunk. There are no ordinal imports.

Functions in **original lookup-table order**, as stored in the file:

- **`KERNEL32.dll` (34):** GetWindowsDirectoryA, SetFileAttributesA, CopyFileA, GetFileAttributesA, LocalAlloc, LockResource, SetCurrentDirectoryA, LoadResource, CloseHandle, FindResourceA, CreateProcessA, LocalFree, DeleteFileA, GetTempPathA, GetSystemDirectoryA, FindFirstFileA, GetStdHandle, GetOEMCP, GetACP, GetModuleFileNameA, UnhandledExceptionFilter, RtlUnwind, ExitProcess, GetCPInfo, GetCommandLineA, GetEnvironmentStrings, FindClose, GetVersion, GetStartupInfoA, GetModuleHandleA, GetFileType, VirtualFree, VirtualAlloc, GetLastError
- **`USER32.dll` (33):** EndPaint, GetWindowRect, GetDesktopWindow, GetClientRect, LoadCursorA, LoadBitmapA, BeginPaint, ScreenToClient, GetDlgItem, EnableWindow, EndDialog, InvalidateRect, UpdateWindow, MessageBoxA, SendMessageA, PostMessageA, ClientToScreen, DefWindowProcA, DestroyWindow, LoadStringA, FindWindowA, ShowWindow, CreateWindowExA, LoadIconA, GetMessageA, TranslateMessage, DispatchMessageA, PostQuitMessage, DialogBoxParamA, MoveWindow, SetWindowTextA, RegisterClassA, SetForegroundWindow
- **`GDI32.dll` (12):** GetStockObject, StretchBlt, SelectObject, DeleteObject, CreateCompatibleDC, SelectPalette, GetObjectA, CreateCompatibleBitmap, RealizePalette, SetDIBits, DeleteDC, CreatePalette
- **`ADVAPI32.dll` (8):** RegQueryValueExA, RegCreateKeyA, RegCloseKey, RegEnumKeyA, RegOpenKeyA, RegDeleteKeyA, RegFlushKey, RegSetValueExA
- **`MSVFW32.dll` (1):** MCIWndCreateA
- **`WINMM.dll` (4):** mciSendCommandA, joyReleaseCapture, joySetCapture, sndPlaySoundA

## 3. `ASSETS/KILLPIT.EXE` (Verified)

### 3.1 Headers

| Field | Value |
| --- | --- |
| DOS header / PE signature | `MZ`; `e_lfanew` = `0x80`; signature `50 45 00 00` |
| Machine | `0x014C` (x86) |
| NumberOfSections | 6 |
| TimeDateStamp | `0x3016163A` = 806,753,850. Decodes to **1995-07-26 10:17:30 UTC**; this is a field value, and the actual build time is not established. |
| Symbol table | none (pointer 0, count 0) |
| SizeOfOptionalHeader | 224 |
| Characteristics | `0x010E`: executable image, line numbers stripped, local symbols stripped, 32-bit machine. Relocations are not stripped. |
| Magic | `0x10B` (PE32) |
| Linker version | 2.55 (value only; toolchain not identified) |
| SizeOfCode / InitializedData / UninitializedData | 5,632 / 5,120 / 1,536 |
| AddressOfEntryPoint | `0x1105` |
| BaseOfCode / BaseOfData | `0x1000` / `0x3000` |
| ImageBase | `0x00400000` |
| Section / file alignment | `0x1000` / `0x200` |
| OS / image / subsystem version | 1.0 / **0.0** / 4.0 |
| Win32VersionValue | 0 |
| SizeOfImage / SizeOfHeaders | `0x8000` / `0x400` |
| CheckSum | `0x00000000` |
| Subsystem | 2 (Windows GUI) |
| DllCharacteristics | `0x0000` |
| Stack reserve / commit; heap reserve / commit | `0x100000` / `0x1000`; `0x100000` / `0x1000` |
| LoaderFlags / NumberOfRvaAndSizes | 0 / 16 |

### 3.2 Data directories

Only two are non-empty:

| Directory | RVA | Size | Location |
| --- | --- | --- | --- |
| Import | `0x6000` | `0x2B4` | exactly `.idata`'s VirtualSize |
| Base relocation | `0x7000` | `0x1E8` | within `.reloc` |

All others are empty. In particular, there is **no Resource directory** (no icons, dialogs or other Windows resources), and no security directory.

### 3.3 Sections

| # | Name | VirtualAddress | VirtualSize | PointerToRawData | SizeOfRawData | Characteristics |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `.text` | `0x1000` | `0x1520` | `0x400` | `0x1600` | `0x60000020` code, execute, read |
| 2 | `.bss` | `0x3000` | `0x420` | — | 0 | `0xC0000080` uninitialized data, read, write |
| 3 | `.rdata` | `0x4000` | `0xC` | `0x1A00` | `0x200` | `0x40000040` initialized data, read |
| 4 | `.data` | `0x5000` | `0x974` | `0x1C00` | `0xA00` | `0xC0000040` initialized data, read, write |
| 5 | `.idata` | `0x6000` | `0x2B4` | `0x2600` | `0x400` | `0xC0000040` initialized data, read, write |
| 6 | `.reloc` | `0x7000` | `0x252` | `0x2A00` | `0x400` | `0x42000040` initialized data, read, discardable |

Raw data ends at `0x2E00` = 11,776 bytes, the file size, so **there is no overlay**.

### 3.4 Entry point

- RVA `0x1105` → VA `0x00401105`.
- It lies in `.text`: `0x1000 ≤ 0x1105 < 0x2520`.
- File offset `0x1105 − 0x1000 + 0x400` = **`0x505`**.
- The code at the entry point was not examined.

### 3.5 Internal consistency checks (arithmetic)

- **Section boundaries:** each section's virtual end, rounded up to `0x1000`, equals the next VirtualAddress. The last equals SizeOfImage `0x8000`. Pass ×6.
- **Raw layout:** the raw sections are contiguous, and the last ends at the file size. Pass.
- **Header area:** section-table end `0x178 + 6×40 = 0x268` ≤ SizeOfHeaders `0x400` = first raw pointer. Pass.
- **Size fields:**
  - SizeOfCode 5,632 = `.text` raw `0x1600`. Pass.
  - SizeOfInitializedData 5,120 = raw sizes of `.rdata` + `.data` + `.idata` + `.reloc` (512 + 2,560 + 1,024 + 1,024). Pass.
  - SizeOfUninitializedData 1,536 = `.bss` VirtualSize `0x420` rounded up to `0x200`. This is an observed relationship.
- **Import count:** 23 + 1 = 24.

### 3.6 Static imports (2 DLLs, 24 functions; all by name)

| DLL (descriptor order) | Count | OriginalFirstThunk | FirstThunk |
| --- | ---: | --- | --- |
| `KERNEL32.dll` | 23 | `0x603C` | `0x60A4` |
| `USER32.dll` | 1 | `0x609C` | `0x6104` |

Both descriptors have TimeDateStamp 0 and ForwarderChain 0, and both were read via OriginalFirstThunk. There are no ordinal imports.

Functions in **original lookup-table order**:

- **`KERNEL32.dll` (23):** ExitProcess, DeleteFileA, Sleep, SetFileAttributesA, GetSystemDirectoryA, GetFileAttributesA, GetTempPathA, GetModuleHandleA, GetStartupInfoA, GetEnvironmentStrings, GetCommandLineA, GetVersion, GetLastError, RtlUnwind, UnhandledExceptionFilter, GetModuleFileNameA, GetACP, GetOEMCP, GetCPInfo, GetStdHandle, GetFileType, VirtualFree, VirtualAlloc
- **`USER32.dll` (1):** MessageBoxA

## 4. Comparison with `PITFALL.EXE` (R2.1)

### 4.1 Header comparison (Verified field values)

| Field | `PITFALL.EXE` (R2.1) | `PITSTART.EXE` | `KILLPIT.EXE` |
| --- | --- | --- | --- |
| Format / machine / subsystem | PE32 / x86 / GUI | PE32 / x86 / GUI | PE32 / x86 / GUI |
| Subsystem version | 4.0 | 4.0 | 4.0 |
| Linker version | 2.55 | 2.55 | 2.55 |
| Image version | **1.0** | **0.0** | **0.0** |
| Sections | 7 (`.text .bss .rdata .data .idata .rsrc .reloc`) | 7 (same names and order) | 6 (same, without `.rsrc`) |
| ImageBase / alignments | `0x400000` / `0x1000` / `0x200` | same | same |
| CheckSum / DllCharacteristics | 0 / 0 | 0 / 0 | 0 / 0 |
| Overlay | none | none | none |
| TimeDateStamp field (UTC) | 1995-09-15 23:53:45 | 1995-09-16 05:07:40 | 1995-07-26 10:17:30 |

### 4.2 Discrepancy D-EXE-2: timestamp fields vs disc directory date (not interpreted)

**Verified field values:** every ISO directory record on the disc is dated 1995-08-24 00:01:00 (GMT+0; see [disc-contents.md](disc-contents.md)). Measured against that date, the PE timestamp fields fall:

| File | Relative to the ISO directory date |
| --- | --- |
| `PITFALL.EXE` | 22 d 23:52:45 **after** (D-EXE-1, R2.1) |
| `PITSTART.EXE` | 23 d 05:06:40 **after**, and 5 h 13 m 55 s after `PITFALL.EXE`'s |
| `KILLPIT.EXE` | 28 d 13:43:30 **before** |

**Not tested:** the reason. As in R2.1, PE timestamp fields and ISO directory dates depend on build- and mastering-machine clocks and tools. No conclusion is drawn about which dates are accurate.

### 4.3 Import comparison (from the recorded lists)

| File and DLL | Imports | Also imported by `PITFALL.EXE` | Not imported by `PITFALL.EXE` |
| --- | ---: | ---: | --- |
| `PITSTART` KERNEL32 | 34 | 29 | CopyFileA, FindClose, FindFirstFileA, GetWindowsDirectoryA, SetCurrentDirectoryA |
| `PITSTART` USER32 | 33 | 29 | GetDesktopWindow, GetMessageA, InvalidateRect, SetWindowTextA |
| `PITSTART` GDI32 | 12 | 12 | — |
| `PITSTART` ADVAPI32 | 8 | 6 | RegDeleteKeyA, RegEnumKeyA |
| `PITSTART` MSVFW32 | 1 | 0 (DLL not imported by `PITFALL.EXE`) | MCIWndCreateA |
| `PITSTART` WINMM | 4 | 4 | — |
| `KILLPIT` KERNEL32 | 23 | 23 | — |
| `KILLPIT` USER32 | 1 | 1 | — |

- `PITSTART.EXE` imports nothing from COMCTL32.
- `KILLPIT.EXE` imports nothing from ADVAPI32, COMCTL32, GDI32 or WINMM.
- Of `KILLPIT.EXE`'s KERNEL32 imports, only `Sleep` is absent from `PITSTART.EXE`'s list.
- **Notable absences (Verified for static imports only):** neither file statically imports `LoadLibraryA` or `GetProcAddress`, which `PITFALL.EXE` does. Neither imports any DirectX DLL, `WAIL32.DLL`, or process-control functions such as `OpenProcess` or `TerminateProcess`.

## 5. Interpretation

Everything here beyond the "Verified" facts is interpretation. None of it is a compatibility conclusion.

| # | Statement | Label |
| --- | --- | --- |
| J1 | Both files are 32-bit x86 Windows GUI programs with subsystem version 4.0, the same build profile as `PITFALL.EXE`. Both use linker version field 2.55. | Fields: **Verified**. A shared toolchain: **Assumption** (field values only) |
| J2 | `PITSTART.EXE`'s imports would let it start another program (`CreateProcessA`), copy and delete files (`CopyFileA`, `DeleteFileA`, `SetFileAttributesA`), look for files (`FindFirstFileA`/`FindClose`), use the Windows, system and temp directories, and create, enumerate, change and delete registry keys. This is consistent with a launcher or setup role (e.g. preparing files or settings, then starting `PITFALL.EXE`). | Imports: **Verified**. Role: **Assumption**. Behavior: **Not tested** |
| J3 | `MSVFW32.dll!MCIWndCreateA` creates a Video for Windows MCI playback window. This is consistent with `PITSTART.EXE` playing video, possibly the disc's `ASSETS/INTRO.AVI`. `sndPlaySoundA` is consistent with playing a sound file, possibly `ASSETS/PITSTART.WAV`. | Imports: **Verified**. Which files are played: **Assumption**. Not tested |
| J4 | `PITSTART.EXE`'s resource section is 536 KiB of a 557 KiB file. Its contents (e.g. bitmaps, dialogs) are unknown. | Size: **Verified**. Contents: **Not tested** |
| J5 | `KILLPIT.EXE`'s imports support file deletion (`DeleteFileA`, `SetFileAttributesA`), locating the system and temp directories, waiting (`Sleep`) and showing a message box. They include **no** process-control, window-finding or registry functions, and no run-time library loading through `LoadLibraryA`/`GetProcAddress`. So **its static imports do not support the filename-based guess that it terminates the game process**. Whatever "KILL" refers to, a file-deletion or clean-up role is equally consistent with these imports. | Imports and absences: **Verified**. Role: **Assumption**. Behavior: **Not tested** |
| J6 | Without `LoadLibraryA`/`GetProcAddress`, ordinary run-time loading of extra libraries is less likely for both files than for `PITFALL.EXE`. Other mechanisms cannot be excluded statically. | **Assumption** |
| J7 | Image version 0.0 (versus 1.0 for `PITFALL.EXE`) and the differing timestamp fields show that the three were not built with identical settings or at the same recorded time. The significance is unknown. | Field values: **Verified**. Significance: **Not tested** |

### Questions for later testing (hypotheses only)

| # | Question | Basis |
| --- | --- | --- |
| Q9 | Is Video for Windows (`MSVFW32.dll`, `MCIWndCreateA`) present and functional on Windows 10/11 for this AVI? | J3 |
| Q10 | Which files does `PITSTART.EXE` copy or delete, which registry keys does it create, enumerate or delete, and which program does it start? | J2 |
| Q11 | Do those file and registry operations need permissions that modern Windows restricts (e.g. writing to the Windows or system directory)? | J2 |
| Q12 | What does `KILLPIT.EXE` delete, and when is it run? | J5 |
| Q13 | What do `PITSTART.EXE`'s resources contain? This would be a read-only resource-type listing, separately scoped. | J4 |

## 6. Evidence limits

- **Claude-reported:** every value in §2–§4 was produced by the reviewed and synthetic-tested replacement parser (`tools/inspect-pe.ps1`, blob `1299ce51…`), run by Claude. The fingerprints were checked by the parser before parsing.
- **Not independent:** no independent party has reproduced these results. A reviewer can recompute the arithmetic from this report, but cannot check the bytes without the image.
- **Mapping policy:** the parser bounds address mapping by VirtualSize. That is the tool's policy, not a claim about Windows loader behavior.

## 7. Not tested / out of scope

- Disassembly or decompilation, including the code at either entry point.
- Strings inside either file, including any file, registry or program names they may reference.
- Resource contents or types (`PITSTART.EXE` `.rsrc`); base-relocation entries; DOS stub contents.
- Execution, loading or debugging; run-time library loading; file, registry or process activity.
- Presence and behavior of the imported functions on Windows 10/11, including `MSVFW32.dll`.
- `WAIL32.DLL`, `.PH` files and other disc files (not read).
- Comparison with other copies of these files (no reference hashes are available).
- Independent reproduction by another party.

## 8. Reproduction and proposed follow-ups

**Reproduction** (with the MEDIA-001 image; see [`tools/README.md`](../../tools/README.md)):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\inspect-pe.ps1 -Image private\original-media\Pitfall_The_Mayan_Adventure_ISO\Pitfall.img -Extent 8449 -Size 570368 -ExpectedSha256 601FA7E7BEEF140D3D626F5B9CFD010386C76438850DDA30D4F8E637380C0257
powershell -NoProfile -ExecutionPolicy Bypass -File tools\inspect-pe.ps1 -Image private\original-media\Pitfall_The_Mayan_Adventure_ISO\Pitfall.img -Extent 4214 -Size 11776 -ExpectedSha256 5807EA8603F5A15624CF2C10D94809E0846D4602C82C6D7680E43028925B4AF6
```

**Expected result:** both print `SHA-256 check: matches expected value`, the values in §2 and §3, and `RESULT: OK`, with exit code 0.

**Proposed follow-ups** (each needs separate user approval):
1. **`WAIL32.DLL` static check:** exports and imports, without loading the DLL. This would need export-table support, which the current parser does not have, so it would be a reviewed tool change.
2. **Resource-type enumeration** for `PITSTART.EXE` and `PITFALL.EXE`: types, IDs and sizes only, with no extraction (Q13).
3. **Run-time behavior** (Q10–Q12): observing what `PITSTART.EXE` and `KILLPIT.EXE` actually do. This requires execution under its own approved test plan and environment.
