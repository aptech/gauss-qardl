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

$commandRefPath = Join-Path $RepoRoot "docs\COMMAND_REFERENCE.md"
if (-not (Test-Path -LiteralPath $commandRefPath)) {
    throw "docs/COMMAND_REFERENCE.md not found at $commandRefPath"
}

$commandRef = Get-Content -LiteralPath $commandRefPath -Raw
$docCommandNames = New-Object System.Collections.Generic.List[string]
$linkedDocPaths = New-Object System.Collections.Generic.List[string]

$linkMatches = [regex]::Matches($commandRef, '\[([A-Za-z_][A-Za-z0-9_]*)\]\(command-reference/([^)]+\.md)\)')
foreach ($match in $linkMatches) {
    $docCommandNames.Add($match.Groups[1].Value)
    $linkedDocPaths.Add($match.Groups[2].Value)
}

$slashMatches = [regex]::Matches($commandRef, '(?m)^\s*-\s+([A-Za-z_][A-Za-z0-9_]*)\s*/\s*([A-Za-z_][A-Za-z0-9_]*)\s*$')
foreach ($match in $slashMatches) {
    $docCommandNames.Add($match.Groups[1].Value)
    $docCommandNames.Add($match.Groups[2].Value)
}

$docCommands = @($docCommandNames | Sort-Object -Unique)
if ($docCommands.Count -eq 0) {
    throw "docs/COMMAND_REFERENCE.md does not list any public commands"
}

$missingDocPages = @()
foreach ($relPath in ($linkedDocPaths | Sort-Object -Unique)) {
    $fullPath = Join-Path (Join-Path $RepoRoot "docs\command-reference") $relPath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $missingDocPages += $relPath
    }
}

if ($missingDocPages.Count -gt 0) {
    throw "docs/COMMAND_REFERENCE.md references missing command pages: $($missingDocPages -join ', ')"
}

$sourceText = ""
foreach ($entry in $srcEntries) {
    if ([System.IO.Path]::GetExtension($entry) -ne ".src") {
        continue
    }

    $sourceText += "`n"
    $sourceText += Get-Content -LiteralPath (Join-Path $srcDir $entry) -Raw
}

$procMatches = [regex]::Matches($sourceText, '(?m)^\s*proc(?:\s*\([^)]*\))?\s*(?:=\s*)?([A-Za-z_][A-Za-z0-9_]*)\s*\(')
$exportedProcs = @($procMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
$missingDocumentedProcs = $docCommands | Where-Object { $exportedProcs -notcontains $_ }

if ($missingDocumentedProcs.Count -gt 0) {
    throw "docs/COMMAND_REFERENCE.md documents procedures not found in package.json source files: $($missingDocumentedProcs -join ', ')"
}

Write-Host "verify_package_manifest.ps1: PASS"
