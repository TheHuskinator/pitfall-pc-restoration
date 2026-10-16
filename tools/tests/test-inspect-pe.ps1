<#
.SYNOPSIS
    Synthetic tests for tools/inspect-pe.ps1.

.DESCRIPTION
    DRAFT FOR SOURCE-ONLY REVIEW. This script has not yet been executed.

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

    Coverage of the ChatGPT Work review (2026-10-15):
      #1 unmapped RVA must not become a name          -> T09, T23
      #2 header/section bounds                        -> T04, T07, T08, T15, T22
      #3 import tables: termination, all-zero entry   -> T10, T11, T12
      #4 unterminated or invalid names                -> T13, T24
      #5 distinct exit codes for each outcome         -> every test checks its code
      Also: header-based RVA (T17), original order kept (T01, T17), image mode (T18, T19)
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

# Wrap bytes in synthetic raw 2,352-byte sectors (user data at +16) after $Lead filler sectors.
function New-RawImage([byte[]]$Data, [int]$Lead) {
    $blocks = [int][math]::Ceiling($Data.Length / 2048)
    $img = New-Object byte[] (($Lead + $blocks) * 2352)
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
    @{ Id = 'T10'; Desc = 'descriptor table with no terminator before section end'; Exit = 3
       Mutate = { param($b) W32 $b 0xC0 0x21EC; W32 $b 0x5EC 0x2040; W32 $b 0x5F8 0x2030; W32 $b 0x5FC 0x2060 }
       Expect = @('RESULT: MALFORMED', 'Import descriptor table is not terminated') }
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
