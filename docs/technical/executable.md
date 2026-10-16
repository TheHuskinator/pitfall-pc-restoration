# R2.1 — `PITFALL.EXE` static analysis: PE header and static imports

**Report ID:** R2.1
**Status:** **Accepted** by ChatGPT Chat 2 in its final review (2026-10-15), after its first audit ("Accept with corrections"). All seven required corrections are applied and verified (marked *[R2.1-Cn]*).
**Examination date:** 2026-10-15 · **Finalized:** 2026-10-15 · **Revised:** 2026-10-15
**Examiner:** Claude Code
**Approval:** user-approved read-only PE header/import check (2026-10-15), within the limits proposed by Chat 2 (tracker item C-f in [media-001-audit-tracker.md](../reviews/media-001-audit-tracker.md)).
**Subject:** `ASSETS/PITFALL.EXE` inside disc image MEDIA-001 (`private/original-media/Pitfall_The_Mayan_Adventure_ISO/Pitfall.img`).

| Subject identifier | Value |
| --- | --- |
| Size | 772,608 bytes |
| ISO extent | Block 8070; occupies 378 blocks, LBA 8070–8447 |
| SHA-256 | `36047291632BEAD27D3AF09EE99BBEF1EEC06F3B9FEA53DB906ECB1E74BFFA86` (matches [materials-inventory.md](../inventory/materials-inventory.md)) |

## Evidence labels used

| Label | Meaning in this report |
| --- | --- |
| **Verified** | Read directly from the file bytes with the hash above, or derived by arithmetic from such values. Offsets are given. |
| **Reported** | Stated by an outside source (cited) and not checked here. |
| **Assumption** | An interpretation, e.g. from function or section names. It may be wrong. |
| **Not tested** | Outside this task's scope or not attempted. |

## Plain-English summary

- `PITFALL.EXE` is a **32-bit Windows program for Intel x86 processors (PE32)**, marked as a Windows GUI (graphical, not console) program. **Verified.**
- The file's COFF timestamp field decodes to **1995-09-15 23:53:45 UTC**. **Verified** (field value). The actual compile or link time is **not established** by this field. *[R2.1-C1]*
- Its static import list (the Windows libraries named in the file) contains 6 standard Windows system DLLs and 180 functions. **Verified.**
- **No DirectX DLL and no `WAIL32.DLL` are in that list. Verified.** The program can load libraries while running, so whether it uses either one at run time is **Not tested**.
- Whether these DLLs and functions all still behave the same on Windows 10/11 is **Not tested**. Nothing in this report is a compatibility result.

## 1. Scope and method

**Done** (all read-only):
1. Opened `Pitfall.img` with .NET `FileStream` (`FileAccess.Read`, `FileShare.Read`).
2. Copied the 2,048-byte Mode 1 user-data area of LBA 8070–8447 into an in-memory buffer, truncated to 772,608 bytes.
3. Computed SHA-256 of the buffer and compared it with the inventory **before** any parsing. It matched.
4. Parsed the DOS header, PE signature, COFF header, PE32 optional header, the 16 data-directory entries, the 7-entry section table, the entry-point location, and the import directory (descriptors, lookup tables, hint/name entries).
5. Cross-checked the parsed values against each other by arithmetic (§5).

**Environment:** Windows 11 Home 10.0.26200; Windows PowerShell 5.1.26100.9444; .NET CLR 4.0.30319.42000. No tools were installed.

**Script:** session-local and **not committed**. Adding it to `tools/` is proposed in §9.

**Integrity before and after:** the image SHA-256 (`EDCE93BE…E147172`) was re-checked after the examination and is unchanged. All MEDIA-001 data sectors, including those of this file, were previously reported to pass EDC (`tools/verify-media001.ps1`, 2026-10-15).

**Not tested / not done:** see §8.

## 2. Header findings (Verified)

Structure locations (file offsets):
- DOS header at `0x0`
- `e_lfanew` (stored at `0x3C`) = **`0x80`**
- PE signature at `0x80`
- COFF header at `0x84`
- Optional header at `0x98` (224 bytes)
- Section table at `0x178`

### 2.1 DOS and PE signatures

