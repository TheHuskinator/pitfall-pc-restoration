# R2.3 — `ASSETS/WAIL32.DLL` static analysis: PE headers, imports and exports

**Report ID:** R2.3
**Status:** **Claude-reported examination complete; pending Work review.** On review branch `draft/r2.3-wail32`, not merged into `main`.
**Transcription:** the import and export lists in §6–§7 were transcribed manually from the parser's on-screen output. No separate run transcript was retained, and the authorized single run was not repeated. Internal consistency checks (§5, and the counts) do **not** establish that the transcription is accurate; see §10.
**Examination date:** 2026-10-16
**Examiner:** Claude Code. Claude is the only examiner, and all results are Claude-reported.
**Authority:** under the user's delegated approval (`CLAUDE.md` → Roles), this follows Work's explicit recommendation of one R2.3 parser run with these limits:
- a clean `main` at `af720d7` and parser blob `3c334673…`;
- extent 6784, size 116,736, with the expected SHA-256;
- metadata only: no other game files, no forwarder resolution, no target-byte examination, no loading, execution or extraction.

**Significance:** this is the **first use of the export-enabled parser on a game file**. There is no earlier baseline for `WAIL32.DLL`.

| Subject | Value |
| --- | --- |
| File | `ASSETS/WAIL32.DLL` (MEDIA-001) |
| Size | 116,736 bytes |
| ISO extent and sectors | 6784; 57 blocks, LBA 6784–6840 |
| SHA-256 | `432D51744010E25EC82E550B4BC6422134625451F6A33FE72228528AA28C241A` (matches [materials-inventory.md](../inventory/materials-inventory.md)) |

## Evidence labels used

| Label | Meaning in this report |
| --- | --- |
| **Verified** | Printed by the reviewed parser from the file bytes with the hash above, or derived by arithmetic from such values. Claude-reported: Claude ran the parser. |
| **Reported** | Stated by an outside source (cited) and not checked here. |
| **Assumption** | An interpretation, e.g. from names. It may be wrong. |
| **Not tested** | Outside this task's scope or not attempted. |

## Plain-English summary

- **Format:** `WAIL32.DLL` is a **32-bit Windows library (PE32, x86) with the DLL flag set**. Its preferred load address is `0x20000000`. **Verified.**
- **Exports:**
  - The library declares **104 export entries, each with exactly one name**. There are no aliases, no unused entries and **no forwarders**. **Verified.**
  - All 104 export addresses classify into the code-flagged section `.text`, at addresses with stored bytes. **Verified** (classification only: section flags do not prove an entry is code rather than data, and no target bytes were examined).
  - 98 names start with `AIL_`, 4 with `FILE_` and 2 with `MEM_`. **Verified.**
- **Imports:** 65 functions from 3 Windows DLLs (KERNEL32, USER32, WINMM), including WINMM's `waveOut*` and `midiOut*` functions. **Verified.**
- **Not established:**
  - Whether the game uses this library. None of `PITFALL.EXE`, `PITSTART.EXE` or `KILLPIT.EXE` statically imports it (R2.1, R2.2). **This report is not evidence that `PITFALL.EXE` uses the DLL.**
  - Product or version identity. The name "Miles Sound System" remains an **Assumption** from the file name.
- **Nothing executed:** no original game code was executed (only the read-only parser was run), and nothing in this report is a compatibility result.

## 1. Scope and method

**Preconditions** (checked before the run; all passed):
- the checkout was clean on `main` at `af720d72074d530023389c09d4ae369ffcb65a37`;
- `tools/inspect-pe.ps1` had Git blob `3c334673f4dc6f32261cd0d745ca39af9825d6c4`, both in the working file and committed;
- the canonical MEDIA-001 image was present.

**Run** (one invocation, Windows PowerShell 5.1, `-NoProfile -NonInteractive`):

```text
inspect-pe.ps1 -Image <MEDIA-001 image> -Extent 6784 -Size 116736 -ExpectedSha256 432D51744010E25EC82E550B4BC6422134625451F6A33FE72228528AA28C241A
```

- **Result:** the SHA-256 matched **before parsing**; `RESULT: OK`, exit code 0.
- **Structural checks the parser enforced, all passed:**
  - `SizeOfHeaders` covers the section table;
  - no overlapping sections;
  - section data is inside the file;
  - import and export metadata are readable and bounded;
  - all names are terminated and printable.
