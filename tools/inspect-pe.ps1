<#
.SYNOPSIS
    Read-only inspector for 32-bit PE (PE32) headers, sections, static imports and exports.

.DESCRIPTION
    Review and test history: see tools/README.md.

    Reads one file into memory and optionally verifies its SHA-256. It then reports:
    the DOS/PE signatures, the COFF header, the PE32 optional header, the data
    directories, the section table, the entry-point location, the static import
    table (DLL names and function names or ordinals, in original and in sorted
    order) and, in a separate section after the imports, the export table (the
    library name, and every address-table entry with its ordinal, its names and
    aliases, and its target or forwarder).

    It never writes, executes, disassembles or extracts anything. All file access
    uses FileAccess.Read / FileShare.Read.

    Input modes
      -Path <file>
            A standalone file. Used by the synthetic tests.
      -Image <img> -Extent <lba> -Size <bytes>
            A file stored in a raw 2,352-byte-sector Mode 1 CD image, with 2,048
            bytes of user data at +16 in each sector (for example
            ASSETS/PITFALL.EXE in MEDIA-001).
    -ExpectedSha256 is required in image mode and optional in file mode.

    Structural rules enforced (a violation is reported as MALFORMED)
      - End of the section table <= SizeOfHeaders <= file size.
      - No two sections overlap in their virtual address ranges.
      - Each section's stored raw data lies inside the file.
      - The import directory [RVA, RVA + Size) lies within one supported stored
        region: the header area (see Address handling) or one section's stored
        data. Its descriptor table, including the all-zero terminator, lies within
        the declared directory Size.
      - Export metadata must be readable from stored data. That covers the export
        directory [RVA, RVA + Size), which must be at least 40 bytes and lie in one
        stored region and within SizeOfImage; the library name; the export
        address table; the name pointer table; the ordinal table; and every
        export name. All are bounds-checked, with counts capped at 65,536 and all
        arithmetic done in 64 bits. Every name's ordinal-table index must be below
        NumberOfFunctions. Several names may share one index (aliases), so having
        more names than functions is valid.
      - Forwarders (an address-table RVA inside the export directory's own range)
        must be printable strings of the form DLL.Name or DLL.#ordinal, split at
        the last '.'. Both parts must be non-empty, and the ordinal must be decimal
        0..65535. The terminating zero must lie inside [RVA, RVA + Size) of the
        export directory.

    Export target classification (this tool's policy)
      A non-forwarder export address is *classified*, not read. The parser reports
      whether it falls in the header area, or in a section (with that section's
      flags and whether the address has stored bytes in the file), or is
      "unmapped/unclassified; loader validity not established". Only an address at
      or beyond SizeOfImage is MALFORMED. Section flags are reported as
      observations only, not as proof that an export is code rather than data.
      An address-table entry of 0 is reported as unused.

    Address handling (this tool's supported policy)
      An RVA below both SizeOfHeaders and the lowest section VirtualAddress is
      mapped 1:1 into the headers. Any other RVA must fall inside exactly one
      section's virtual range (VirtualSize, or SizeOfRawData when VirtualSize is 0)
      and inside that section's stored file data. Otherwise the input is reported
      as malformed; nothing is read from an unmapped or ambiguous address.
      Bounding by VirtualSize is a deliberate, stricter policy of this tool. It is
      not claimed to reproduce the Windows loader's behavior exactly.

    Exit codes (each also printed as the final "RESULT:" line)
      0  OK             parsed successfully
      1  INPUT ERROR    bad arguments, missing file, or a size/extent/range outside the input
      2  HASH MISMATCH  SHA-256 differs from -ExpectedSha256; nothing was parsed
      3  MALFORMED      a structure is truncated, out of range, unterminated or inconsistent
      4  UNSUPPORTED    not MZ, MZ without a PE signature (e.g. NE/LE), or not PE32
      5  INTERNAL ERROR an unexpected error in this script

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\inspect-pe.ps1 `
      -Image private\original-media\Pitfall_The_Mayan_Adventure_ISO\Pitfall.img `
      -Extent 8070 -Size 772608 `
      -ExpectedSha256 36047291632BEAD27D3AF09EE99BBEF1EEC06F3B9FEA53DB906ECB1E74BFFA86
#>
[CmdletBinding(DefaultParameterSetName = 'Path')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Path')][string]$Path,
    [Parameter(Mandatory, ParameterSetName = 'Image')][string]$Image,
    [Parameter(Mandatory, ParameterSetName = 'Image')][long]$Extent,
    [Parameter(Mandatory, ParameterSetName = 'Image')][long]$Size,
    [Parameter(ParameterSetName = 'Path')]
    [Parameter(Mandatory, ParameterSetName = 'Image')][string]$ExpectedSha256,
    [long]$MaxSize = 64MB
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$RawSector = 2352
$UserDataOffset = 16
$BlockSize = 2048
$mode = $PSCmdlet.ParameterSetName
$MaxExportEntries = 65536
$script:buf = $null
$script:sections = @()
$script:sizeOfHeaders = 0L
$script:sizeOfImage = 0L

# ---------------------------------------------------------------- helpers

# Every failure goes through here: the exception carries the exit code.
function Fail([int]$Code, [string]$Message) {
    $ex = New-Object System.Exception $Message
    $ex.Data['ExitCode'] = $Code
    throw $ex
}

function Read-Exact([IO.Stream]$Stream, [byte[]]$Target, [int]$Offset, [int]$Count) {
    $done = 0
    while ($done -lt $Count) {
        $k = $Stream.Read($Target, $Offset + $done, $Count - $done)
        if ($k -le 0) { Fail 1 ('Unexpected end of input after {0} of {1} bytes' -f $done, $Count) }
        $done += $k
    }
}

# Bounds check for every read: [Offset, Offset + Length) must lie inside the buffer.
function Need([long]$Offset, [long]$Length, [string]$What) {
    if ($Offset -lt 0 -or $Length -lt 0 -or ($Offset + $Length) -gt $script:buf.LongLength) {
        Fail 3 ('{0}: needs bytes [0x{1:X}, 0x{2:X}), but the file is 0x{3:X} bytes' -f $What, $Offset, ($Offset + $Length), $script:buf.LongLength)
    }
}
function U8 ([long]$Offset, [string]$What = 'byte')  { Need $Offset 1 $What; [long]$script:buf[$Offset] }
function U16([long]$Offset, [string]$What = 'field') { Need $Offset 2 $What; [long][BitConverter]::ToUInt16($script:buf, [int]$Offset) }
function U32([long]$Offset, [string]$What = 'field') { Need $Offset 4 $What; [long][BitConverter]::ToUInt32($script:buf, [int]$Offset) }

function Hex([byte[]]$Bytes) { ($Bytes | ForEach-Object { '{0:X2}' -f $_ }) -join ' ' }
function Printable([string]$Text) { $Text -replace '[^\x20-\x7E]', '.' }

# Zero-terminated ASCII string. It must end before $Limit (exclusive) and within
# 4,096 bytes, be non-empty, and contain only printable ASCII; otherwise MALFORMED.
function Read-CString([long]$Offset, [long]$Limit, [string]$What) {
    $Limit = [math]::Min($Limit, $script:buf.LongLength)
    if ($Offset -lt 0 -or $Offset -ge $Limit) {
        Fail 3 ('{0}: starts at 0x{1:X}, outside its region (which ends at 0x{2:X})' -f $What, $Offset, $Limit)
    }
    $end = [math]::Min($Limit, $Offset + 4096)
    $z = $Offset
    while ($z -lt $end -and $script:buf[$z] -ne 0) { $z++ }
    if ($z -ge $end) { Fail 3 ('{0}: no terminating zero byte between 0x{1:X} and 0x{2:X}' -f $What, $Offset, $end) }
    if ($z -eq $Offset) { Fail 3 ('{0}: empty string at 0x{1:X}' -f $What, $Offset) }
    for ($i = $Offset; $i -lt $z; $i++) {
        $ch = $script:buf[$i]
        if ($ch -lt 0x20 -or $ch -gt 0x7E) { Fail 3 ('{0}: non-printable byte 0x{1:X2} at 0x{2:X}' -f $What, $ch, $i) }
    }
    [Text.Encoding]::ASCII.GetString($script:buf, [int]$Offset, [int]($z - $Offset))
}

# Map an RVA to a file offset. Returns @{ Offset; Limit; Region }, where Limit is the
# exclusive end of the stored bytes that the RVA may use. Never returns a sentinel:
# an unmappable RVA is MALFORMED.
function Resolve-Rva([long]$Rva, [string]$What) {
    $firstVa = [long]::MaxValue
    foreach ($s in $script:sections) { if ($s.VA -lt $firstVa) { $firstVa = $s.VA } }
    $hdrEnd = [math]::Min([math]::Min($script:sizeOfHeaders, $firstVa), $script:buf.LongLength)
    if ($Rva -ge 0 -and $Rva -lt $hdrEnd) {
        return @{ Offset = $Rva; Limit = $hdrEnd; Region = '(headers)' }
    }
    $hits = @($script:sections | Where-Object { $Rva -ge $_.VA -and $Rva -lt ($_.VA + $_.Span) })
    if ($hits.Count -gt 1) {
        # Overlaps are rejected when the section table is read; this is a second, local guard.
        Fail 3 ('{0}: RVA 0x{1:X} is ambiguous; it lies in sections {2}' -f $What, $Rva, (($hits | ForEach-Object { $_.Name }) -join ', '))
    }
    if ($hits.Count -eq 0) { Fail 3 ('{0}: RVA 0x{1:X} is not inside the headers or any section' -f $What, $Rva) }
    $s = $hits[0]
    $mapped = [math]::Min($s.Span, $s.RawSize)
    $delta = $Rva - $s.VA
    if ($delta -ge $mapped) {
        Fail 3 ('{0}: RVA 0x{1:X} is in section {2} but beyond its stored file data' -f $What, $Rva, $s.Name)
    }
    return @{ Offset = $s.RawPtr + $delta; Limit = $s.RawPtr + $mapped; Region = "section $($s.Name)" }
}

# Classify an export target RVA without reading it (see "Export target classification").
# The caller has already rejected RVAs at or beyond SizeOfImage.
function Get-TargetClass([long]$Rva) {
    $firstVa = [long]::MaxValue
    foreach ($s in $script:sections) { if ($s.VA -lt $firstVa) { $firstVa = $s.VA } }
    $hdrEnd = [math]::Min($script:sizeOfHeaders, $firstVa)
    if ($Rva -ge 0 -and $Rva -lt $hdrEnd) { return 'header area' }
    $hits = @($script:sections | Where-Object { $Rva -ge $_.VA -and $Rva -lt ($_.VA + $_.Span) })
    if ($hits.Count -eq 1) {
        $s = $hits[0]
        $stored = if (($Rva - $s.VA) -lt [math]::Min($s.Span, $s.RawSize)) { 'stored bytes' } else { 'no stored bytes' }
        return ('section {0} [{1}] ({2})' -f $s.Name, $s.Flags, $stored)
    }
    'unmapped/unclassified; loader validity not established'
}

# ---------------------------------------------------------------- main

try {
    if ($ExpectedSha256 -and $ExpectedSha256 -notmatch '^[0-9A-Fa-f]{64}$') { Fail 1 '-ExpectedSha256 must be 64 hexadecimal characters' }
    if ($MaxSize -le 0 -or $MaxSize -gt 1GB) { Fail 1 '-MaxSize must be between 1 byte and 1 GB' }

    # ---- Load the bytes (all ranges validated before allocating or reading) ----
    if ($mode -eq 'Path') {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { Fail 1 "Not a file: $Path" }
        $full = (Resolve-Path -LiteralPath $Path).ProviderPath
        $len = (Get-Item -LiteralPath $full).Length
        if ($len -le 0 -or $len -gt $MaxSize) { Fail 1 ('File size {0} is outside 1..{1} bytes' -f $len, $MaxSize) }
        "Input        : file $full ($len bytes)"
        $script:buf = New-Object byte[] $len
        $fs = [IO.File]::Open($full, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try { Read-Exact $fs $script:buf 0 ([int]$len) } finally { $fs.Dispose() }
    }
    else {
        if (-not (Test-Path -LiteralPath $Image -PathType Leaf)) { Fail 1 "Not a file: $Image" }
        if ($Extent -lt 0) { Fail 1 '-Extent must not be negative' }
        if ($Size -le 0 -or $Size -gt $MaxSize) { Fail 1 ('-Size {0} is outside 1..{1} bytes' -f $Size, $MaxSize) }
        $full = (Resolve-Path -LiteralPath $Image).ProviderPath
        $imgLen = (Get-Item -LiteralPath $full).Length
        if ($imgLen % $RawSector -ne 0) { Fail 1 ('Image length {0} is not a multiple of {1}' -f $imgLen, $RawSector) }
        $sectorCount = [long]($imgLen / $RawSector)
        $blocks = [long][math]::Ceiling($Size / $BlockSize)
        if ($Extent + $blocks -gt $sectorCount) {
            Fail 1 ('Sectors {0}-{1} lie beyond the image ({2} sectors)' -f $Extent, ($Extent + $blocks - 1), $sectorCount)
        }
        "Input        : image $full, sectors $Extent-$($Extent + $blocks - 1), $Size bytes of Mode 1 user data"
        $script:buf = New-Object byte[] $Size
        $fs = [IO.File]::Open($full, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try {
            $done = 0L
            for ($k = 0L; $k -lt $blocks; $k++) {
                $fs.Position = ($Extent + $k) * $RawSector + $UserDataOffset
                $n = [int][math]::Min([long]$BlockSize, $Size - $done)
                Read-Exact $fs $script:buf ([int]$done) $n
                $done += $n
            }
        }
        finally { $fs.Dispose() }
    }

    # ---- Hash check before any parsing ----
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $actual = [BitConverter]::ToString($sha.ComputeHash($script:buf)).Replace('-', '') } finally { $sha.Dispose() }
    "SHA-256      : $actual"
    if ($ExpectedSha256) {
        if ($actual -ne $ExpectedSha256.ToUpperInvariant()) {
            Fail 2 ('SHA-256 differs from expected {0}; nothing parsed' -f $ExpectedSha256.ToUpperInvariant())
        }
        'SHA-256 check: matches expected value'
    }
    else { 'SHA-256 check: not performed (no -ExpectedSha256 given)' }

    # ---- DOS header and PE signature ----
    '=== DOS HEADER'
    if ($script:buf.LongLength -lt 2 -or $script:buf[0] -ne 0x4D -or $script:buf[1] -ne 0x5A) {
        Fail 4 ('Not an MZ executable (first bytes: {0})' -f (Hex $script:buf[0..([math]::Min(3, $script:buf.Length - 1))]))
    }
    Need 0 64 'DOS header'
    $lfanew = U32 0x3C 'e_lfanew'
    Need $lfanew 4 'PE signature at e_lfanew'
    $sigBytes = [byte[]]$script:buf[$lfanew..($lfanew + 3)]
    'e_magic=MZ e_lfanew=0x{0:X}' -f $lfanew
    'Signature    : {0} (''{1}'')' -f (Hex $sigBytes), (Printable ([Text.Encoding]::ASCII.GetString($sigBytes)))
    if (-not ($sigBytes[0] -eq 0x50 -and $sigBytes[1] -eq 0x45 -and $sigBytes[2] -eq 0 -and $sigBytes[3] -eq 0)) {
        Fail 4 ('MZ file without a PE signature at 0x{0:X} (found {1}); NE/LE/LX/DOS formats are not supported' -f $lfanew, (Hex $sigBytes))
    }

    # ---- COFF header ----
    '=== COFF HEADER'
    $c = $lfanew + 4
    Need $c 20 'COFF header'
    $machine = U16 $c; $nsec = U16 ($c + 2); $tds = U32 ($c + 4)
    $symPtr = U32 ($c + 8); $symCount = U32 ($c + 12); $optSize = U16 ($c + 16); $chars = U16 ($c + 18)
    'Machine=0x{0:X4} Sections={1} TimeDateStamp=0x{2:X8} (field decodes to {3:yyyy-MM-dd HH:mm:ss} UTC) PtrSymTab=0x{4:X} NumSyms={5} SizeOfOptionalHeader={6} Characteristics=0x{7:X4}' -f `
        $machine, $nsec, $tds, ([DateTimeOffset]::FromUnixTimeSeconds($tds).UtcDateTime), $symPtr, $symCount, $optSize, $chars
    $charNames = @(
        @(0x0001, 'RELOCS_STRIPPED'), @(0x0002, 'EXECUTABLE_IMAGE'), @(0x0004, 'LINE_NUMS_STRIPPED'),
        @(0x0008, 'LOCAL_SYMS_STRIPPED'), @(0x0020, 'LARGE_ADDRESS_AWARE'), @(0x0100, '32BIT_MACHINE'),
        @(0x0200, 'DEBUG_STRIPPED'), @(0x2000, 'DLL'))
    '  flags: ' + (($charNames | Where-Object { $chars -band $_[0] } | ForEach-Object { $_[1] }) -join ', ')
    if ($nsec -eq 0 -or $nsec -gt 96) { Fail 3 ('NumberOfSections {0} is outside 1..96' -f $nsec) }

    # ---- Optional header ----
    '=== OPTIONAL HEADER'
    $o = $c + 20
    $magic = U16 $o 'optional header magic'
    if ($magic -eq 0x20B) { Fail 4 'Optional header magic 0x20B (PE32+, 64-bit) is not supported' }
    if ($magic -eq 0x107) { Fail 4 'Optional header magic 0x107 (ROM image) is not supported' }
    if ($magic -ne 0x10B) { Fail 3 ('Unknown optional header magic 0x{0:X4}' -f $magic) }
    if ($optSize -lt 96) { Fail 3 ('SizeOfOptionalHeader {0} is smaller than the 96-byte PE32 fixed part' -f $optSize) }
    Need $o $optSize 'optional header'
    $ep = U32 ($o + 16); $imageBase = U32 ($o + 28)
    'Magic=0x10B (PE32, 32-bit)  Linker={0}.{1}  SizeOfCode={2} SizeOfInitData={3} SizeOfUninitData={4}' -f `
        (U8 ($o + 2)), (U8 ($o + 3)), (U32 ($o + 4)), (U32 ($o + 8)), (U32 ($o + 12))
    'AddressOfEntryPoint=0x{0:X} BaseOfCode=0x{1:X} BaseOfData=0x{2:X} ImageBase=0x{3:X8}' -f $ep, (U32 ($o + 20)), (U32 ($o + 24)), $imageBase
    'SectionAlignment=0x{0:X} FileAlignment=0x{1:X} OSVersion={2}.{3} ImageVersion={4}.{5} SubsystemVersion={6}.{7} Win32VersionValue={8}' -f `
        (U32 ($o + 32)), (U32 ($o + 36)), (U16 ($o + 40)), (U16 ($o + 42)), (U16 ($o + 44)), (U16 ($o + 46)), (U16 ($o + 48)), (U16 ($o + 50)), (U32 ($o + 52))
    $subsys = U16 ($o + 68)
    $subNames = @{ 1 = 'NATIVE'; 2 = 'WINDOWS_GUI'; 3 = 'WINDOWS_CUI'; 5 = 'OS2_CUI'; 7 = 'POSIX_CUI' }
    $subName = if ($subNames.ContainsKey([int]$subsys)) { $subNames[[int]$subsys] } else { 'unknown' }
    $script:sizeOfHeaders = U32 ($o + 60)
    $script:sizeOfImage = U32 ($o + 56)
    'SizeOfImage=0x{0:X} SizeOfHeaders=0x{1:X} CheckSum=0x{2:X8} Subsystem={3} ({4}) DllCharacteristics=0x{5:X4}' -f `
        $script:sizeOfImage, $script:sizeOfHeaders, (U32 ($o + 64)), $subsys, $subName, (U16 ($o + 70))
    'StackReserve=0x{0:X} StackCommit=0x{1:X} HeapReserve=0x{2:X} HeapCommit=0x{3:X} LoaderFlags=0x{4:X}' -f `
        (U32 ($o + 72)), (U32 ($o + 76)), (U32 ($o + 80)), (U32 ($o + 84)), (U32 ($o + 88))
    if ($script:sizeOfHeaders -gt $script:buf.LongLength) {
        Fail 3 ('SizeOfHeaders 0x{0:X} exceeds the file size 0x{1:X}' -f $script:sizeOfHeaders, $script:buf.LongLength)
    }

    # ---- Data directories (bounded by NumberOfRvaAndSizes and SizeOfOptionalHeader) ----
    $numDirs = U32 ($o + 92)
    'NumberOfRvaAndSizes=' + $numDirs
    if (96 + 8 * $numDirs -gt $optSize) {
        Fail 3 ('NumberOfRvaAndSizes {0} needs {1} bytes of data directories, but SizeOfOptionalHeader leaves {2}' -f $numDirs, (8 * $numDirs), ($optSize - 96))
    }
    $dirNames = 'Export', 'Import', 'Resource', 'Exception', 'Security', 'BaseReloc', 'Debug', 'Architecture',
                'GlobalPtr', 'TLS', 'LoadConfig', 'BoundImport', 'IAT', 'DelayImport', 'CLR', 'Reserved'
    $dirs = @{}
    'Data directories present (RVA, size):'
    for ($i = 0; $i -lt [math]::Min(16L, $numDirs); $i++) {
        $va = U32 ($o + 96 + 8 * $i); $sz = U32 ($o + 100 + 8 * $i)
        $dirs[$i] = @($va, $sz)
        if ($va -or $sz) { '  {0,-12} 0x{1:X8} 0x{2:X}' -f $dirNames[$i], $va, $sz }
    }
    if ($numDirs -gt 16) { 'NOTE: NumberOfRvaAndSizes {0} is above 16; only the 16 defined directories were read' -f $numDirs }

    # ---- Section table ----
    '=== SECTIONS'
    $st = $o + $optSize
    Need $st (40 * $nsec) 'section table'
    $stEnd = $st + 40 * $nsec
    if ($script:sizeOfHeaders -lt $stEnd) {
        Fail 3 ('SizeOfHeaders 0x{0:X} does not cover the section table, which ends at 0x{1:X}' -f $script:sizeOfHeaders, $stEnd)
    }
    for ($i = 0; $i -lt $nsec; $i++) {
        $b = $st + 40 * $i
        $name = Printable (([Text.Encoding]::ASCII.GetString($script:buf, [int]$b, 8)).TrimEnd([char]0))
        $s = [pscustomobject]@{
            Name = $name; VSize = (U32 ($b + 8)); VA = (U32 ($b + 12))
            RawSize = (U32 ($b + 16)); RawPtr = (U32 ($b + 20)); Chars = (U32 ($b + 36)); Span = 0L; Flags = ''
        }
        $s.Span = if ($s.VSize -gt 0) { $s.VSize } else { $s.RawSize }   # virtual extent used for address mapping
        $f = @()
        if ($s.Chars -band 0x20) { $f += 'CODE' }
        if ($s.Chars -band 0x40) { $f += 'IDATA' }
        if ($s.Chars -band 0x80) { $f += 'UDATA' }
        if ($s.Chars -band 0x02000000L) { $f += 'DISCARDABLE' }
        if ($s.Chars -band 0x10000000L) { $f += 'SHARED' }
        if ($s.Chars -band 0x20000000L) { $f += 'X' }
        if ($s.Chars -band 0x40000000L) { $f += 'R' }
        if ($s.Chars -band 0x80000000L) { $f += 'W' }
        $s.Flags = ($f -join ' ')   # kept for export target classification
        '  {0,-8} VA=0x{1:X8} VSize=0x{2:X8} RawPtr=0x{3:X8} RawSize=0x{4:X8} Chars=0x{5:X8} [{6}]' -f `
            $s.Name, $s.VA, $s.VSize, $s.RawPtr, $s.RawSize, $s.Chars, ($f -join ' ')
        if ($s.RawSize -gt 0) { Need $s.RawPtr $s.RawSize ('section {0} raw data' -f $name) }
        $script:sections += $s
    }
    # Reject overlapping virtual ranges so that every RVA maps to at most one section.
    for ($i = 0; $i -lt $script:sections.Count; $i++) {
        for ($j = $i + 1; $j -lt $script:sections.Count; $j++) {
            $p = $script:sections[$i]; $q = $script:sections[$j]
            if ($p.Span -gt 0 -and $q.Span -gt 0 -and $p.VA -lt ($q.VA + $q.Span) -and $q.VA -lt ($p.VA + $p.Span)) {
                Fail 3 ('Sections {0} [0x{1:X}, 0x{2:X}) and {3} [0x{4:X}, 0x{5:X}) overlap in virtual address range' -f `
                    $p.Name, $p.VA, ($p.VA + $p.Span), $q.Name, $q.VA, ($q.VA + $q.Span))
            }
        }
    }
    $lastRawEnd = 0L
    foreach ($s in $script:sections) {
        if ($s.RawSize -gt 0 -and ($s.RawPtr + $s.RawSize) -gt $lastRawEnd) { $lastRawEnd = $s.RawPtr + $s.RawSize }
    }
    'Raw data ends at 0x{0:X} ({0}); file size {1}; bytes after the last section: {2}' -f `
        $lastRawEnd, $script:buf.LongLength, ($script:buf.LongLength - $lastRawEnd)

    # ---- Entry point ----
    if ($ep -eq 0) { 'Entry point  : none (AddressOfEntryPoint = 0)' }
    else {
        $epSec = $null
        foreach ($s in $script:sections) {
            if ($ep -ge $s.VA -and $ep -lt ($s.VA + $s.Span)) { $epSec = $s; break }
        }
        if ($epSec) {
            $delta = $ep - $epSec.VA
            $offText = if ($delta -lt $epSec.RawSize) { '0x{0:X}' -f ($epSec.RawPtr + $delta) } else { '(beyond the section''s stored data)' }
            'Entry point  : RVA 0x{0:X}, VA 0x{1:X8}, section {2}, file offset {3}' -f $ep, ($imageBase + $ep), $epSec.Name, $offText
        }
        else { 'Entry point  : RVA 0x{0:X} is not inside any section' -f $ep }
    }

    # ---- Static imports ----
    '=== STATIC IMPORTS'
    if (-not $dirs.ContainsKey(1) -or $dirs[1][0] -eq 0) { '(no import directory)' }
    else {
        $impRva = $dirs[1][0]; $impSize = $dirs[1][1]
        if ($impSize -lt 20) { Fail 3 ('Import directory size {0} is too small to hold even the 20-byte terminator' -f $impSize) }
        $loc = Resolve-Rva $impRva 'import directory'
        if ($loc.Offset + $impSize -gt $loc.Limit) {
            Fail 3 ('Import directory [RVA 0x{0:X}, size 0x{1:X}) extends beyond the stored data of {2} (ends at file offset 0x{3:X})' -f $impRva, $impSize, $loc.Region, $loc.Limit)
        }
        $tableEnd = $loc.Offset + $impSize   # descriptors, including the terminator, must lie within the declared size
        $d = $loc.Offset; $nDesc = 0; $total = 0
        while ($true) {
            if ($d + 20 -gt $tableEnd) {
                Fail 3 ('Import descriptor table is not terminated within the declared import directory size 0x{0:X}: entry {1} at 0x{2:X} would end at 0x{3:X}' -f $impSize, ($nDesc + 1), $d, ($d + 20))
            }
            $oft = U32 $d; $dts = U32 ($d + 4); $fwd = U32 ($d + 8); $nameRva = U32 ($d + 12); $ft = U32 ($d + 16)
            if (($oft -bor $dts -bor $fwd -bor $nameRva -bor $ft) -eq 0) { break }   # all five fields zero = terminator
            $nDesc++
            if ($nDesc -gt 4096) { Fail 3 'More than 4096 import descriptors; refusing to continue' }
            if ($nameRva -eq 0 -or ($oft -eq 0 -and $ft -eq 0)) {
                Fail 3 ('Import descriptor {0} at 0x{1:X} is neither a valid entry nor an all-zero terminator (Name=0x{2:X} OriginalFirstThunk=0x{3:X} FirstThunk=0x{4:X})' -f $nDesc, $d, $nameRva, $oft, $ft)
            }
            $what = 'import descriptor {0} DLL name' -f $nDesc
            $nl = Resolve-Rva $nameRva $what
            $dll = Read-CString $nl.Offset $nl.Limit $what
            if ($oft) { $tRva = $oft; $via = 'OriginalFirstThunk' } else { $tRva = $ft; $via = 'FirstThunk (no OriginalFirstThunk)' }
            $tl = Resolve-Rva $tRva ('{0} lookup table' -f $dll)
            $t = $tl.Offset
            $entries = New-Object System.Collections.Generic.List[object]
            while ($true) {
                if ($t + 4 -gt $tl.Limit) {
                    Fail 3 ('{0} lookup table is not terminated before the end of {1} (0x{2:X})' -f $dll, $tl.Region, $tl.Limit)
                }
                $v = U32 $t
                if ($v -eq 0) { break }
                if ($entries.Count -ge 65536) { Fail 3 ('{0} lookup table has more than 65536 entries' -f $dll) }
                $idx = $entries.Count + 1
                if ($v -band 0x80000000L) {
                    if ($v -band 0x7FFF0000L) { Fail 3 ('{0} entry {1}: ordinal entry 0x{2:X8} has reserved bits 16-30 set' -f $dll, $idx, $v) }
                    $ord = $v -band 0xFFFF
                    $entries.Add([pscustomobject]@{ Kind = 'Ordinal'; Ordinal = $ord; Text = ('#{0}' -f $ord) })
                }
                else {
                    $what = '{0} entry {1} hint/name' -f $dll, $idx
                    $hl = Resolve-Rva $v $what
                    if ($hl.Offset + 2 -ge $hl.Limit) { Fail 3 ('{0}: no room for a name after the 2-byte hint at 0x{1:X}' -f $what, $hl.Offset) }
                    $entries.Add([pscustomobject]@{ Kind = 'Name'; Ordinal = $null; Text = (Read-CString ($hl.Offset + 2) $hl.Limit $what) })
                }
                $t += 4
            }
            $total += $entries.Count
            # Display-only sort: ordinals numerically first, then names by ordinal (byte-wise) string comparison.
            $names = New-Object System.Collections.Generic.List[string]
            foreach ($e in $entries) { if ($e.Kind -eq 'Name') { $names.Add($e.Text) } }
            $names.Sort([StringComparer]::Ordinal)
            $sorted = @($entries | Where-Object { $_.Kind -eq 'Ordinal' } | Sort-Object Ordinal | ForEach-Object { $_.Text }) + @($names)
            $nOrd = @($entries | Where-Object { $_.Kind -eq 'Ordinal' }).Count
            'DLL {0}  ({1} entries: {2} by name, {3} by ordinal; read via {4}; OriginalFirstThunk=0x{5:X} TimeDateStamp=0x{6:X} ForwarderChain=0x{7:X} FirstThunk=0x{8:X})' -f `
                $dll, $entries.Count, ($entries.Count - $nOrd), $nOrd, $via, $oft, $dts, $fwd, $ft
            '  original order: ' + (($entries | ForEach-Object { $_.Text }) -join ', ')
            '  sorted        : ' + ($sorted -join ', ')
            $d += 20
        }
        'Total imported functions: {0} from {1} DLL(s)' -f $total, $nDesc
    }

    # ---- Exports (a separate, added section; all output above is unchanged) ----
    '=== EXPORTS'
    if (-not $dirs.ContainsKey(0) -or $dirs[0][0] -eq 0) { '(no export directory)' }
    else {
        $expRva = $dirs[0][0]; $expSize = $dirs[0][1]
        $expEnd = $expRva + $expSize                     # 64-bit arithmetic: cannot wrap around
        if ($expSize -lt 40) { Fail 3 ('Export directory size {0} is smaller than the 40-byte export directory table' -f $expSize) }
        if ($expEnd -gt $script:sizeOfImage) {
            Fail 3 ('Export directory [RVA 0x{0:X}, 0x{1:X}) extends beyond SizeOfImage 0x{2:X}' -f $expRva, $expEnd, $script:sizeOfImage)
        }
        $el = Resolve-Rva $expRva 'export directory'
        if ($el.Offset + $expSize -gt $el.Limit) {
            Fail 3 ('Export directory [RVA 0x{0:X}, size 0x{1:X}) extends beyond the stored data of {2} (ends at file offset 0x{3:X})' -f $expRva, $expSize, $el.Region, $el.Limit)
        }
        $x = $el.Offset
        $eFlags = U32 $x; $eTds = U32 ($x + 4); $eMaj = U16 ($x + 8); $eMin = U16 ($x + 10); $eNameRva = U32 ($x + 12)
        $eBase = U32 ($x + 16); $nFunc = U32 ($x + 20); $nNames = U32 ($x + 24)
        $eatRva = U32 ($x + 28); $nptRva = U32 ($x + 32); $otRva = U32 ($x + 36)
        'Export directory: RVA 0x{0:X}, size 0x{1:X}, in {2}' -f $expRva, $expSize, $el.Region
        $nl = Resolve-Rva $eNameRva 'export DLL name'
        'DLL name     : ' + (Read-CString $nl.Offset $nl.Limit 'export DLL name')
        'Characteristics=0x{0:X} TimeDateStamp=0x{1:X8} (field decodes to {2:yyyy-MM-dd HH:mm:ss} UTC) Version={3}.{4} OrdinalBase={5}' -f `
            $eFlags, $eTds, ([DateTimeOffset]::FromUnixTimeSeconds($eTds).UtcDateTime), $eMaj, $eMin, $eBase
        'NumberOfFunctions={0} NumberOfNames={1} AddressOfFunctions=0x{2:X} AddressOfNames=0x{3:X} AddressOfNameOrdinals=0x{4:X}' -f `
            $nFunc, $nNames, $eatRva, $nptRva, $otRva
        if ($eFlags -ne 0) { 'NOTE: export Characteristics is 0x{0:X}; the field is reserved and normally 0' -f $eFlags }
        if ($nFunc -gt $MaxExportEntries) { Fail 3 ('NumberOfFunctions {0} exceeds this tool''s limit of {1}' -f $nFunc, $MaxExportEntries) }
        if ($nNames -gt $MaxExportEntries) { Fail 3 ('NumberOfNames {0} exceeds this tool''s limit of {1}' -f $nNames, $MaxExportEntries) }
        if ($nFunc -gt 0 -and ($eBase + $nFunc - 1) -gt 0xFFFF) {
            'NOTE: the highest ordinal, {0}, exceeds 65535 and could not be imported by ordinal' -f ($eBase + $nFunc - 1)
        }

        # Metadata tables: each must be readable from one stored region.
        $eat = 0L; $npt = 0L; $ot = 0L
        if ($nFunc -gt 0) {
            $tl = Resolve-Rva $eatRva 'export address table'
            if ($tl.Offset + 4 * $nFunc -gt $tl.Limit) {
                Fail 3 ('Export address table ({0} entries at RVA 0x{1:X}) runs past the stored data of {2}' -f $nFunc, $eatRva, $tl.Region)
            }
            $eat = $tl.Offset
        }
        if ($nNames -gt 0) {
            $tl = Resolve-Rva $nptRva 'export name pointer table'
            if ($tl.Offset + 4 * $nNames -gt $tl.Limit) {
                Fail 3 ('Export name pointer table ({0} entries at RVA 0x{1:X}) runs past the stored data of {2}' -f $nNames, $nptRva, $tl.Region)
            }
            $npt = $tl.Offset
            $tl = Resolve-Rva $otRva 'export ordinal table'
            if ($tl.Offset + 2 * $nNames -gt $tl.Limit) {
                Fail 3 ('Export ordinal table ({0} entries at RVA 0x{1:X}) runs past the stored data of {2}' -f $nNames, $otRva, $tl.Region)
            }
            $ot = $tl.Offset
        }

        # Names. Several names may share one address-table index (aliases); that is valid.
        $aliases = @{}   # [long] index -> list of names, in name-table order
        $seen = New-Object 'System.Collections.Generic.Dictionary[string,long]' ([StringComparer]::Ordinal)
        for ($i = 0L; $i -lt $nNames; $i++) {
            $what = 'export name {0}' -f ($i + 1)
            $idx = U16 ($ot + 2 * $i)
            if ($idx -ge $nFunc) { Fail 3 ('{0}: ordinal-table index {1} is not below NumberOfFunctions {2}' -f $what, $idx, $nFunc) }
            $nr = Resolve-Rva (U32 ($npt + 4 * $i)) $what
            $nm = Read-CString $nr.Offset $nr.Limit $what
            if ($seen.ContainsKey($nm)) { 'NOTE: duplicate export name {0} (name entries {1} and {2})' -f $nm, $seen[$nm], ($i + 1) }
            else { $seen[$nm] = $i + 1 }
            if (-not $aliases.ContainsKey($idx)) { $aliases[$idx] = New-Object System.Collections.Generic.List[string] }
            $aliases[$idx].Add($nm)
        }

        # Address table, in original (index) order. Targets are classified, not read.
        $nT = 0; $nF = 0; $nU = 0
        for ($i = 0L; $i -lt $nFunc; $i++) {
            $ord = $eBase + $i
            $names = if ($aliases.ContainsKey($i)) { $aliases[$i] -join ', ' } else { '(none)' }
            $v = U32 ($eat + 4 * $i)
            if ($v -eq 0) {
                $nU++
                '  ordinal {0}: unused (address 0); names: {1}' -f $ord, $names
                if ($aliases.ContainsKey($i)) { 'NOTE: export name(s) {0} refer to the unused address-table entry for ordinal {1}' -f $names, $ord }
                continue
            }
            if ($v -ge $expRva -and $v -lt $expEnd) {
                # Forwarder: the string, including its terminating zero, must lie inside the export directory range.
                $what = 'export ordinal {0} forwarder' -f $ord
                $text = Read-CString ($el.Offset + ($v - $expRva)) ($el.Offset + $expSize) $what
                $dot = $text.LastIndexOf('.')
                if ($dot -le 0 -or $dot -ge $text.Length - 1) {
                    Fail 3 ('{0}: "{1}" is not of the form DLL.Name or DLL.#ordinal' -f $what, $text)
                }
                $target = $text.Substring($dot + 1)
                if ($target.StartsWith('#') -and ($target -notmatch '^#\d{1,5}$' -or [long]$target.Substring(1) -gt 65535)) {
                    Fail 3 ('{0}: "{1}" has an invalid ordinal form; expected # followed by a decimal number 0..65535' -f $what, $text)
                }
                $nF++
                '  ordinal {0}: forwarder -> {1}; names: {2}' -f $ord, $text, $names
                continue
            }
            if ($v -ge $script:sizeOfImage) {
                Fail 3 ('Export ordinal {0}: target RVA 0x{1:X} is at or beyond SizeOfImage 0x{2:X}' -f $ord, $v, $script:sizeOfImage)
            }
            $nT++
            '  ordinal {0}: RVA 0x{1:X8} -> {2}; names: {3}' -f $ord, $v, (Get-TargetClass $v), $names
        }
        'Total exports: {0} address-table entries (targets {1}, forwarders {2}, unused {3}); names {4}' -f $nFunc, $nT, $nF, $nU, $nNames
    }
}
catch {
    $ex = $_.Exception
    $code = 5
    if ($ex.Data.Contains('ExitCode')) { $code = [int]$ex.Data['ExitCode'] }
    else {
        for ($x = $ex; $x; $x = $x.InnerException) {
            if ($x -is [IO.IOException] -or $x -is [UnauthorizedAccessException]) { $code = 1; break }
        }
    }
    $labels = @{ 1 = 'INPUT ERROR'; 2 = 'HASH MISMATCH'; 3 = 'MALFORMED'; 4 = 'UNSUPPORTED'; 5 = 'INTERNAL ERROR' }
    'RESULT: {0}: {1}' -f $labels[$code], $ex.Message
    exit $code
}
'RESULT: OK'
exit 0
