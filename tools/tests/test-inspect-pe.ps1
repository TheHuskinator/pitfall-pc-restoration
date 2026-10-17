<#
.SYNOPSIS
    Synthetic tests for tools/inspect-pe.ps1.

.DESCRIPTION
    Review and run history: see tools/README.md.

    Builds small, harmless PE32 byte arrays from scratch in memory. They contain
    no game data, no copies of system files, and no code that is ever run.
    Each test writes its file to a new temporary folder, runs the inspector in a
    separate powershell.exe process, and checks the exit code and key output lines.
    The temporary folder is deleted afterwards. The exit code is 0 only if every
    test passes.

    Base fixture (0x600 bytes):
      headers  0x000-0x1FF  MZ, e_lfanew = 0x40, PE32, 2 sections, 16 data directories
      .text    VA 0x1000, raw 0x200-0x3FF (zeros; entry point RVA 0x1000)
      .idata   VA 0x2000, raw 0x400-0x5FF
               0x400 descriptor 1 (OriginalFirstThunk 0x2040, Name 0x2030, FirstThunk 0x2060)
               0x414 all-zero terminator
               0x430 "TEST.DLL"
               0x440 lookup table: 0x2080 (Zeta), ordinal 7, 0x2090 (Alpha), 0
               0x460 import address table (same values)
               0x480 hint 1 "Zeta" / 0x490 hint 2 "Alpha"

    Coverage of ChatGPT Work's first review (2026-10-15):
      #1 unmapped RVA must not become a name          -> T09, T23
      #2 header/section bounds                        -> T04, T07, T08, T15, T22
      #3 import tables: termination, all-zero entry   -> T10, T11, T12
      #4 unterminated or invalid names                -> T13, T24
      #5 distinct exit codes for each outcome         -> every test checks its code
    Coverage of ChatGPT Work's second review (commit 6a583bc):
      R2-1 declared import-directory size enforced    -> T10, T25, T26
      R2-2 overlapping sections rejected              -> T27
      R2-3 SizeOfHeaders must cover the section table -> T28
      R2-4 multi-sector image mode, partial last sector -> T29 (and T18)
    Also: header-based RVA (T17), original order kept (T01, T17), image mode (T18, T19)

    Export fixture (New-ExportPe, 0x800 bytes): the base fixture, plus
      COFF NumberOfSections 4, Characteristics 0x2102 (DLL); SizeOfImage 0x5000
      export directory: data directory 0 = RVA 0x3000, size 0x160
      .edata   VA 0x3000, raw 0x600-0x7FF          .bss  VA 0x4000, VSize 0x100, no raw data
               0x600 export directory table: name 0x3100, OrdinalBase 1, 5 functions, 4 names,
                     AddressOfFunctions 0x3028, AddressOfNames 0x303C, AddressOfNameOrdinals 0x304C
               0x628 address table: 0x1000 (.text), 0x1010 (.text), 0 (unused),
                     0x3110 (forwarder "OTHER.Func"), 0x4000 (.bss data, no stored bytes)
               0x63C name pointers -> "Alpha", "AlphaAlias", "DataItem", "Fwd"
               0x64C ordinal indexes 0, 0, 4, 3   (Alpha and AlphaAlias are aliases)
               0x700 "TESTEXP.DLL"  0x710 "OTHER.Func"  0x720.. names

    Coverage of the export enhancement (Work's corrections to the proposal, 2026-10-16):
      no export directory still reported; header/import output unchanged -> T30
      aliases, including more names than functions                    -> T31, T32
      export address need not have stored bytes (exported data)       -> T31
      forwarders DLL.Name and DLL.#ordinal; syntax; ordinal range     -> T31, T35, T38, T39, T40
      forwarder terminator as the last byte inside the directory (pass) and
        as the first byte outside (fail)                              -> T36, T37
      non-default ordinal base; ordinal above 65535                   -> T33, T34
      zero (unused) address-table entries                             -> T31, T59
      metadata bounds: name index, names, DLL name, tables, directory -> T41-T50
      counts and arithmetic near the 32-bit limit                     -> T51-T54
      target classification: beyond SizeOfImage (fail), unmapped,
        header area                                                   -> T55, T56, T57
      duplicate names (note)                                          -> T58
    Coverage of Work's source review of the export draft (commit 4c1d42c):
      export directory entry: absent (no entry / both zero) vs exactly one zero -> T60-T63
      zero RVA for a mandatory reference is MALFORMED, not header text:
        DLL name, address table, name pointer table, ordinal table, a name entry -> T64-T68
      zero-count tables with zero RVAs remain valid                   -> T69, T70
      unterminated DLL name; truncated name pointer and ordinal tables -> T71-T73

    Synthetic disc images are pre-filled with 0xEE marker bytes. A read from the
    wrong sector position would therefore pull in marker bytes and fail the SHA-256 check.
#>
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$inspector = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\inspect-pe.ps1')).ProviderPath
$psExe = Join-Path $PSHOME 'powershell.exe'
$work = Join-Path ([IO.Path]::GetTempPath()) ('inspect-pe-tests-' + [guid]::NewGuid().ToString('N'))

# ---------------------------------------------------------------- byte helpers
# Values are masked to 32 bits so hex literals that PowerShell reads as negative
# (e.g. 0x80000007) are written correctly.
function W16([byte[]]$B, [int]$Off, [long]$V) { [BitConverter]::GetBytes([uint16]($V -band 0xFFFF)).CopyTo($B, $Off) }
function W32([byte[]]$B, [int]$Off, [long]$V) { [BitConverter]::GetBytes([uint32]($V -band 0xFFFFFFFFL)).CopyTo($B, $Off) }
function WStr([byte[]]$B, [int]$Off, [string]$S) { [Text.Encoding]::ASCII.GetBytes($S).CopyTo($B, $Off) }

function New-ValidPe {
    $b = New-Object byte[] 0x600
    WStr $b 0 'MZ'; W32 $b 0x3C 0x40
    WStr $b 0x40 "PE`0`0"
    $c = 0x44                                   # COFF header
    W16 $b $c 0x14C; W16 $b ($c + 2) 2; W32 $b ($c + 4) 0x12345678
    W16 $b ($c + 16) 0xE0; W16 $b ($c + 18) 0x0102
    $o = 0x58                                   # optional header (PE32, 224 bytes)
    W16 $b $o 0x10B; $b[$o + 2] = 1
    W32 $b ($o + 4) 0x200; W32 $b ($o + 8) 0x200
    W32 $b ($o + 16) 0x1000; W32 $b ($o + 20) 0x1000; W32 $b ($o + 24) 0x2000; W32 $b ($o + 28) 0x400000
    W32 $b ($o + 32) 0x1000; W32 $b ($o + 36) 0x200; W16 $b ($o + 48) 4
    W32 $b ($o + 56) 0x3000; W32 $b ($o + 60) 0x200; W16 $b ($o + 68) 2
    W32 $b ($o + 92) 16
    W32 $b 0xC0 0x2000; W32 $b 0xC4 0x28          # import directory (data directory 1)
    $s = 0x138                                  # section table
    WStr $b $s '.text';  W32 $b ($s + 8) 0x200; W32 $b ($s + 12) 0x1000; W32 $b ($s + 16) 0x200; W32 $b ($s + 20) 0x200; W32 $b ($s + 36) 0x60000020
    $s = 0x160
    WStr $b $s '.idata'; W32 $b ($s + 8) 0x200; W32 $b ($s + 12) 0x2000; W32 $b ($s + 16) 0x200; W32 $b ($s + 20) 0x400; W32 $b ($s + 36) 0xC0000040
    W32 $b 0x400 0x2040; W32 $b 0x40C 0x2030; W32 $b 0x410 0x2060   # descriptor 1; 0x414-0x427 terminator
    WStr $b 0x430 'TEST.DLL'
    W32 $b 0x440 0x2080; W32 $b 0x444 0x80000007; W32 $b 0x448 0x2090   # lookup table, 0x44C = 0
    W32 $b 0x460 0x2080; W32 $b 0x464 0x80000007; W32 $b 0x468 0x2090   # import address table
    W16 $b 0x480 1; WStr $b 0x482 'Zeta'
    W16 $b 0x490 2; WStr $b 0x492 'Alpha'
    , $b
}

# A small DLL-shaped fixture with an export table (layout in the header comment).
function New-ExportPe {
    $base = New-ValidPe
    $b = New-Object byte[] 0x800
    [Array]::Copy($base, $b, $base.Length)
    W16 $b 0x46 4                                 # NumberOfSections
    W16 $b 0x56 0x2102                            # Characteristics: executable image, 32-bit, DLL
    W32 $b (0x58 + 56) 0x5000                     # SizeOfImage
    W32 $b 0xB8 0x3000; W32 $b 0xBC 0x160         # export directory (data directory 0)
    $s = 0x188
    WStr $b $s '.edata'; W32 $b ($s + 8) 0x200; W32 $b ($s + 12) 0x3000; W32 $b ($s + 16) 0x200; W32 $b ($s + 20) 0x600; W32 $b ($s + 36) 0x40000040
    $s = 0x1B0
    WStr $b $s '.bss';   W32 $b ($s + 8) 0x100; W32 $b ($s + 12) 0x4000; W32 $b ($s + 16) 0;     W32 $b ($s + 20) 0;     W32 $b ($s + 36) 0xC0000080
    W32 $b 0x604 0x12345678; W16 $b 0x608 1; W32 $b 0x60C 0x3100; W32 $b 0x610 1        # timestamp, version 1.0, name, OrdinalBase
    W32 $b 0x614 5; W32 $b 0x618 4; W32 $b 0x61C 0x3028; W32 $b 0x620 0x303C; W32 $b 0x624 0x304C
    W32 $b 0x628 0x1000; W32 $b 0x62C 0x1010; W32 $b 0x630 0; W32 $b 0x634 0x3110; W32 $b 0x638 0x4000
    W32 $b 0x63C 0x3120; W32 $b 0x640 0x3130; W32 $b 0x644 0x3140; W32 $b 0x648 0x3150
    W16 $b 0x64C 0; W16 $b 0x64E 0; W16 $b 0x650 4; W16 $b 0x652 3
    WStr $b 0x700 'TESTEXP.DLL'; WStr $b 0x710 'OTHER.Func'
    WStr $b 0x720 'Alpha'; WStr $b 0x730 'AlphaAlias'; WStr $b 0x740 'DataItem'; WStr $b 0x750 'Fwd'
    , $b
}

# Wrap bytes in synthetic raw 2,352-byte sectors (user data at +16) after $Lead filler sectors.
function New-RawImage([byte[]]$Data, [int]$Lead) {
    $blocks = [int][math]::Ceiling($Data.Length / 2048)
    $img = New-Object byte[] (($Lead + $blocks) * 2352)
    for ($k = 0; $k -lt $img.Length; $k++) { $img[$k] = 0xEE }   # marker: any misplaced read changes the hash
    for ($k = 0; $k -lt $blocks; $k++) {
        $n = [math]::Min(2048, $Data.Length - $k * 2048)
        [Array]::Copy($Data, $k * 2048, $img, ($Lead + $k) * 2352 + 16, $n)
    }
    , $img
}

function Get-Sha256Hex([byte[]]$Data) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { [BitConverter]::ToString($sha.ComputeHash($Data)).Replace('-', '') } finally { $sha.Dispose() }
}