- **Output handling:** the output stayed in memory and on screen, with the image path masked.
- **After the run:** arithmetic checks by hand on the printed values (§5), and a comparison with the committed import lists of R2.1 and R2.2 (§8).

**Not done:** see §11. In particular, no other game file was read, no forwarders were followed (there are none), no export target bytes were examined, and the DLL was not loaded or executed.

## 2. Headers (Verified)

| Field | Value |
| --- | --- |
| DOS header / PE signature | `MZ`; `e_lfanew` = `0x80`; signature `50 45 00 00` |
| Machine | `0x014C` (x86) |
| NumberOfSections | 7 |
| TimeDateStamp | `0x30009DFF` = 805,346,815. Decodes to **1995-07-10 03:26:55 UTC**; a field value, and the actual build time is not established. |
| Symbol table | none (pointer 0, count 0) |
| SizeOfOptionalHeader | 224 |
| Characteristics | `0x2106`: executable image, line numbers stripped, 32-bit machine, **DLL**. Not set: relocations stripped, and **local symbols stripped** (that flag *is* set in the three earlier executables). |
| Magic / linker version | `0x10B` (PE32) / 2.55 (value only) |
| SizeOfCode / InitializedData / UninitializedData | 89,088 / 23,552 / 8,704 |
| AddressOfEntryPoint | `0x115AD` (for a DLL, conventionally its initialization routine; **Assumption**, not examined) |
| BaseOfCode / BaseOfData | `0x1000` / `0x17000` |
| ImageBase | **`0x20000000`** |
| Section / file alignment | `0x1000` / `0x200` |
| OS / image / subsystem version | 1.0 / 0.0 / 4.0 |
| SizeOfImage / SizeOfHeaders | `0x22000` / `0x400` |
| CheckSum | **`0x0002A4C5`** (non-zero, unlike the three earlier executables; **not validated**) |
| Subsystem / DllCharacteristics | 2 (Windows GUI) / `0x0000` |
| Stack reserve/commit; heap reserve/commit | `0x100000`/`0x1000`; `0x100000`/`0x1000` |
| NumberOfRvaAndSizes | 16 |

### 2.1 Data directories

Four are non-empty:

| Directory | RVA | Size | Location |
| --- | --- | --- | --- |
| Export | `0x1F000` | `0xCCE` | exactly `.edata`'s virtual size |
| Import | `0x1E000` | `0x6E8` | exactly `.idata`'s virtual size |
| Base relocation | `0x20000` | `0x18E4` | within `.reloc` (virtual size `0x1948`) |
| Debug | `0x1A000` | `0x54` | within `.rdata` (virtual size `0x2D9`); **contents not examined** |

All others are empty, including Resource (none declared) and Security.

## 3. Sections (Verified)

| # | Name | VirtualAddress | VirtualSize | PointerToRawData | SizeOfRawData | Characteristics |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `.text` | `0x1000` | `0x15A20` | `0x400` | `0x15C00` | `0x60000020` code, execute, read |
| 2 | `.bss` | `0x17000` | `0x2124` | — | 0 | `0xD0000080` uninitialized data, **shared**, read, write |
| 3 | `.rdata` | `0x1A000` | `0x2D9` | `0x16000` | `0x400` | `0x40000040` initialized data, read |
| 4 | `.data` | `0x1B000` | `0x27A0` | `0x16400` | `0x2800` | `0xD0000040` initialized data, **shared**, read, write |
| 5 | `.idata` | `0x1E000` | `0x6E8` | `0x18C00` | `0x800` | `0xC0000040` initialized data, read, write |
| 6 | `.edata` | `0x1F000` | `0xCCE` | `0x19400` | `0xE00` | `0x40000040` initialized data, read |
| 7 | `.reloc` | `0x20000` | `0x1948` | `0x1A200` | `0x1A00` | `0x42000040` initialized data, discardable, read |

- **Overlay:** the raw data of the last section ends at `0x1BC00` = 113,664 bytes. The file is 116,736 bytes, so **3,072 bytes (`0xC00`) follow the last section**. Their contents were **not examined**. Whether they relate to the declared Debug directory is **not established**.
- **Shared sections:** `.bss` and `.data` carry the shared flag (`0x10000000`). That is an observation only; its run-time significance is **Not tested**.

