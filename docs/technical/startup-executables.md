# R2.2 — `PITSTART.EXE` and `KILLPIT.EXE` static analysis: PE headers and static imports

**Report ID:** R2.2
**Status:** committed on `main` (`323a03c`, `e08d2dc`).
- **First audit** (2026-10-16, recorded at the time as "ChatGPT Chat 2"): **Accept with corrections**. The documentation corrections, marked *[R2.2-Cn]*, are in `6629328`.
- **Final result:** **Work's follow-up ACCEPT** of the R2.2 corrections in `6629328`, reviewed on GitHub at `06ee277`. No further technical corrections.
- **Workflow note:** on 2026-10-16 the user replaced the numbered-chat roles with a two-agent workflow (see `CLAUDE.md` → Roles). The reviewer recorded in this report as "Chat 2" is the Work reviewer role. Both reviews are from the same reviewer, so they are **not** separate independent verifications. Older mentions of "Chat 2" below are kept as originally recorded.
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
  - One DLL, `MSVFW32.dll` (Video for Windows), is absent from `PITFALL.EXE`'s recorded static imports. `PITSTART.EXE` imports only `MCIWndCreateA` from it. **Verified.** *[R2.2-C1]*
  - About 96% of its bytes are in its resource section. Those resources were **not examined**.
- **`KILLPIT.EXE`:**
  - A small program that imports 24 functions from just 2 DLLs: 23 from KERNEL32 and `MessageBoxA` from USER32. **Verified.**
  - It declares no PE Resource directory and has no section named `.rsrc`. **Verified.** *[R2.2-C4]*
  - Every function it imports also appears in `PITFALL.EXE`'s imports. **Verified.**
- **Not established:** what either program does. Interpretations from function names are labeled **Assumption** in §5. No original game code was executed; only the read-only parser was run. *[R2.2-C2]* Nothing in this report is a compatibility result.

## 1. Scope and method

**Pre-check** (no game data read):
- The checkout was clean on `main` at `29589a7`.
- `tools/inspect-pe.ps1` had Git blob `1299ce51c5f69d1c5ed1612291a35e89e27cbb07`, the reviewed version.
- Its LF-normalized SHA-256 was `81FDEB05637DB9C35072EB768EEAF2FFFF3105749771A516F534CE23A13C193C`, the reviewed value.

**Runs** (Windows PowerShell 5.1.26100.9444, `-NoProfile -NonInteractive`), in this order:
1. `inspect-pe.ps1 -Image <MEDIA-001 image> -Extent 8449 -Size 570368 -ExpectedSha256 601FA7E7…0C0257`
   - fingerprint matched before parsing; `RESULT: OK`, exit code 0.
2. `inspect-pe.ps1 -Image <MEDIA-001 image> -Extent 4214 -Size 11776 -ExpectedSha256 5807EA86…B4AF6` *[R2.2-C3: the abbreviation previously ended in a mistyped `…ADE3A`; the full value is in the subject table]*
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

All others are empty. In particular, **no PE Resource directory is declared**, no section is named `.rsrc`, and there is no security directory. *[R2.2-C4]*

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
- **Notable absences (Verified for static imports only):** neither file statically imports `LoadLibraryA` or `GetProcAddress`, which `PITFALL.EXE` does. Neither imports any DirectX DLL or `WAIL32.DLL`, and neither statically imports `OpenProcess` or `TerminateProcess`. *[R2.2-C5]*
- **Process-related imports that *are* present:** both import `ExitProcess`, which ends the calling process itself, and `PITSTART.EXE` imports `CreateProcessA`. What either program actually does with them is **Not tested**.

## 5. Interpretation

Everything here beyond the "Verified" facts is interpretation. None of it is a compatibility conclusion.