| Field | Offset | Value |
| --- | --- | --- |
| `e_magic` | `0x00` | `MZ` |
| `e_lfanew` | `0x3C` | `0x80` |
| PE signature | `0x80` | `50 45 00 00` (`PE\0\0`) |

The DOS stub between `0x40` and `0x80` was not examined.

### 2.2 COFF file header (at `0x84`)

| Field | Value | Meaning |
| --- | --- | --- |
| Machine | `0x014C` | Intel 386 (x86) |
| NumberOfSections | 7 | |
| TimeDateStamp | `0x305A1209` = 811,209,225 | Decodes, as seconds since 1970-01-01 UTC, to 1995-09-15 23:53:45 UTC. This is the recorded field value. The actual compile or link time is **not independently established**: the field depends on the build machine's clock and toolchain. *[R2.1-C1]* |
| PointerToSymbolTable / NumberOfSymbols | 0 / 0 | No COFF symbol table |
| SizeOfOptionalHeader | 224 (`0xE0`) | Standard PE32 size |
| Characteristics | `0x010E` | `0x0002` executable image · `0x0004` line numbers stripped · `0x0008` local symbols stripped · `0x0100` 32-bit machine. **Not set:** `0x0001` relocations stripped (so relocations are present), `0x2000` DLL, `0x0020` large-address-aware. |

### 2.3 Optional header (PE32, at `0x98`)

| Field | Value |
| --- | --- |
| Magic | `0x10B` (PE32, 32-bit) |
| Linker version | 2.55 (the value only; the toolchain is **not identified** — see §6, I8) |
| SizeOfCode / SizeOfInitializedData / SizeOfUninitializedData | 321,536 / 450,048 / 18,944 bytes |
| AddressOfEntryPoint (RVA) | `0x0004AC60` |
| BaseOfCode / BaseOfData | `0x1000` / `0x50000` |
| ImageBase | `0x00400000` |
| SectionAlignment / FileAlignment | `0x1000` / `0x200` |
| Operating system version | 1.0 |
| Image version | 1.0 |
| Subsystem version | 4.0 |
| Win32VersionValue | 0 |
| SizeOfImage / SizeOfHeaders | `0xC6000` / `0x400` |
| CheckSum | `0x00000000` (not set) |
| Subsystem | 2 = Windows GUI |
| DllCharacteristics | `0x0000`: no dynamic-base (ASLR), NX-compatible (DEP), no-SEH or other flags |
| Stack reserve / commit | `0x100000` (1 MiB) / `0x1000` (4 KiB) |
| Heap reserve / commit | `0x100000` (1 MiB) / `0x1000` (4 KiB) |
| LoaderFlags / NumberOfRvaAndSizes | 0 / 16 |

### 2.4 Data directories

Only three of the 16 directories are non-empty. RVA is the address relative to the image base, once loaded.

| Directory | RVA | Size | Contained in |
| --- | --- | --- | --- |
| Import (1) | `0x00074000` | `0x11EE` | `.idata`, exactly (same start and size) |
| Resource (2) | `0x00076000` | `0x3FD84` (261,508 B ≈ 255.4 KiB) | `.rsrc`, exactly |
| Base relocation (5) | `0x000B6000` | `0xF078` | `.reloc` (virtual size `0xF790`) |

All other directories are **empty (0, 0)**: Export, Exception, Security (no embedded Authenticode certificate table is declared; this says nothing about possible external catalog signatures *[R2.1-C2]*), Debug, Architecture, GlobalPtr, TLS, Load Config, Bound Import, IAT, Delay Import, CLR and Reserved.

## 3. Section table (Verified; table at `0x178`)