## 4. Entry point (Verified by calculation)

- RVA `0x115AD` → VA `0x200115AD`.
- It lies in `.text`: `0x1000 ≤ 0x115AD < 0x16A20`.
- File offset `0x115AD − 0x1000 + 0x400` = **`0x109AD`**.
- The code was not examined.

## 5. Internal consistency checks (arithmetic on printed values)

- **Section boundaries:** each section's virtual end, rounded up to `0x1000`, equals the next VirtualAddress, and the last equals SizeOfImage `0x22000`. Pass ×7.
- **Raw layout:** the raw sections are contiguous from `0x400` to `0x1BC00`. Pass. (3,072 bytes follow; see §3.)
- **Header area:** section-table end `0x178 + 7×40 = 0x290` ≤ SizeOfHeaders `0x400`. Pass.
- **Size fields:**
  - SizeOfCode 89,088 = `.text` raw `0x15C00`. Pass.
  - SizeOfInitializedData 23,552 = raw sizes of `.rdata` + `.data` + `.idata` + `.edata` + `.reloc` (1,024 + 10,240 + 2,048 + 3,584 + 6,656). Pass.
  - SizeOfUninitializedData 8,704 = `.bss` VirtualSize `0x2124` rounded up to `0x200`. Pass (an observed relationship).
- **Directories:** Export and Import sizes equal `.edata`'s and `.idata`'s virtual sizes; Base relocation and Debug lie within their sections. Pass.
- **Export tables, back to back:**
  - address table `0x1F028 + 4×104 = 0x1F1C8` = AddressOfNames;
  - name pointer table `0x1F1C8 + 4×104 = 0x1F368` = AddressOfNameOrdinals;
  - ordinal table ends at `0x1F368 + 2×104 = 0x1F438`, inside the export directory, which ends at `0x1FCCE`.
  
  Pass.
- **Counts:** imports 42 + 5 + 18 = 65; exports 104 entries and 104 names, with ordinals 1–104 consecutive. Pass.

**No discrepancies were found.**

## 6. Static imports (Verified; 3 DLLs, 65 functions, all by name)

| DLL | Count | OriginalFirstThunk | FirstThunk |
| --- | ---: | --- | --- |
| `KERNEL32.dll` | 42 | `0x1E050` | `0x1E160` |
| `USER32.dll` | 5 | `0x1E0FC` | `0x1E20C` |
| `WINMM.dll` | 18 | `0x1E114` | `0x1E224` |

All descriptors have TimeDateStamp 0 and ForwarderChain 0, and were read via OriginalFirstThunk.

Original lookup-table order, manually transcribed from the parser's on-screen output (see the transcription note at the top):

- **`KERNEL32.dll` (42):** WideCharToMultiByte, InitializeCriticalSection, DeleteCriticalSection, LeaveCriticalSection, EnterCriticalSection, lstrcpyA, lstrcmpiA, lstrlenA, GlobalLock, GlobalAlloc, GlobalFree, GlobalHandle, CloseHandle, GetFileSize, CreateFileA, ReadFile, WriteFile, GetEnvironmentStrings, GetCommandLineA, GetVersion, GetLocalTime, ExitProcess, VirtualFree, VirtualAlloc, GetModuleFileNameA, GetACP, GetOEMCP, GetCPInfo, GetStdHandle, GetFileType, GetStartupInfoA, GetTimeZoneInformation, GetLastError, MultiByteToWideChar, GetProfileStringA, GetProcAddress, GetModuleHandleA, SetFilePointer, SetStdHandle, FlushFileBuffers, SetEndOfFile, SetEnvironmentVariableA
- **`USER32.dll` (5):** SetTimer, MessageBeep, KillTimer, wsprintfA, wvsprintfA
- **`WINMM.dll` (18):** timeEndPeriod, timeKillEvent, timeSetEvent, timeBeginPeriod, waveOutReset, waveOutWrite, waveOutClose, waveOutUnprepareHeader, waveOutPrepareHeader, timeGetTime, waveOutOpen, midiOutShortMsg, midiOutLongMsg, midiOutClose, midiOutReset, midiOutUnprepareHeader, midiOutPrepareHeader, midiOutOpen