# ---------------------------------------------------------------- test cases
$defaultArgs = { param($File, $Sha, $Bytes) @('-Path', $File, '-ExpectedSha256', $Sha) }
$exp = { New-ExportPe }
$text1 = 'ordinal 1: RVA 0x00001000 -> section .text [CODE X R] (stored bytes)'

$tests = @(
    @{ Id = 'T01'; Desc = 'valid PE32: imports in original and sorted order'; Exit = 0
       Expect = @('DLL TEST.DLL', 'original order: Zeta, #7, Alpha', 'sorted        : #7, Alpha, Zeta',
                    'Total imported functions: 3 from 1 DLL(s)', 'section .text', 'bytes after the last section: 0', 'RESULT: OK') }
    @{ Id = 'T02'; Desc = 'hash mismatch stops before parsing'; Exit = 2
       Args = { param($File, $Sha, $Bytes) @('-Path', $File, '-ExpectedSha256', ('0' * 64)) }
       Expect = @('RESULT: HASH MISMATCH'); Reject = @('=== DOS HEADER') }
    @{ Id = 'T03'; Desc = 'not MZ'; Exit = 4; Mutate = { param($b) $b[0] = 0x58 }
       Expect = @('RESULT: UNSUPPORTED', 'Not an MZ') }
    @{ Id = 'T04'; Desc = 'e_lfanew beyond end of file'; Exit = 3; Mutate = { param($b) W32 $b 0x3C 0x10000 }
       Expect = @('RESULT: MALFORMED', 'PE signature at e_lfanew') }
    @{ Id = 'T05'; Desc = 'MZ with NE signature'; Exit = 4; Mutate = { param($b) WStr $b 0x40 'NE' }
       Expect = @('RESULT: UNSUPPORTED', '4E 45 00 00') }
    @{ Id = 'T06'; Desc = 'PE32+ magic'; Exit = 4; Mutate = { param($b) W16 $b 0x58 0x20B }
       Expect = @('RESULT: UNSUPPORTED', 'PE32+') }
    @{ Id = 'T07'; Desc = 'section table runs past end of file'; Exit = 3; Mutate = { param($b) W16 $b 0x46 40 }
       Expect = @('RESULT: MALFORMED', 'section table') }
    @{ Id = 'T08'; Desc = 'NumberOfRvaAndSizes larger than optional header allows'; Exit = 3; Mutate = { param($b) W32 $b (0x58 + 92) 20 }
       Expect = @('RESULT: MALFORMED', 'data directories') }
    @{ Id = 'T09'; Desc = 'unmappable hint/name RVA is not read as a name (Work #1)'; Exit = 3; Mutate = { param($b) W32 $b 0x440 0x9000 }
       Expect = @('RESULT: MALFORMED', 'RVA 0x9000'); Reject = @('original order') }
    @{ Id = 'T10'; Desc = 'import directory extends past its section''s stored data'; Exit = 3
       Mutate = { param($b) W32 $b 0xC0 0x21EC; W32 $b 0x5EC 0x2040; W32 $b 0x5F8 0x2030; W32 $b 0x5FC 0x2060 }
       Expect = @('RESULT: MALFORMED', 'extends beyond the stored data'); Reject = @('DLL TEST.DLL') }
    @{ Id = 'T11'; Desc = 'partially zero descriptor is not a terminator'; Exit = 3; Mutate = { param($b) W32 $b (0x414 + 16) 0x2060 }
       Expect = @('RESULT: MALFORMED', 'neither a valid entry nor an all-zero terminator') }
    @{ Id = 'T12'; Desc = 'lookup table with no zero entry before section end'; Exit = 3
       Mutate = { param($b) W32 $b 0x400 0x21F8; W32 $b 0x5F8 0x2080; W32 $b 0x5FC 0x2090 }
       Expect = @('RESULT: MALFORMED', 'lookup table is not terminated') }
    @{ Id = 'T13'; Desc = 'name with no terminating zero before section end (Work #4)'; Exit = 3
       Mutate = { param($b) W32 $b 0x440 0x21F0; W16 $b 0x5F0 5; WStr $b 0x5F2 'ABCDEFGHIJKLMN' }
       Expect = @('RESULT: MALFORMED', 'no terminating zero byte') }
    @{ Id = 'T14'; Desc = 'ordinal entry with reserved bits set'; Exit = 3; Mutate = { param($b) W32 $b 0x444 0x80010007 }
       Expect = @('RESULT: MALFORMED', 'reserved bits') }
    @{ Id = 'T15'; Desc = 'section raw data past end of file'; Exit = 3; Mutate = { param($b) W32 $b (0x160 + 16) 0x400 }
       Expect = @('RESULT: MALFORMED', 'section .idata raw data') }
    @{ Id = 'T16'; Desc = 'no import directory is valid'; Exit = 0; Mutate = { param($b) W32 $b 0xC0 0; W32 $b 0xC4 0 }
       Expect = @('(no import directory)', 'RESULT: OK') }
    @{ Id = 'T17'; Desc = 'hint/name located in the headers (header-based RVA)'; Exit = 0
       Mutate = { param($b) W16 $b 0x1C0 3; WStr $b 0x1C2 'HdrName'; W32 $b 0x448 0x1C0 }
       Expect = @('original order: Zeta, #7, HdrName', 'RESULT: OK') }
    @{ Id = 'T18'; Desc = 'image mode reads Mode 1 user data from synthetic sectors'; Exit = 0
       Args = { param($File, $Sha, $Bytes)
                $img = Join-Path $work 'T18.img'
                [IO.File]::WriteAllBytes($img, (New-RawImage $Bytes 3))
                @('-Image', $img, '-Extent', '3', '-Size', [string]$Bytes.Length, '-ExpectedSha256', $Sha) }
       Expect = @('sectors 3-3', 'Total imported functions: 3 from 1 DLL(s)', 'RESULT: OK') }
    @{ Id = 'T19'; Desc = 'image mode: extent beyond image rejected before reading'; Exit = 1
       Args = { param($File, $Sha, $Bytes)
                $img = Join-Path $work 'T19.img'
                [IO.File]::WriteAllBytes($img, (New-RawImage $Bytes 3))
                @('-Image', $img, '-Extent', '50', '-Size', [string]$Bytes.Length, '-ExpectedSha256', $Sha) }
       Expect = @('RESULT: INPUT ERROR', 'beyond the image') }
    @{ Id = 'T20'; Desc = 'unknown optional header magic'; Exit = 3; Mutate = { param($b) W16 $b 0x58 0x1234 }
       Expect = @('RESULT: MALFORMED', 'Unknown optional header magic') }
    @{ Id = 'T21'; Desc = 'empty file'; Exit = 1; Build = { , (New-Object byte[] 0) }
       Expect = @('RESULT: INPUT ERROR', 'File size 0') }
    @{ Id = 'T22'; Desc = 'file shorter than a DOS header'; Exit = 3
       Build = { $t = New-Object byte[] 0x30; $t[0] = 0x4D; $t[1] = 0x5A; , $t }
       Expect = @('RESULT: MALFORMED', 'DOS header') }
    @{ Id = 'T23'; Desc = 'unmappable DLL-name RVA (Work #1)'; Exit = 3; Mutate = { param($b) W32 $b 0x40C 0x9000 }
       Expect = @('RESULT: MALFORMED', 'DLL name'); Reject = @('DLL TEST.DLL') }
    @{ Id = 'T24'; Desc = 'non-printable byte inside a name'; Exit = 3; Mutate = { param($b) $b[0x483] = 0x01 }
       Expect = @('RESULT: MALFORMED', 'non-printable') }
    @{ Id = 'T25'; Desc = 'terminator lies outside the declared import directory size (Work R2-1)'; Exit = 3
       Mutate = { param($b) W32 $b 0xC4 0x14 }
       Expect = @('RESULT: MALFORMED', 'not terminated within the declared import directory size'); Reject = @('RESULT: OK') }
    @{ Id = 'T26'; Desc = 'import directory size smaller than one descriptor'; Exit = 3
       Mutate = { param($b) W32 $b 0xC4 0x10 }
       Expect = @('RESULT: MALFORMED', 'too small') }
    @{ Id = 'T27'; Desc = 'overlapping sections rejected (Work R2-2)'; Exit = 3
       Mutate = { param($b) W32 $b (0x138 + 8) 0x1800 }
       Expect = @('RESULT: MALFORMED', 'overlap'); Reject = @('=== STATIC IMPORTS') }
    @{ Id = 'T28'; Desc = 'SizeOfHeaders smaller than the end of the section table (Work R2-3)'; Exit = 3
       Mutate = { param($b) W32 $b (0x58 + 60) 0x100 }
       Expect = @('RESULT: MALFORMED', 'does not cover the section table') }
    @{ Id = 'T29'; Desc = 'image mode across 3 sectors with a partly used last sector (Work R2-4)'; Exit = 0
       Build = {
           # Base fixture plus a 3,464-byte patterned overlay = 5,000 bytes = 2 full blocks + 904 bytes.
           $base = New-ValidPe
           $t = New-Object byte[] 5000
           [Array]::Copy($base, $t, $base.Length)
           for ($k = $base.Length; $k -lt $t.Length; $k++) { $t[$k] = [byte](($k * 7 + 3) % 251) }
           , $t }
       Args = { param($File, $Sha, $Bytes)
                $img = Join-Path $work 'T29.img'
                [IO.File]::WriteAllBytes($img, (New-RawImage $Bytes 3))
                @('-Image', $img, '-Extent', '3', '-Size', [string]$Bytes.Length, '-ExpectedSha256', $Sha) }
       Expect = @('sectors 3-5', 'SHA-256 check: matches expected value', 'bytes after the last section: 3464',
                  'Total imported functions: 3 from 1 DLL(s)', 'RESULT: OK') }

    # ---- Exports (T30-T59) ----
    @{ Id = 'T30'; Desc = 'no export directory: reported after unchanged import output'; Exit = 0
       Expect = @('original order: Zeta, #7, Alpha', 'Total imported functions: 3 from 1 DLL(s)', '=== EXPORTS', '(no export directory)', 'RESULT: OK') }
    @{ Id = 'T31'; Desc = 'valid exports: alias, ordinal-only, unused, forwarder by name, exported data'; Exit = 0; Build = $exp
       Expect = @('flags: EXECUTABLE_IMAGE, 32BIT_MACHINE, DLL', 'Total imported functions: 3 from 1 DLL(s)',
                  'Export directory: RVA 0x3000, size 0x160, in section .edata', 'DLL name     : TESTEXP.DLL', 'Version=1.0 OrdinalBase=1',
                  'NumberOfFunctions=5 NumberOfNames=4', ($text1 + '; names: Alpha, AlphaAlias'),
                  'ordinal 2: RVA 0x00001010 -> section .text [CODE X R] (stored bytes); names: (none)',
                  'ordinal 3: unused (address 0); names: (none)', 'ordinal 4: forwarder -> OTHER.Func; names: Fwd',
                  'ordinal 5: RVA 0x00004000 -> section .bss [UDATA R W] (no stored bytes); names: DataItem',
                  'Total exports: 5 address-table entries (targets 3, forwarders 1, unused 1); names 4', 'RESULT: OK')
       Reject = @('NOTE:') }
    @{ Id = 'T32'; Desc = 'more names than functions via aliases is valid'; Exit = 0; Build = $exp
       Mutate = { param($b) W32 $b 0x614 1; W16 $b 0x650 0; W16 $b 0x652 0 }
       Expect = @(($text1 + '; names: Alpha, AlphaAlias, DataItem, Fwd'),
                  'Total exports: 1 address-table entries (targets 1, forwarders 0, unused 0); names 4', 'RESULT: OK') }
    @{ Id = 'T33'; Desc = 'non-default ordinal base'; Exit = 0; Build = $exp; Mutate = { param($b) W32 $b 0x610 100 }
       Expect = @('OrdinalBase=100', 'ordinal 100: RVA 0x00001000', 'ordinal 102: unused', 'ordinal 103: forwarder -> OTHER.Func', 'ordinal 104: RVA 0x00004000', 'RESULT: OK')
       Reject = @('NOTE:') }
    @{ Id = 'T34'; Desc = 'highest ordinal above 65535 is noted, not rejected'; Exit = 0; Build = $exp; Mutate = { param($b) W32 $b 0x610 65535 }
       Expect = @('NOTE: the highest ordinal, 65539, exceeds 65535', 'ordinal 65539: RVA 0x00004000', 'RESULT: OK') }
    @{ Id = 'T35'; Desc = 'forwarder by ordinal (DLL.#27)'; Exit = 0; Build = $exp
       Mutate = { param($b) WStr $b 0x710 'OTHER.#27'; $b[0x719] = 0 }
       Expect = @('ordinal 4: forwarder -> OTHER.#27; names: Fwd', 'RESULT: OK') }
    @{ Id = 'T36'; Desc = 'forwarder terminator is the last byte inside the export directory (pass)'; Exit = 0; Build = $exp
       Mutate = { param($b) W32 $b 0xBC 0x11B }   # directory [0x3000, 0x311B); "OTHER.Func" 0x3110-0x3119, zero at 0x311A
       Expect = @('Export directory: RVA 0x3000, size 0x11B', 'ordinal 4: forwarder -> OTHER.Func; names: Fwd', 'RESULT: OK') }
    @{ Id = 'T37'; Desc = 'forwarder terminator is the first byte outside the export directory (fail)'; Exit = 3; Build = $exp
       Mutate = { param($b) W32 $b 0xBC 0x11A }   # directory [0x3000, 0x311A); the zero at 0x311A is outside
       Expect = @('RESULT: MALFORMED', 'export ordinal 4 forwarder', 'no terminating zero byte'); Reject = @('Total exports') }
    @{ Id = 'T38'; Desc = 'forwarder without DLL.Name form'; Exit = 3; Build = $exp
       Mutate = { param($b) WStr $b 0x710 'NoDotHere'; $b[0x719] = 0 }
       Expect = @('RESULT: MALFORMED', 'is not of the form DLL.Name or DLL.#ordinal') }
    @{ Id = 'T39'; Desc = 'forwarder with a non-decimal ordinal form'; Exit = 3; Build = $exp
       Mutate = { param($b) WStr $b 0x710 'OTHER.#9x'; $b[0x719] = 0 }
       Expect = @('RESULT: MALFORMED', 'invalid ordinal form') }
    @{ Id = 'T40'; Desc = 'forwarder ordinal above 65535'; Exit = 3; Build = $exp
       Mutate = { param($b) WStr $b 0x710 'OTHER.#70000' }   # zero already at 0x71C
       Expect = @('RESULT: MALFORMED', 'invalid ordinal form') }
    @{ Id = 'T41'; Desc = 'name ordinal index not below NumberOfFunctions'; Exit = 3; Build = $exp; Mutate = { param($b) W16 $b 0x64C 7 }
       Expect = @('RESULT: MALFORMED', 'export name 1: ordinal-table index 7 is not below NumberOfFunctions 5') }
    @{ Id = 'T42'; Desc = 'names but no functions'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x614 0 }
       Expect = @('RESULT: MALFORMED', 'is not below NumberOfFunctions 0') }
    @{ Id = 'T43'; Desc = 'unmappable export name RVA'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x63C 0x9000 }
       Expect = @('RESULT: MALFORMED', 'export name 1: RVA 0x9000'); Reject = @('Total exports') }
    @{ Id = 'T44'; Desc = 'export name with no terminating zero before the section end'; Exit = 3; Build = $exp
       Mutate = { param($b) for ($k = 0x750; $k -lt 0x800; $k++) { $b[$k] = 0x58 } }
       Expect = @('RESULT: MALFORMED', 'export name 4', 'no terminating zero byte') }
    @{ Id = 'T45'; Desc = 'unmappable export DLL-name RVA'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x60C 0x9000 }
       Expect = @('RESULT: MALFORMED', 'export DLL name: RVA 0x9000'); Reject = @('DLL name     :') }
    @{ Id = 'T46'; Desc = 'export address table runs past stored data'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x614 200 }
       Expect = @('RESULT: MALFORMED', 'Export address table (200 entries') }
    @{ Id = 'T47'; Desc = 'export directory smaller than 40 bytes'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0xBC 0x20 }
       Expect = @('RESULT: MALFORMED', 'smaller than the 40-byte export directory table') }
    @{ Id = 'T48'; Desc = 'export directory outside every section (inside SizeOfImage)'; Exit = 3; Build = $exp
       Mutate = { param($b) W32 $b 0xB8 0x4800; W32 $b 0xBC 0x40 }
       Expect = @('RESULT: MALFORMED', 'export directory: RVA 0x4800 is not inside the headers or any section') }
    @{ Id = 'T49'; Desc = 'export directory in a section with no stored bytes'; Exit = 3; Build = $exp
       Mutate = { param($b) W32 $b 0xB8 0x4000; W32 $b 0xBC 0x40 }
       Expect = @('RESULT: MALFORMED', 'beyond its stored file data') }
    @{ Id = 'T50'; Desc = 'export directory runs past its section''s stored data'; Exit = 3; Build = $exp
       Mutate = { param($b) W32 $b 0xB8 0x3100; W32 $b 0xBC 0x140 }
       Expect = @('RESULT: MALFORMED', 'Export directory [RVA 0x3100, size 0x140) extends beyond the stored data') }
    @{ Id = 'T51'; Desc = 'huge NumberOfFunctions rejected by the limit'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x614 0x7FFFFFFF }
       Expect = @('RESULT: MALFORMED', 'NumberOfFunctions 2147483647 exceeds this tool''s limit') }
    @{ Id = 'T52'; Desc = 'huge NumberOfNames rejected by the limit'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x618 0xFFFFFFFF }
       Expect = @('RESULT: MALFORMED', 'NumberOfNames 4294967295 exceeds this tool''s limit') }
    @{ Id = 'T53'; Desc = 'table RVA near the 32-bit limit'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x61C 0xFFFFFFF0 }
       Expect = @('RESULT: MALFORMED', 'export address table: RVA 0xFFFFFFF0') }
    @{ Id = 'T54'; Desc = 'export directory RVA near the 32-bit limit (no wrap-around)'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0xB8 0xFFFFFFF0 }
       Expect = @('RESULT: MALFORMED', 'extends beyond SizeOfImage 0x5000') }
    @{ Id = 'T55'; Desc = 'export target at or beyond SizeOfImage'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x62C 0x6000 }
       Expect = @('RESULT: MALFORMED', 'Export ordinal 2: target RVA 0x6000 is at or beyond SizeOfImage') }
    @{ Id = 'T56'; Desc = 'export target inside SizeOfImage but outside every section'; Exit = 0; Build = $exp; Mutate = { param($b) W32 $b 0x62C 0x4800 }
       Expect = @('ordinal 2: RVA 0x00004800 -> unmapped/unclassified; loader validity not established; names: (none)', 'RESULT: OK') }
    @{ Id = 'T57'; Desc = 'export target in the header area'; Exit = 0; Build = $exp; Mutate = { param($b) W32 $b 0x62C 0x100 }
       Expect = @('ordinal 2: RVA 0x00000100 -> header area; names: (none)', 'RESULT: OK') }
    @{ Id = 'T58'; Desc = 'duplicate export names are noted'; Exit = 0; Build = $exp; Mutate = { param($b) W32 $b 0x640 0x3120 }
       Expect = @('NOTE: duplicate export name Alpha (name entries 1 and 2)', ($text1 + '; names: Alpha, Alpha'), 'RESULT: OK') }
    @{ Id = 'T59'; Desc = 'a name that refers to an unused address-table entry is noted'; Exit = 0; Build = $exp; Mutate = { param($b) W16 $b 0x650 2 }
       Expect = @('ordinal 3: unused (address 0); names: DataItem', 'NOTE: export name(s) DataItem refer to the unused address-table entry for ordinal 3',
                  'ordinal 5: RVA 0x00004000 -> section .bss [UDATA R W] (no stored bytes); names: (none)', 'RESULT: OK') }

    # ---- Export corrections from Work's review of 4c1d42c (T60-T73) ----
    @{ Id = 'T60'; Desc = 'export directory RVA 0 with non-zero size is inconsistent'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0xB8 0 }
       Expect = @('RESULT: MALFORMED', 'Export directory entry is inconsistent: RVA 0x0, size 0x160'); Reject = @('(no export directory)') }
    @{ Id = 'T61'; Desc = 'export directory non-zero RVA with size 0 is inconsistent'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0xBC 0 }
       Expect = @('RESULT: MALFORMED', 'Export directory entry is inconsistent: RVA 0x3000, size 0x0') }
    @{ Id = 'T62'; Desc = 'export directory RVA and size both 0 is absent'; Exit = 0; Build = $exp; Mutate = { param($b) W32 $b 0xB8 0; W32 $b 0xBC 0 }
       Expect = @('(no export directory)', 'RESULT: OK'); Reject = @('Export directory:') }
    @{ Id = 'T63'; Desc = 'no data-directory entries at all: imports and exports absent'; Exit = 0; Build = $exp; Mutate = { param($b) W32 $b (0x58 + 92) 0 }
       Expect = @('NumberOfRvaAndSizes=0', '(no import directory)', '(no export directory)', 'RESULT: OK') }
    @{ Id = 'T64'; Desc = 'export DLL-name RVA 0 is missing, not header text'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x60C 0 }
       Expect = @('RESULT: MALFORMED', 'export DLL name: RVA is 0 (missing mandatory reference)'); Reject = @('DLL name     : MZ') }
    @{ Id = 'T65'; Desc = 'export name-pointer entry 0 is missing, not header text'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x63C 0 }
       Expect = @('RESULT: MALFORMED', 'export name 1: name RVA is 0 (missing mandatory reference)'); Reject = @('names: MZ') }
    @{ Id = 'T66'; Desc = 'address table RVA 0 with NumberOfFunctions > 0'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x61C 0 }
       Expect = @('RESULT: MALFORMED', 'export address table: RVA is 0 (missing mandatory reference) but NumberOfFunctions is 5') }
    @{ Id = 'T67'; Desc = 'name pointer table RVA 0 with NumberOfNames > 0'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x620 0 }
       Expect = @('RESULT: MALFORMED', 'export name pointer table: RVA is 0 (missing mandatory reference) but NumberOfNames is 4') }
    @{ Id = 'T68'; Desc = 'ordinal table RVA 0 with NumberOfNames > 0'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x624 0 }
       Expect = @('RESULT: MALFORMED', 'export ordinal table: RVA is 0 (missing mandatory reference) but NumberOfNames is 4') }
    @{ Id = 'T69'; Desc = 'no names: zero name-table RVAs are valid'; Exit = 0; Build = $exp
       Mutate = { param($b) W32 $b 0x618 0; W32 $b 0x620 0; W32 $b 0x624 0 }
       Expect = @('NumberOfFunctions=5 NumberOfNames=0 AddressOfFunctions=0x3028 AddressOfNames=0x0 AddressOfNameOrdinals=0x0',
                  ($text1 + '; names: (none)'), 'Total exports: 5 address-table entries (targets 3, forwarders 1, unused 1); names 0', 'RESULT: OK') }
    @{ Id = 'T70'; Desc = 'empty export table: zero counts and zero table RVAs are valid'; Exit = 0; Build = $exp
       Mutate = { param($b) W32 $b 0x614 0; W32 $b 0x618 0; W32 $b 0x61C 0; W32 $b 0x620 0; W32 $b 0x624 0 }
       Expect = @('DLL name     : TESTEXP.DLL', 'Total exports: 0 address-table entries (targets 0, forwarders 0, unused 0); names 0', 'RESULT: OK') }
    @{ Id = 'T71'; Desc = 'export DLL name with no terminating zero before the section end'; Exit = 3; Build = $exp
       Mutate = { param($b) W32 $b 0x60C 0x31F8; for ($k = 0x7F8; $k -lt 0x800; $k++) { $b[$k] = 0x58 } }
       Expect = @('RESULT: MALFORMED', 'export DLL name: no terminating zero byte') }
    @{ Id = 'T72'; Desc = 'name pointer table truncated by the section end'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x620 0x31F8 }
       Expect = @('RESULT: MALFORMED', 'Export name pointer table (4 entries at RVA 0x31F8) runs past the stored data') }
    @{ Id = 'T73'; Desc = 'ordinal table truncated by the section end'; Exit = 3; Build = $exp; Mutate = { param($b) W32 $b 0x624 0x31FC }
       Expect = @('RESULT: MALFORMED', 'Export ordinal table (4 entries at RVA 0x31FC) runs past the stored data') }
)

