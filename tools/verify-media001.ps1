<#
.SYNOPSIS
    Read-only verifier for disc image MEDIA-001 (Pitfall, CloneCD-style IMG/SUB).

.DESCRIPTION
    Re-confirms the recorded MEDIA-001 findings without modifying, mounting,
    extracting or executing anything:

      1. EDC self-test on a published check string (no image access).
      2. Image SHA-256 and IMG/SUB sector counts.
      3. Mode 1 sync, header address, mode byte and EDC for every data sector.
      4. ISO 9660 primary volume descriptor fields.
      5. ISO 9660 directory walk: every file's path, size, extent and in-memory
         SHA-256, compared with the table in docs/inventory/materials-inventory.md.

    The media files are opened with FileAccess.Read / FileShare.Read only.
    File contents are hashed in memory and never written to disk.
    Output is a PASS/FAIL line per check; the exit code is 0 only if all pass.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify-media001.ps1
#>
[CmdletBinding()]
param(
    [string]$ImageDir = 'private/original-media/Pitfall_The_Mayan_Adventure_ISO',
    [string]$Inventory = 'docs/inventory/materials-inventory.md',
    # Expected values recorded in docs/technical/original-media-examination.md and disc-contents.md.
    [long]$ExpectedSectors = 272313,
    [int]$ExpectedDataSectors = 8880,
    [string]$ExpectedVolumeId = 'PITFALL',
    [int]$ExpectedVolumeBlocks = 8728,
    [switch]$SkipImageHash
)

$ErrorActionPreference = 'Stop'
$RAW = 2352; $SUBSZ = 96; $BLK = 2048; $USER = 16
$script:failures = 0

function Report([string]$name, [bool]$ok, [string]$detail) {
    if (-not $ok) { $script:failures++ }
    '{0}  {1}  {2}' -f $(if ($ok) { 'PASS' } else { 'FAIL' }), $name, $detail
}

Add-Type -TypeDefinition @'
public static class Media001Check {
    static readonly uint[] T = Build();
    static uint[] Build() {
        var t = new uint[256];
        for (uint i = 0; i < 256; i++) { uint e = i; for (int k = 0; k < 8; k++) e = (e >> 1) ^ ((e & 1) != 0 ? 0xD8018001u : 0u); t[i] = e; }
        return t;
    }
    // CRC-32/CD-ROM-EDC: poly 0x8001801B (reflected 0xD8018001), init 0, refin/refout, xorout 0.
    public static uint Edc(byte[] b, int len) { uint e = 0; for (int i = 0; i < len; i++) e = (e >> 8) ^ T[(e ^ b[i]) & 0xFF]; return e; }
    static byte Bcd(int v) { return (byte)(((v / 10) << 4) | (v % 10)); }
    // Returns null if the raw Mode 1 sector at this LBA is valid, else a reason.
    public static string CheckMode1(byte[] r, long lba) {
        if (r[0] != 0 || r[11] != 0) return "sync";
        for (int i = 1; i <= 10; i++) if (r[i] != 0xFF) return "sync";
        long a = lba + 150;
        if (r[12] != Bcd((int)(a / 4500)) || r[13] != Bcd((int)(a / 75 % 60)) || r[14] != Bcd((int)(a % 75))) return "header-address";
        if (r[15] != 1) return "mode=" + r[15];
        if (Edc(r, 2064) != System.BitConverter.ToUInt32(r, 2064)) return "EDC";
        return null;
    }
}
'@

# ---- Expected values from the committed inventory (single source of truth) ----
$invText = Get-Content -LiteralPath $Inventory -Raw
$m = [regex]::Match($invText, '\|\s*MEDIA-001a\s*\|[^\n]*?`([0-9A-F]{64})`')
if (-not $m.Success) { throw "MEDIA-001a hash not found in $Inventory" }
$expectedImageHash = $m.Groups[1].Value
$expectedFiles = @{}
foreach ($row in [regex]::Matches($invText, '(?m)^\|\s*`([A-Z0-9_./]+)`\s*\|\s*([\d,]+)\s*\|\s*(\d+)\s*\|\s*`([0-9A-F]{64})`\s*\|\s*$')) {
    $expectedFiles[$row.Groups[1].Value] = [pscustomobject]@{ Size = [long]($row.Groups[2].Value -replace ',', ''); Extent = [long]$row.Groups[3].Value; Sha = $row.Groups[4].Value }
}
"Expected values: image hash and $($expectedFiles.Count) file rows read from $Inventory"