**Absent from the static imports (Verified, static imports only):** `LoadLibraryA` (`GetProcAddress` and `GetModuleHandleA` *are* imported), any DirectX DLL, `DSOUND.dll`, and ADVAPI32 (registry).

## 7. Exports (Verified)

| Field | Value |
| --- | --- |
| Export directory | RVA `0x1F000`, size `0xCCE`, in section `.edata` |
| DLL name (export directory) | `WAIL32.dll` (a recorded field value; not product identification) |
| Characteristics | `0x0` |
| TimeDateStamp | `0x30009DFC` = 805,346,812. Decodes to 1995-07-10 03:26:52 UTC, 3 seconds before the COFF field. Field value only. |
| Version | 0.0 |
| OrdinalBase | 1 |
| NumberOfFunctions / NumberOfNames | 104 / 104 |
| AddressOfFunctions / AddressOfNames / AddressOfNameOrdinals | `0x1F028` / `0x1F1C8` / `0x1F368` |

**Summary:**
- 104 address-table entries: 104 targets, 0 forwarders, 0 unused.
- 104 names, exactly one per entry: no aliases and no duplicates.
- No `NOTE:` lines were printed.
- Every target classifies as `section .text [CODE X R] (stored bytes)`. That is section-flag classification only; it is not proof that an entry is code rather than data. Export-target contents were not examined or decoded, and nothing was followed. (The parser does read the whole file into memory, to verify its fingerprint.)

**Address-table order**, manually transcribed from the parser's on-screen output (see the transcription note at the top). Each line gives the ordinal, the export RVA, its classification and its name; no entry has an alias.
- The parser lists entries in **address-table order**, and keeps name-table order only **within** each entry's alias list.
- It does not print each name's overall position in the name pointer table.
- With one name per entry, this listing therefore does **not** establish the original overall name-table order.