| # | Name | VirtualAddress | VirtualSize | PointerToRawData | SizeOfRawData | Characteristics | Decoded flags |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `.text` | `0x00001000` | `0x0004E724` | `0x00000400` | `0x0004E800` | `0x60000020` | code, execute, read |
| 2 | `.bss` | `0x00050000` | `0x0000486C` | `0x00000000` | `0x00000000` | `0xC0000080` | uninitialized data, read, write |
| 3 | `.rdata` | `0x00055000` | `0x00000229` | `0x0004EC00` | `0x00000400` | `0x40000040` | initialized data, read |
| 4 | `.data` | `0x00056000` | `0x0001D17C` | `0x0004F000` | `0x0001D200` | `0xC0000040` | initialized data, read, write |
| 5 | `.idata` | `0x00074000` | `0x000011EE` | `0x0006C200` | `0x00001200` | `0xC0000040` | initialized data, read, write |
| 6 | `.rsrc` | `0x00076000` | `0x0003FD84` | `0x0006D400` | `0x0003FE00` | `0x40000040` | initialized data, read |
| 7 | `.reloc` | `0x000B6000` | `0x0000F790` | `0x000AD200` | `0x0000F800` | `0x42000040` | initialized data, read, discardable |

**Overlay:** the last section's raw data ends at `0xAD200 + 0xF800 = 0xBCA00` = 772,608, exactly the file size. There are **0 bytes** after the last section.

The names suggest a conventional layout: code, uninitialized data, read-only data, data, imports, resources, relocations. That reading is an **Assumption**, since section names are conventions and not enforced.

## 4. Entry point (Verified by calculation)

| Step | Calculation | Result |
| --- | --- | --- |
| Entry-point RVA | from the optional header | `0x0004AC60` |
| Virtual address when loaded at the preferred base | `0x00400000 + 0x0004AC60` | `0x0044AC60` |
| Containing section | `.text` covers RVA `0x1000` to `0x1000 + 0x4E724 = 0x4F724`, and `0x1000 ≤ 0x4AC60 < 0x4F724` | `.text` (code, execute, read) |
| File offset | `RVA − VirtualAddress + PointerToRawData = 0x4AC60 − 0x1000 + 0x400` | **`0x0004A060`** (303,200), inside `.text`'s raw range `0x400`–`0x4EC00` |

The code at the entry point was **not** disassembled (Not tested).

## 5. Internal consistency checks (Verified by arithmetic)

| Check | Result |
| --- | --- |
| Each section's virtual end, rounded up to `0x1000`, equals the next section's VirtualAddress | Pass for all 6 boundaries |
| The last section's virtual end (`0xB6000 + 0xF790`, rounded) equals SizeOfImage `0xC6000` | Pass |
| Raw sections are contiguous: each PointerToRawData + SizeOfRawData = the next PointerToRawData (`.bss` has no raw data) | Pass |
| SizeOfHeaders `0x400` = the first raw section pointer | Pass |
| SizeOfCode 321,536 = `.text` SizeOfRawData `0x4E800` | Pass |
| SizeOfInitializedData 450,048 = the sum of raw sizes of `.rdata`, `.data`, `.idata`, `.rsrc` and `.reloc` (1,024 + 119,296 + 4,608 + 261,632 + 63,488) | Pass |
| SizeOfUninitializedData 18,944 = `.bss` VirtualSize `0x486C` rounded up to FileAlignment `0x200` (`0x4A00`) | Observed match. This is a numerical relationship seen in this file, **not** a rule the PE specification requires. *[R2.1-C3]* |
| The Import and Resource directories coincide exactly with `.idata` and `.rsrc`; Base relocation lies within `.reloc` | Pass |
| Import function count: 4 + 63 + 17 + 64 + 26 + 6 | 180 |

**No internal inconsistencies were found.**

## 6. Static imports (Verified; 6 DLLs, 180 functions)

**How they were read:**
- The import directory starts at RVA `0x74000`, which is file offset `0x6C200`.
- Each 20-byte descriptor was read until an all-zero terminator.
- For each descriptor, the DLL name and its lookup table (OriginalFirstThunk) were read.
- Each 32-bit entry with the high bit set is an ordinal import (written `#n` below). Otherwise it points to a 2-byte hint followed by the function name.

**Descriptor properties:**
- All six descriptors have a non-zero OriginalFirstThunk.
- All have TimeDateStamp = 0, meaning the imports are not pre-bound.