| # | Statement | Label |
| --- | --- | --- |
| J1 | Both files are 32-bit x86 Windows GUI programs with subsystem version 4.0 and linker version field 2.55, matching `PITFALL.EXE` in these selected header fields. | Fields: **Verified**. A shared toolchain: **Assumption** (field values only) |
| J2 | `PITSTART.EXE`'s imports would let it start another program (`CreateProcessA`), copy and delete files (`CopyFileA`, `DeleteFileA`, `SetFileAttributesA`), look for files (`FindFirstFileA`/`FindClose`), use the Windows, system and temp directories, and create, enumerate, change and delete registry keys. This is consistent with a launcher or setup role (e.g. preparing files or settings, then starting `PITFALL.EXE`). | Imports: **Verified**. Role: **Assumption**. Behavior: **Not tested** |
| J3 | **API semantics** (*Reported*: Microsoft's documentation of `MCIWndCreateA`, <https://learn.microsoft.com/en-us/windows/win32/api/vfw/nf-vfw-mciwndcreatea>, as cited by Chat 2's audit; not re-fetched): `MCIWndCreateA` creates an MCI window that can open and play media such as AVI files. **Observation:** `PITSTART.EXE` imports it. **Hypothesis:** `PITSTART.EXE` plays video, possibly the disc's `ASSETS/INTRO.AVI`. Likewise, `sndPlaySoundA` could play a sound file, possibly `ASSETS/PITSTART.WAV`. | Import: **Verified**. API meaning: **Reported**. Which files, if any, are played: **Assumption**. Behavior: **Not tested** |
| J4 | `PITSTART.EXE`'s `.rsrc` section has a raw size of 549,376 bytes (≈ 536.5 KiB) in a 570,368-byte (≈ 557.0 KiB) file. Its declared Resource directory size is 548,944 bytes (≈ 536.1 KiB). Its contents (e.g. bitmaps, dialogs) are unknown. | Sizes: **Verified**. Contents: **Not tested** |
| J5 | `KILLPIT.EXE`'s static imports include functions for deleting files (`DeleteFileA`, `SetFileAttributesA`), locating the system and temp directories, waiting (`Sleep`), showing a message box, and ending its own process. That last function, `ExitProcess`, ends only the calling process (*Reported*: Microsoft documentation, <https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess>, as cited by Chat 2). They include no static imports of `OpenProcess` or `TerminateProcess`, no window-finding functions such as `FindWindowA`, no ADVAPI32 (registry) functions, and neither `LoadLibraryA` nor `GetProcAddress`. So **its static imports do not support the filename-based guess that it terminates the game process**. Static imports cannot show run-time behavior, so they do not rule it out either. A file-deletion or clean-up role is also consistent with these imports. *[R2.2-C5]* | Imports and absences: **Verified** (static imports only). Role: **Assumption**. Termination or any other behavior: **Not tested** |
| J6 | Neither file statically imports `LoadLibraryA` or `GetProcAddress`. Whether either file loads libraries at run time is not established. *[R2.2-C6]* | Absence: **Verified** (static imports only). Run-time loading: **Not tested** |
| J7 | The recorded image-version fields (0.0 for both files, 1.0 for `PITFALL.EXE`) and the timestamp fields differ among the three files. Actual build settings, chronology, and the reasons for the differences are not established. *[R2.2-C7]* | Field values: **Verified**. Build settings, chronology, reasons: **Not tested** |

### Questions for later testing (hypotheses only)

| # | Question | Basis |
| --- | --- | --- |
| Q9 | If `PITSTART.EXE` uses `MCIWndCreateA` to play video (for example `INTRO.AVI`), is Video for Windows (`MSVFW32.dll`) present and functional for it on Windows 10/11? | J3 |
| Q10 | At run time, does `PITSTART.EXE` copy or delete files, create, enumerate or delete registry keys, or start another program? If so, which? | J2 |
| Q11 | If it performs such file or registry operations, do they need permissions that modern Windows restricts (e.g. writing to the Windows or system directory)? | J2 |
| Q12 | Does `KILLPIT.EXE` delete files at run time? If so, which ones, and when or by what is it run? | J5 |
| Q13 | What do `PITSTART.EXE`'s resources contain? This would be a read-only resource-type listing, separately scoped. | J4 |

## 6. Evidence limits

The values in this report come from three kinds of source *[R2.2-C8]*:

1. **New parser observations (Claude-reported, this examination):**
   - every header, directory, section, entry-point and import value for `PITSTART.EXE` and `KILLPIT.EXE` in §2–§3, and in their columns of §4.1;
   - the source is the reviewed and synthetic-tested replacement parser (`tools/inspect-pe.ps1`, blob `1299ce51…`), run by Claude, with fingerprints checked by the parser before parsing.
2. **Earlier reports, reused here:**
   - the `PITFALL.EXE` values and import lists (R2.1, [`executable.md`](executable.md), accepted by Chat 2);
   - the ISO directory date 1995-08-24 00:01:00 ([`disc-contents.md`](disc-contents.md), examiner-reported).
3. **Derivations a reviewer can recompute from this report:**
   - the consistency arithmetic in §2.5 and §3.5;
   - the timestamp differences in §4.2;
   - the import set comparisons in §4.3.

**Not independent:** no independent party has reproduced the parser observations. Chat 2's audit (2026-10-16) recomputed the derivations and checked agreement with the committed documents, but did not inspect the bytes.
- **Mapping policy:** the parser bounds address mapping by VirtualSize. That is the tool's policy, not a claim about Windows loader behavior.

## 7. Not tested / out of scope

- Disassembly or decompilation, including the code at either entry point.
- Strings inside either file, including any file, registry or program names they may reference.
- Resource contents or types (`PITSTART.EXE` `.rsrc`); base-relocation entries; DOS stub contents.
- Execution, loading or debugging; run-time library loading; file, registry or process activity.
- Presence and behavior of the imported functions on Windows 10/11, including `MSVFW32.dll`.
- `WAIL32.DLL`, `.PH` files and other disc files (not read).
- Comparison with other copies of these files (no reference hashes are available).
- Transitive dependencies: libraries that the imported DLLs themselves load.
- Whether any imported function is actually called. A static import list shows what the program links to, not what it uses at run time.
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