```text
ordinal 1: RVA 0x000069A9 -> section .text [CODE X R] (stored bytes); names: AIL_XMIDI_master_volume
ordinal 2: RVA 0x000055F2 -> section .text [CODE X R] (stored bytes); names: AIL_active_sample_count
ordinal 3: RVA 0x00006B31 -> section .text [CODE X R] (stored bytes); names: AIL_active_sequence_count
ordinal 4: RVA 0x00003142 -> section .text [CODE X R] (stored bytes); names: AIL_allocate_file_sample
ordinal 5: RVA 0x00002FBA -> section .text [CODE X R] (stored bytes); names: AIL_allocate_sample_handle
ordinal 6: RVA 0x000059D3 -> section .text [CODE X R] (stored bytes); names: AIL_allocate_sequence_handle
ordinal 7: RVA 0x000023B8 -> section .text [CODE X R] (stored bytes); names: AIL_background
ordinal 8: RVA 0x00007178 -> section .text [CODE X R] (stored bytes); names: AIL_branch_index
ordinal 9: RVA 0x00006E51 -> section .text [CODE X R] (stored bytes); names: AIL_channel_notes
ordinal 10: RVA 0x00006CB9 -> section .text [CODE X R] (stored bytes); names: AIL_controller_value
ordinal 11: RVA 0x000084DA -> section .text [CODE X R] (stored bytes); names: AIL_create_wave_synthesizer
ordinal 12: RVA 0x00002302 -> section .text [CODE X R] (stored bytes); names: AIL_delay
ordinal 13: RVA 0x0000867A -> section .text [CODE X R] (stored bytes); names: AIL_destroy_wave_synthesizer
ordinal 14: RVA 0x000045A0 -> section .text [CODE X R] (stored bytes); names: AIL_digital_master_volume
ordinal 15: RVA 0x0000398C -> section .text [CODE X R] (stored bytes); names: AIL_end_sample
ordinal 16: RVA 0x00005FCB -> section .text [CODE X R] (stored bytes); names: AIL_end_sequence
ordinal 17: RVA 0x00001F21 -> section .text [CODE X R] (stored bytes); names: AIL_get_preference
ordinal 18: RVA 0x00003390 -> section .text [CODE X R] (stored bytes); names: AIL_init_sample
ordinal 19: RVA 0x00005C11 -> section .text [CODE X R] (stored bytes); names: AIL_init_sequence
ordinal 20: RVA 0x000020A9 -> section .text [CODE X R] (stored bytes); names: AIL_last_error
ordinal 21: RVA 0x00004A48 -> section .text [CODE X R] (stored bytes); names: AIL_load_sample_buffer
ordinal 22: RVA 0x000022B6 -> section .text [CODE X R] (stored bytes); names: AIL_lock
ordinal 23: RVA 0x00007EAA -> section .text [CODE X R] (stored bytes); names: AIL_lock_channel
ordinal 24: RVA 0x000080F0 -> section .text [CODE X R] (stored bytes); names: AIL_map_sequence_channel
ordinal 25: RVA 0x0000591D -> section .text [CODE X R] (stored bytes); names: AIL_midiOutClose
ordinal 26: RVA 0x0000577A -> section .text [CODE X R] (stored bytes); names: AIL_midiOutOpen
ordinal 27: RVA 0x00004728 -> section .text [CODE X R] (stored bytes); names: AIL_minimum_sample_buffer_size
ordinal 28: RVA 0x00004EEC -> section .text [CODE X R] (stored bytes); names: AIL_register_EOB_callback
ordinal 29: RVA 0x0000520C -> section .text [CODE X R] (stored bytes); names: AIL_register_EOF_callback
ordinal 30: RVA 0x0000507C -> section .text [CODE X R] (stored bytes); names: AIL_register_EOS_callback
ordinal 31: RVA 0x00007DEC -> section .text [CODE X R] (stored bytes); names: AIL_register_ICA_array
ordinal 32: RVA 0x00004D5C -> section .text [CODE X R] (stored bytes); names: AIL_register_SOB_callback
ordinal 33: RVA 0x000076E6 -> section .text [CODE X R] (stored bytes); names: AIL_register_beat_callback
ordinal 34: RVA 0x00007876 -> section .text [CODE X R] (stored bytes); names: AIL_register_event_callback
ordinal 35: RVA 0x00007236 -> section .text [CODE X R] (stored bytes); names: AIL_register_prefix_callback
ordinal 36: RVA 0x00007556 -> section .text [CODE X R] (stored bytes); names: AIL_register_sequence_callback
ordinal 37: RVA 0x00007A06 -> section .text [CODE X R] (stored bytes); names: AIL_register_timbre_callback
ordinal 38: RVA 0x000023EC -> section .text [CODE X R] (stored bytes); names: AIL_register_timer
ordinal 39: RVA 0x000073C6 -> section .text [CODE X R] (stored bytes); names: AIL_register_trigger_callback
ordinal 40: RVA 0x00002CB8 -> section .text [CODE X R] (stored bytes); names: AIL_release_all_timers
ordinal 41: RVA 0x00008032 -> section .text [CODE X R] (stored bytes); names: AIL_release_channel
ordinal 42: RVA 0x000032DA -> section .text [CODE X R] (stored bytes); names: AIL_release_sample_handle
ordinal 43: RVA 0x00005B5B -> section .text [CODE X R] (stored bytes); names: AIL_release_sequence_handle
ordinal 44: RVA 0x00002C02 -> section .text [CODE X R] (stored bytes); names: AIL_release_timer_handle
ordinal 45: RVA 0x000038D6 -> section .text [CODE X R] (stored bytes); names: AIL_resume_sample
ordinal 46: RVA 0x00005F15 -> section .text [CODE X R] (stored bytes); names: AIL_resume_sequence
ordinal 47: RVA 0x000048C0 -> section .text [CODE X R] (stored bytes); names: AIL_sample_buffer_ready
ordinal 48: RVA 0x0000435A -> section .text [CODE X R] (stored bytes); names: AIL_sample_loop_count
ordinal 49: RVA 0x000041D2 -> section .text [CODE X R] (stored bytes); names: AIL_sample_pan
ordinal 50: RVA 0x00003EC2 -> section .text [CODE X R] (stored bytes); names: AIL_sample_playback_rate
ordinal 51: RVA 0x00004BD4 -> section .text [CODE X R] (stored bytes); names: AIL_sample_position
ordinal 52: RVA 0x00003D3A -> section .text [CODE X R] (stored bytes); names: AIL_sample_status
ordinal 53: RVA 0x00005462 -> section .text [CODE X R] (stored bytes); names: AIL_sample_user_data
ordinal 54: RVA 0x0000404A -> section .text [CODE X R] (stored bytes); names: AIL_sample_volume
ordinal 55: RVA 0x00008346 -> section .text [CODE X R] (stored bytes); names: AIL_send_channel_voice_message
ordinal 56: RVA 0x0000841C -> section .text [CODE X R] (stored bytes); names: AIL_send_sysex_message
ordinal 57: RVA 0x00006763 -> section .text [CODE X R] (stored bytes); names: AIL_sequence_loop_count
ordinal 58: RVA 0x00006FE1 -> section .text [CODE X R] (stored bytes); names: AIL_sequence_position
ordinal 59: RVA 0x000062CB -> section .text [CODE X R] (stored bytes); names: AIL_sequence_status
ordinal 60: RVA 0x00006453 -> section .text [CODE X R] (stored bytes); names: AIL_sequence_tempo
ordinal 61: RVA 0x00007C5C -> section .text [CODE X R] (stored bytes); names: AIL_sequence_user_data
ordinal 62: RVA 0x000065DB -> section .text [CODE X R] (stored bytes); names: AIL_sequence_volume
ordinal 63: RVA 0x00009E61 -> section .text [CODE X R] (stored bytes); names: AIL_serve
ordinal 64: RVA 0x000068EB -> section .text [CODE X R] (stored bytes); names: AIL_set_XMIDI_master_volume
ordinal 65: RVA 0x000044E2 -> section .text [CODE X R] (stored bytes); names: AIL_set_digital_master_volume
ordinal 66: RVA 0x00002210 -> section .text [CODE X R] (stored bytes); names: AIL_set_error
ordinal 67: RVA 0x00001D91 -> section .text [CODE X R] (stored bytes); names: AIL_set_preference
ordinal 68: RVA 0x000035DE -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_address
ordinal 69: RVA 0x00003446 -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_file
ordinal 70: RVA 0x00003C7C -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_loop_count
ordinal 71: RVA 0x00003BBE -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_pan
ordinal 72: RVA 0x00003A42 -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_playback_rate
ordinal 73: RVA 0x00004B16 -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_position
ordinal 74: RVA 0x000036A4 -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_type
ordinal 75: RVA 0x0000539C -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_user_data
ordinal 76: RVA 0x00003B00 -> section .text [CODE X R] (stored bytes); names: AIL_set_sample_volume
ordinal 77: RVA 0x0000620D -> section .text [CODE X R] (stored bytes); names: AIL_set_sequence_loop_count
ordinal 78: RVA 0x00006081 -> section .text [CODE X R] (stored bytes); names: AIL_set_sequence_tempo
ordinal 79: RVA 0x00007B96 -> section .text [CODE X R] (stored bytes); names: AIL_set_sequence_user_data
ordinal 80: RVA 0x00006147 -> section .text [CODE X R] (stored bytes); names: AIL_set_sequence_volume
ordinal 81: RVA 0x00002880 -> section .text [CODE X R] (stored bytes); names: AIL_set_timer_divisor
ordinal 82: RVA 0x000027C2 -> section .text [CODE X R] (stored bytes); names: AIL_set_timer_frequency
ordinal 83: RVA 0x00002704 -> section .text [CODE X R] (stored bytes); names: AIL_set_timer_period
ordinal 84: RVA 0x00002574 -> section .text [CODE X R] (stored bytes); names: AIL_set_timer_user
ordinal 85: RVA 0x00001C77 -> section .text [CODE X R] (stored bytes); names: AIL_shutdown
ordinal 86: RVA 0x000029F4 -> section .text [CODE X R] (stored bytes); names: AIL_start_all_timers
ordinal 87: RVA 0x0000376A -> section .text [CODE X R] (stored bytes); names: AIL_start_sample
ordinal 88: RVA 0x00005DA9 -> section .text [CODE X R] (stored bytes); names: AIL_start_sequence
ordinal 89: RVA 0x0000293E -> section .text [CODE X R] (stored bytes); names: AIL_start_timer
ordinal 90: RVA 0x00001A92 -> section .text [CODE X R] (stored bytes); names: AIL_startup
ordinal 91: RVA 0x00002B56 -> section .text [CODE X R] (stored bytes); names: AIL_stop_all_timers
ordinal 92: RVA 0x00003820 -> section .text [CODE X R] (stored bytes); names: AIL_stop_sample
ordinal 93: RVA 0x00005E5F -> section .text [CODE X R] (stored bytes); names: AIL_stop_sequence
ordinal 94: RVA 0x00002AA0 -> section .text [CODE X R] (stored bytes); names: AIL_stop_timer
ordinal 95: RVA 0x000081B6 -> section .text [CODE X R] (stored bytes); names: AIL_true_sequence_channel
ordinal 96: RVA 0x000022DC -> section .text [CODE X R] (stored bytes); names: AIL_unlock
ordinal 97: RVA 0x00002F04 -> section .text [CODE X R] (stored bytes); names: AIL_waveOutClose
ordinal 98: RVA 0x00002D64 -> section .text [CODE X R] (stored bytes); names: AIL_waveOutOpen
ordinal 99: RVA 0x00008992 -> section .text [CODE X R] (stored bytes); names: FILE_error
ordinal 100: RVA 0x00008A1F -> section .text [CODE X R] (stored bytes); names: FILE_read
ordinal 101: RVA 0x000089A7 -> section .text [CODE X R] (stored bytes); names: FILE_size
ordinal 102: RVA 0x00008B31 -> section .text [CODE X R] (stored bytes); names: FILE_write
ordinal 103: RVA 0x00008927 -> section .text [CODE X R] (stored bytes); names: MEM_alloc_lock
ordinal 104: RVA 0x0000895B -> section .text [CODE X R] (stored bytes); names: MEM_free_lock
```