| DLL (descriptor order) | Count | OriginalFirstThunk | FirstThunk (IAT) |
| --- | ---: | --- | --- |
| `COMCTL32.dll` | 4 | `0x740A8` | `0x74390` |
| `KERNEL32.dll` | 63 | `0x74128` | `0x74410` |
| `WINMM.dll` | 17 | `0x7432C` | `0x74614` |
| `USER32.dll` | 64 | `0x74228` | `0x74510` |
| `GDI32.dll` | 26 | `0x740BC` | `0x743A4` |
| `ADVAPI32.dll` | 6 | `0x7408C` | `0x74374` |
| **Total** | **180** | | |

Complete function lists, reformatted for readability:
- The lists are roughly alphabetical, not strictly sorted. For example, KERNEL32's `_l*` functions come first, and COMCTL32's ordinals are in numeric order.
- **The original lookup-table (thunk) order was not retained** in this report. *[R2.1-C4]*

**`ADVAPI32.dll` (6):** RegCloseKey, RegCreateKeyA, RegFlushKey, RegOpenKeyA, RegQueryValueExA, RegSetValueExA

**`COMCTL32.dll` (4):** ordinal #5, ordinal #6, ordinal #17, PropertySheetA. Ordinals carry no name in the file; their function names are **not** asserted here.

**`GDI32.dll` (26):** AnimatePalette, BitBlt, CreateCompatibleBitmap, CreateCompatibleDC, CreateDIBSection, CreateFontIndirectA, CreatePalette, DeleteDC, DeleteObject, GdiFlush, GetDeviceCaps, GetObjectA, GetStockObject, GetSystemPaletteEntries, GetSystemPaletteUse, RealizePalette, SelectObject, SelectPalette, SetBkMode, SetDIBColorTable, SetDIBits, SetStretchBltMode, SetSystemPaletteUse, SetTextColor, StretchBlt, TextOutA

**`KERNEL32.dll` (63):** _lclose, _lcreat, _llseek, _lopen, _lwrite, CloseHandle, CreateFileA, CreateProcessA, DeleteCriticalSection, DeleteFileA, EnterCriticalSection, ExitProcess, FindResourceA, FlushFileBuffers, FreeLibrary, GetACP, GetCommandLineA, GetCPInfo, GetCurrentProcess, GetCurrentThreadId, GetEnvironmentStrings, GetFileAttributesA, GetFileType, GetLastError, GetModuleFileNameA, GetModuleHandleA, GetOEMCP, GetProcAddress, GetStartupInfoA, GetStdHandle, GetSystemDirectoryA, GetTempPathA, GetVersion, GlobalAlloc, GlobalFree, GlobalLock, GlobalReAlloc, GlobalUnlock, InitializeCriticalSection, LeaveCriticalSection, LoadLibraryA, LoadModule, LoadResource, LocalAlloc, LocalFree, LockResource, MultiByteToWideChar, ReadFile, RtlUnwind, SetErrorMode, SetFileAttributesA, SetFilePointer, SetPriorityClass, SetStdHandle, Sleep, TlsAlloc, TlsGetValue, TlsSetValue, UnhandledExceptionFilter, VirtualAlloc, VirtualFree, WideCharToMultiByte, WriteFile

**`USER32.dll` (64):** AdjustWindowRect, BeginPaint, CallWindowProcA, CheckDlgButton, CheckMenuItem, CheckRadioButton, ClientToScreen, CopyRect, CreateDialogParamA, CreateWindowExA, DefWindowProcA, DestroyMenu, DestroyWindow, DialogBoxParamA, DispatchMessageA, DrawMenuBar, EnableMenuItem, EnableWindow, EndDialog, EndPaint, FindWindowA, GetAsyncKeyState, GetClientRect, GetDC, GetDlgCtrlID, GetDlgItem, GetFocus, GetKeyNameTextA, GetMenu, GetSystemMetrics, GetWindowLongA, GetWindowRect, IsDlgButtonChecked, KillTimer, LoadBitmapA, LoadCursorA, LoadIconA, LoadMenuA, LoadStringA, MessageBeep, MessageBoxA, MoveWindow, PeekMessageA, PostMessageA, PostQuitMessage, PtInRect, RegisterClassA, ReleaseCapture, ReleaseDC, ScreenToClient, SendDlgItemMessageA, SendMessageA, SetCapture, SetCursor, SetForegroundWindow, SetMenu, SetTimer, SetWindowLongA, SetWindowPos, ShowWindow, SystemParametersInfoA, TranslateMessage, UpdateWindow, WinHelpA