# ---- 1. EDC self-test (no image access) ----
$probe = [Text.Encoding]::ASCII.GetBytes('123456789')
$got = [Media001Check]::Edc($probe, $probe.Length)
Report 'EDC self-test' ($got -eq 0x6EC2EDC4) ('"123456789" -> 0x{0:X8} (expected 0x6EC2EDC4)' -f $got)

# ---- 2. Image hash and sector counts ----
$img = Get-Item -LiteralPath (Join-Path $ImageDir 'Pitfall.img')
$sub = Get-Item -LiteralPath (Join-Path $ImageDir 'Pitfall.sub')
if ($SkipImageHash) { '-     Image SHA-256  skipped (-SkipImageHash)' }
else {
    $h = (Get-FileHash -LiteralPath $img.FullName -Algorithm SHA256).Hash
    Report 'Image SHA-256' ($h -eq $expectedImageHash) $h
}
Report 'IMG sector count' (($img.Length % $RAW -eq 0) -and ($img.Length / $RAW -eq $ExpectedSectors)) ('{0} / {1} = {2} rem {3}' -f $img.Length, $RAW, [math]::Floor($img.Length / $RAW), ($img.Length % $RAW))
Report 'SUB sector count' (($sub.Length % $SUBSZ -eq 0) -and ($sub.Length / $SUBSZ -eq $ExpectedSectors)) ('{0} / {1} = {2} rem {3}' -f $sub.Length, $SUBSZ, [math]::Floor($sub.Length / $SUBSZ), ($sub.Length % $SUBSZ))