## 8. Comparison with the earlier executables (from the recorded lists)

**Use of `WAIL32.DLL`:** none of `PITFALL.EXE` (R2.1 §6), `PITSTART.EXE` or `KILLPIT.EXE` (R2.2 §2.6, §3.6) has `WAIL32.dll` in its static imports. **Verified for static imports only.** `PITFALL.EXE` does import `LoadLibraryA` and `GetProcAddress` (R2.1), so loading at run time is *possible*, but whether it happens is **Not tested**. This report is **not** evidence that `PITFALL.EXE` uses this DLL.

**`WAIL32.DLL`'s imports compared with `PITFALL.EXE`'s:**

| DLL | `WAIL32` imports | Also imported by `PITFALL.EXE` | Not imported by `PITFALL.EXE` |
| --- | ---: | ---: | --- |
| KERNEL32 | 42 | 32 | GetFileSize, GetLocalTime, GetProfileStringA, GetTimeZoneInformation, GlobalHandle, lstrcmpiA, lstrcpyA, lstrlenA, SetEndOfFile, SetEnvironmentVariableA |
| USER32 | 5 | 3 | wsprintfA, wvsprintfA |
| WINMM | 18 | 5 | midiOutClose, midiOutLongMsg, midiOutOpen, midiOutPrepareHeader, midiOutReset, midiOutShortMsg, midiOutUnprepareHeader, waveOutClose, waveOutOpen, waveOutPrepareHeader, waveOutReset, waveOutUnprepareHeader, waveOutWrite |