**`WINMM.dll` (17):** auxGetDevCapsA, auxGetNumDevs, auxGetVolume, auxSetVolume, joyGetDevCapsA, joyGetNumDevs, joyGetPos, joyReleaseCapture, joySetCapture, mciSendCommandA, sndPlaySoundA, timeBeginPeriod, timeEndPeriod, timeGetTime, timeKillEvent, timeSetEvent, waveOutGetNumDevs

**Absent from the static imports (Verified for static imports only):**
- No DirectX DLL (`DDRAW.dll`, `DSOUND.dll`, `DINPUT.dll`, `D3D*`).
- No `WAIL32.DLL`.
- No networking DLLs (e.g. `WSOCK32.dll`).
- No OLE/COM DLLs (`OLE32.dll`, `OLEAUT32.dll`).
- No `SHELL32.dll`, no `VERSION.dll`.

## 7. Interpretation

Everything in this section beyond the "Verified" facts is interpretation. None of it is a compatibility conclusion.

| # | Statement | Label |
| --- | --- | --- |
| I1 | Subsystem version 4.0 and machine `0x014C` mean the file is built for 32-bit x86 Windows with subsystem version 4.0, the version used by Windows 95 and Windows NT 4.0. | Fields: **Verified**. Era mapping: **Assumption** (general Windows versioning knowledge) |
| I2 | Graphics output probably uses GDI with 256-colour palettes, based on `CreatePalette`, `SelectPalette`, `RealizePalette`, `AnimatePalette`, `SetSystemPaletteUse`, `CreateDIBSection`, `SetDIBColorTable` and `StretchBlt`/`BitBlt`. | **Assumption** (function names only) |
| I3 | `WAIL32.DLL` is not statically imported. Because `LoadLibraryA`, `GetProcAddress` and `FreeLibrary` are imported, the program could load `WAIL32.DLL`, DirectX or other libraries at run time. | Not imported: **Verified**. Run-time loading: **Not tested** |
| I4 | `mciSendCommandA` with `auxGetVolume`/`auxSetVolume` is consistent with controlling CD audio through MCI. This fits the 23 audio tracks on MEDIA-001 and the report that the music is Red Book CD audio ([S001](../research/sources.md)). | Interpretation: **Assumption**. CD-music claim: **Reported** (S001). Behavior: **Not tested** |
| I5 | Input and timing probably use WINMM joystick functions (`joy*`), `GetAsyncKeyState` and multimedia timers (`timeSetEvent`, `timeBeginPeriod`). | **Assumption** (function names only) |
| I6 | The registry functions indicate the program reads and/or writes registry values. Which keys and values is unknown. | Imports: **Verified**. Use: **Not tested** |
| I7 | `CreateProcessA` and `LoadModule` indicate the program can start other programs. Which ones, and when, is unknown. | Imports: **Verified**. Use: **Not tested** |
| I8 | Linker version field = 2.55. **The compiler/linker product is not identified**; the version number alone is not used as identification. | Value: **Verified**. Toolchain: **Not tested** |
| I9 | `WinHelpA` is imported, which is consistent with the four `PITFALL*.HLP` files on the disc. | Import: **Verified**. Link to the `.HLP` files: **Assumption** |

### Discrepancy D-EXE-1 — PE timestamp field vs. disc directory date

- **Verified (field values):**
  - The PE TimeDateStamp field decodes to **1995-09-15 23:53:45 UTC**.
  - The ISO directory record for this file, like every record on the disc, carries **1995-08-24 00:01:00 (GMT+0)** ([disc-contents.md](disc-contents.md)).
  - The calendar dates are 22 days apart. The exact difference between the two recorded values is **22 days, 23 hours, 52 minutes, 45 seconds**. *[R2.1-C6]*
- **Not tested:** the reason. Possibilities include a fixed or default date written by the mastering tool, an incorrect clock on either machine, or a timestamp that does not reflect wall-clock time.
- No conclusion is drawn about which date is accurate. The pairing may help distinguish builds when comparing other copies.

### Questions for future compatibility testing (hypotheses only)