$fs = [IO.File]::Open($img.FullName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
try {
    function ReadRaw([long]$lba) {
        $b = New-Object byte[] $RAW; $fs.Position = $lba * $RAW; $r = 0
        while ($r -lt $RAW) { $k = $fs.Read($b, $r, $RAW - $r); if ($k -le 0) { throw "short read at LBA $lba" }; $r += $k }
        , $b
    }
    function ReadBlock([long]$lba) {
        if ($lba -lt 0 -or $lba -ge $ExpectedDataSectors) { throw "LBA $lba outside the data track" }
        $u = New-Object byte[] $BLK; [Array]::Copy((ReadRaw $lba), $USER, $u, 0, $BLK); , $u
    }

    # ---- 3. Every data sector: sync, header address, mode, EDC ----
    $bad = New-Object System.Collections.Generic.List[string]
    for ($l = 0; $l -lt $ExpectedDataSectors; $l++) {
        $why = [Media001Check]::CheckMode1((ReadRaw $l), $l)
        if ($why) { $bad.Add("LBA ${l}: $why") }
    }
    Report 'Mode 1 sectors (sync/header/mode/EDC)' ($bad.Count -eq 0) ("{0} checked (LBA 0-{1}), {2} problems{3}" -f $ExpectedDataSectors, ($ExpectedDataSectors - 1), $bad.Count, $(if ($bad.Count) { ': ' + (($bad | Select-Object -First 5) -join '; ') } else { '' }))

    # ---- 4. Primary volume descriptor ----
    $pvd = ReadBlock 16
    $vid = [Text.Encoding]::ASCII.GetString($pvd, 40, 32).TrimEnd(' ', [char]0)
    $blocks = [BitConverter]::ToUInt32($pvd, 80)
    Report 'Volume descriptor' (($pvd[0] -eq 1) -and ([Text.Encoding]::ASCII.GetString($pvd, 1, 5) -eq 'CD001')) "type=$($pvd[0])"
    Report 'Volume ID' ($vid -eq $ExpectedVolumeId) "'$vid'"
    Report 'Volume space' ($blocks -eq $ExpectedVolumeBlocks) "$blocks blocks"

    # ---- 5. Directory walk and per-file comparison ----
    $found = @{}; $dirs = New-Object System.Collections.Generic.List[string]; $visited = @{}
    $queue = New-Object System.Collections.Generic.Queue[object]
    $queue.Enqueue(@([BitConverter]::ToUInt32($pvd, 158), [BitConverter]::ToUInt32($pvd, 166), ''))
    while ($queue.Count) {
        $extent, $size, $path = $queue.Dequeue()
        if ($visited.ContainsKey($extent)) { continue }; $visited[$extent] = $true
        for ($k = 0; $k -lt [math]::Ceiling($size / $BLK); $k++) {
            $b = ReadBlock ($extent + $k); $o = 0
            while ($o -lt $BLK -and $b[$o] -ne 0) {
                $len = $b[$o]; $nl = $b[$o + 32]; $flags = $b[$o + 25]
                $ext = [BitConverter]::ToUInt32($b, $o + 2); $dl = [BitConverter]::ToUInt32($b, $o + 10)
                if (-not ($nl -eq 1 -and $b[$o + 33] -le 1)) {
                    $name = [Text.Encoding]::ASCII.GetString($b, $o + 33, $nl) -replace ';\d+$', ''
                    $full = if ($path) { "$path/$name" } else { $name }
                    if ($flags -band 2) { $dirs.Add(('{0} (flags 0x{1:X2})' -f $full, $flags)); $queue.Enqueue(@($ext, $dl, $full)) }
                    else { $found[$full] = [pscustomobject]@{ Size = [long]$dl; Extent = [long]$ext; Flags = $flags } }
                }
                $o += $len
            }
        }
    }
    "INFO  Directories: $($dirs -join ', ')"

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $fileProblems = New-Object System.Collections.Generic.List[string]
        foreach ($p in ($found.Keys | Sort-Object)) {
            $f = $found[$p]; $e = $expectedFiles[$p]
            if (-not $e) { $fileProblems.Add("$p not in inventory"); continue }
            [void]$sha.Initialize(); $left = $f.Size; $l = $f.Extent
            while ($left -gt 0) { $u = ReadBlock $l; $n = [int][math]::Min($BLK, $left); [void]$sha.TransformBlock($u, 0, $n, $null, 0); $left -= $n; $l++ }
            [void]$sha.TransformFinalBlock((New-Object byte[] 0), 0, 0)
            $h = [BitConverter]::ToString($sha.Hash).Replace('-', '')
            if ($f.Size -ne $e.Size) { $fileProblems.Add("$p size $($f.Size) != $($e.Size)") }
            if ($f.Extent -ne $e.Extent) { $fileProblems.Add("$p extent $($f.Extent) != $($e.Extent)") }
            if ($h -ne $e.Sha) { $fileProblems.Add("$p SHA-256 mismatch") }
            if ($f.Flags -ne 0) { $fileProblems.Add(('{0} flags 0x{1:X2}' -f $p, $f.Flags)) }
        }
        foreach ($p in $expectedFiles.Keys) { if (-not $found.ContainsKey($p)) { $fileProblems.Add("$p in inventory but not on disc") } }
        $total = ($found.Values | Measure-Object Size -Sum).Sum
        Report 'File listing vs inventory' ($fileProblems.Count -eq 0 -and $found.Count -eq $expectedFiles.Count) ("{0} files on disc, {1} in inventory, {2:N0} bytes, {3} problems{4}" -f $found.Count, $expectedFiles.Count, $total, $fileProblems.Count, $(if ($fileProblems.Count) { ': ' + (($fileProblems | Select-Object -First 5) -join '; ') } else { '' }))
    } finally { $sha.Dispose() }
} finally { $fs.Dispose() }

if ($script:failures) { "RESULT: FAIL ($script:failures check(s) failed)"; exit 1 } else { 'RESULT: PASS (all checks)'; exit 0 }