# ---------------------------------------------------------------- runner
New-Item -ItemType Directory -Path $work | Out-Null
$failed = 0
try {
    foreach ($t in $tests) {
        $bytes = if ($t.ContainsKey('Build')) { & $t.Build } else { New-ValidPe }
        if ($t.ContainsKey('Mutate')) { & $t.Mutate $bytes }
        $file = Join-Path $work ($t.Id + '.dat')
        [IO.File]::WriteAllBytes($file, $bytes)
        $sha = Get-Sha256Hex $bytes
        $argBuilder = if ($t.ContainsKey('Args')) { $t.Args } else { $defaultArgs }
        $inspectorArgs = & $argBuilder $file $sha $bytes

        $out = & $psExe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $inspector @inspectorArgs | Out-String
        $code = $LASTEXITCODE

        $problems = @()
        if ($code -ne $t.Exit) { $problems += "exit code $code, expected $($t.Exit)" }
        # Keys are named Expect/Reject (not Contains) so they cannot be confused with Hashtable.Contains().
        foreach ($s in $t['Expect']) { if (-not $out.Contains($s)) { $problems += "missing '$s'" } }
        if ($t.ContainsKey('Reject')) { foreach ($s in $t['Reject']) { if ($out.Contains($s)) { $problems += "unexpected '$s'" } } }

        if ($problems.Count -eq 0) { 'PASS  {0}  {1}' -f $t.Id, $t.Desc }
        else {
            $failed++
            'FAIL  {0}  {1}: {2}' -f $t.Id, $t.Desc, ($problems -join '; ')
            ($out -split "`r?`n" | ForEach-Object { '        | ' + $_ }) -join "`n"
        }
    }
}
finally {
    # Remove only the folder this run created.
    if ($work.StartsWith([IO.Path]::GetTempPath()) -and (Split-Path -Leaf $work).StartsWith('inspect-pe-tests-')) {
        Remove-Item -LiteralPath $work -Recurse -Force
    }
}

if ($failed) { "RESULT: $failed of $($tests.Count) test(s) FAILED"; exit 1 }
"RESULT: all $($tests.Count) tests passed"
exit 0