These are **not findings**. They are listed only so that a later, separately approved compatibility test plan can check them.

| # | Question to test later | Basis |
| --- | --- | --- |
| Q1 | **If** the program uses 256-colour palette-based drawing (I2), how does that behavior translate to a modern true-colour Windows 10/11 desktop? *[R2.1-C5]* | I2 (Assumption) |
| Q2 | How will CD audio (I4) be supplied when running from a disc image rather than a physical CD? | I4 (Assumption) |
| Q3 | Do multimedia-timer timing (I5) and game speed behave correctly on modern hardware? | I5 (Assumption) |
| Q4 | Which registry keys are written (I6), and do modern permission rules affect them? | I6 |
| Q5 | Which libraries are loaded at run time (I3), and are they all present on Windows 10/11? | I3 |
| Q6 | Are all 180 statically imported functions present in current Windows system DLLs? | §6; **Not tested** (no Windows 10/11 export comparison was made) |
| Q7 | How do the three ordinal-only COMCTL32 imports (#5, #6, #17) resolve against the COMCTL32 versions on Windows 10/11? | §6; research target suggested by Chat 2's audit; **Not tested** |
| Q8 | Is legacy Windows Help (`WinHelpA` with `.HLP` files, I9) available on Windows 10/11 without extra components? | I9; research target suggested by Chat 2's audit; **Not tested** |

## 8. Not tested / out of scope

- Disassembly or decompilation, including the code at the entry point.
- Strings inside the executable, including any run-time library names.
- Resource section contents or a list of its types (`.rsrc` was not parsed).
- Base-relocation entries, the DOS stub contents, and any Rich header or other undocumented data before `0x80`.
- Execution, loading or debugging; run-time library loading; registry or file activity.
- Presence and behavior of the imported functions on Windows 10/11.
- `PITSTART.EXE`, `KILLPIT.EXE` and `WAIL32.DLL` (not examined).
- Comparison with any other copy of `PITFALL.EXE` (no reference hash is available).
- Cross-checking the parse with an independent PE parser, or validating the session-local parser against a known, harmless PE test file.
- Comparison with current Windows DLL exports (see Q6–Q7).
- Certificate-table contents: none is declared (security directory empty), so there was nothing to inspect.
- Dependencies reached indirectly: libraries that the six imported DLLs, or any run-time-loaded library, themselves load remain unknown.
- The original thunk order of the import lists (not retained; see §6).

## 9. Reproduction and proposed follow-ups

**Reproducibility limitation *[R2.1-C7]*:**
- This report gives enough offsets and values for anyone to **recalculate** the results.
- However, the session-local parser that produced them is not in the repository, so its results have **not been independently reproduced** from the binary.
- Chat 2's audit (2026-10-15) independently checked the arithmetic and internal consistency only, not the underlying bytes.
- Preserving the parser, with its version and validation checks, is proposed as a separately approved tooling task (follow-up 1).

An auditor with the image can reproduce the values as follows:
1. Copy the user data of LBA 8070–8447 (offset `LBA × 2352 + 16`, 2,048 bytes each, truncated to 772,608 bytes) into memory.
2. Confirm the SHA-256 above.
3. Read the fields at the offsets given in §2–§6. Any standard PE parser should report the same header, section and import values.

**Proposed follow-ups**, in the order Chat 2 recommended (each needs separate user approval):
1. **Review and preserve the PE parser** in `tools/`:
   - check that it is read-only and bounds-checked;
   - add a README with expected results;
   - optionally record the original thunk order, and validate it against a harmless known PE file.
   No embedded game bytes.
2. **R2.2:** the same header/section/entry-point/static-import check on `PITSTART.EXE` and `KILLPIT.EXE`, using the inventory hashes. No disassembly, execution, extraction or string scanning.
3. **`WAIL32.DLL` static check:** record its exports and imports without loading the DLL or examining its code.
4. **Resource-type enumeration** for `PITFALL.EXE`: types, IDs and sizes only, with no payload extraction or decoding.
5. **Run-time dependencies:**
   - a bounded static search for DLL names gives leads only;
   - executing or monitoring the game needs its own approved test plan and environment.
