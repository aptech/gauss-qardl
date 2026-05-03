param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$packagePath = Join-Path $RepoRoot "package.json"
$srcDir = Join-Path $RepoRoot "src"

if (-not (Test-Path -LiteralPath $packagePath)) {
    throw "package.json not found at $packagePath"
}

$pkg = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
$srcEntries = @($pkg.src)

if ($srcEntries.Count -eq 0) {
    throw "package.json src array is empty"
}

$duplicates = $srcEntries | Group-Object | Where-Object { $_.Count -gt 1 }
if ($duplicates.Count -gt 0) {
    $names = ($duplicates | ForEach-Object { $_.Name }) -join ", "
    throw "package.json src has duplicate entries: $names"
}

if ($srcEntries[0] -ne "qardl.sdf") {
    throw "package.json src must list qardl.sdf first so structures are registered before procedures"
}

$missing = @()
foreach ($entry in $srcEntries) {
    $path = Join-Path $srcDir $entry
    if (-not (Test-Path -LiteralPath $path)) {
        $missing += $entry
    }
}

if ($missing.Count -gt 0) {
    throw "package.json src references missing files: $($missing -join ', ')"
}

$actualSrc = Get-ChildItem -LiteralPath $srcDir -File |
    Where-Object { $_.Extension -in ".src", ".sdf" } |
    ForEach-Object { $_.Name }

$unlisted = $actualSrc | Where-Object { $srcEntries -notcontains $_ }
if ($unlisted.Count -gt 0) {
    throw "src files not listed in package.json: $($unlisted -join ', ')"
}

Write-Host "verify_package_manifest.ps1: PASS"