**Shared imports with the other two files** (computed the same way):
- **`PITSTART.EXE`:** 16 of the 42 KERNEL32 imports; none of the USER32 or WINMM imports.
- **`KILLPIT.EXE`:** 15 of the 42 KERNEL32 imports; none of the USER32 or WINMM imports.

## 9. Interpretation

| # | Statement | Label |
| --- | --- | --- |
| K1 | A 32-bit x86 DLL with the same linker version field (2.55) and subsystem version (4.0) as the three executables. Unlike them, it has a non-zero CheckSum, a different ImageBase, and the local-symbols-stripped flag clear. | Fields: **Verified**. Shared toolchain: **Assumption** |
| K2 | WINMM's `waveOut*` (wave audio output) and `midiOut*` (MIDI output) imports, together with multimedia timers, are consistent with a sound library that drives wave and MIDI output itself. | Imports: **Verified**. Role: **Assumption** |
| K3 | The `AIL_` export prefix and names such as `AIL_start_sample`, `AIL_start_sequence` and `AIL_set_XMIDI_master_volume` are consistent with an audio API (samples, MIDI-style "sequences", timers). Whether this is the Miles Sound System, as the file name suggests, remains a hypothesis. *[corrected after Work's review of `5866633`: an uncited naming claim was removed]* | Names: **Verified**. API semantics and product identity: **Assumption** (names do not establish behavior or product) |
| K4 | The `FILE_` and `MEM_` exports look like helper routines (file I/O and locked memory). | **Assumption** |
| K5 | `.data` and `.bss` carry `IMAGE_SCN_MEM_SHARED`, indicating that these sections can be shared in memory. Actual run-time behavior was not tested. | Flags: **Verified**. Run-time behavior: **Not tested** |
| K6 | The library imports `GetProcAddress` but not `LoadLibraryA`. | **Verified** (static imports only); what it looks up is **Not tested** |
| K7 | 3,072 bytes follow the last section, and a Debug directory is declared. Their contents and any relationship between them are unknown. | Sizes: **Verified**. Contents: **Not tested** |

### Discrepancy D-EXE-3: timestamp fields (not interpreted)

**Verified field values:**
- The COFF TimeDateStamp decodes to **1995-07-10 03:26:55 UTC**; the export directory's to 03:26:52, 3 seconds earlier.
- Against the disc's ISO directory date (1995-08-24 00:01:00): **44 d 20:34:05 before**.
- That is earlier than `KILLPIT.EXE`'s field (1995-07-26 10:17:30) by 16 d 06:50:35.

The reasons, and whether any of these dates are accurate, are **Not tested**.

### Questions for later (hypotheses only)

| # | Question | Basis |
| --- | --- | --- |
| Q14 | Does `PITFALL.EXE` load `WAIL32.DLL` at run time (e.g. via `LoadLibraryA`)? If so, which exports does it look up? | §8, K6 |
| Q15 | If the game uses this library for sound effects (`INIT.PH` WAV data is reported in S001), does wave and MIDI output through WINMM work on Windows 10/11? | K2; S001 (**Reported**) |
| Q16 | What do the 3,072 bytes after the last section and the Debug directory contain? This would need a separately scoped, read-only metadata step. | K7 |

## 10. Evidence limits

- **New parser observations (Claude-reported):** everything in §2–§7. This is the export-enabled parser's first game-file run.
- **Earlier reports reused:** the import lists of `PITFALL.EXE` (R2.1) and of `PITSTART.EXE`/`KILLPIT.EXE` (R2.2); the ISO directory date (`disc-contents.md`).
- **Recomputable derivations:** §4, §5, the §8 comparisons and the D-EXE-3 durations.
- **Manual transcription:**
  - §6–§7's lists and §2–§4's values were transcribed manually from the parser's on-screen output, and no separate run transcript was retained.
  - Claude checked the lists only for internal consistency: 104 consecutive ordinals, 104 unique names, and import counts matching their headers. That does **not** establish that the transcription is accurate.
  - Confirming accuracy would need a separately authorized re-run with saved output.
- **Not independent:** no independent party has reproduced the parser observations.
- **Policy:** the parser bounds address mapping by VirtualSize, and classifies export targets by section flags. Both are tool policy, not claims about Windows loader behavior.

## 11. Not tested / out of scope

- Disassembly or decompilation, including the entry point and any export target.
- Examination or decoding of export-target contents; forwarder resolution (there are no forwarders).
- General string scanning (only import and export names were parsed); the contents of the Debug directory or of the 3,072 bytes after the last section; resources (none declared).
- Loading, executing or debugging the DLL; whether any game program loads it; which exports are actually called.
- Behavior on Windows 10/11 of the imported WINMM functions.
- Product or version identification; comparison with other copies of `WAIL32.DLL` (no reference hashes are available).
- Validation of the PE CheckSum.
- Re-reading `PITFALL.EXE`, `PITSTART.EXE` or `KILLPIT.EXE` with the export-enabled parser.

## 12. Reproduction

With the MEDIA-001 image, from the repository root at `af720d7` (parser blob `3c334673…`):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\inspect-pe.ps1 -Image "<MEDIA-001 image>" -Extent 6784 -Size 116736 -ExpectedSha256 432D51744010E25EC82E550B4BC6422134625451F6A33FE72228528AA28C241A
```

**Expected result:**
- `SHA-256 check: matches expected value`;
- the values in §2–§7;
- `Total imported functions: 65 from 3 DLL(s)`;
- `Total exports: 104 address-table entries (targets 104, forwarders 0, unused 0); names 104`;
- `RESULT: OK`, exit code 0.

**No follow-up is authorized by this report.** Possible next steps (Q14–Q16, re-reading the earlier executables, resource enumeration) each need their own approval.
