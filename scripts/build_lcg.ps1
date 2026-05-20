param(
    [string]$PackageRoot,
    [string]$PackageName = ""
)

if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    throw "PackageRoot is required"
}

$packagePath = Join-Path $PackageRoot "package.json"
if (-not (Test-Path -LiteralPath $packagePath)) {
    throw "package.json not found at $packagePath"
}

$pkg = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($PackageName)) {
    $PackageName = [string]$pkg.name
}

if ([string]::IsNullOrWhiteSpace($PackageName)) {
    throw "package name is empty"
}

$libDir = Join-Path $PackageRoot "lib"
if (-not (Test-Path -LiteralPath $libDir)) {
    New-Item -ItemType Directory -Path $libDir | Out-Null
}

$catalogPath = Join-Path $libDir "$PackageName.lcg"
$catalog = New-Object System.Collections.Generic.List[string]

$catalog.Add("/*")
$catalog.Add("** Package: $PackageName")
$catalog.Add("** Version: $($pkg.version)")
$catalog.Add("** Author: $($pkg.author)")
$catalog.Add("** Description: $($pkg.description)")
$catalog.Add("*/")
$catalog.Add("")

foreach ($entry in @($pkg.src)) {
    $srcPath = Join-Path (Join-Path $PackageRoot "src") $entry
    if (-not (Test-Path -LiteralPath $srcPath)) {
        throw "package source file listed in package.json was not found: $srcPath"
    }

    $gaussPath = ((Resolve-Path -LiteralPath $srcPath).Path -replace "\\", "/").ToLowerInvariant()
    $catalog.Add($gaussPath)

    $lines = Get-Content -LiteralPath $srcPath
    for ($ii = 0; $ii -lt $lines.Count; $ii++) {
        $lineNo = $ii + 1
        $line = $lines[$ii]

        if ($line -match '^\s*struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{') {
            $catalog.Add(("    {0,-34} : definition : {1}" -f ("struct " + $matches[1]), $lineNo))
            continue
        }

        if ($line -match '^\s*proc(?:\s*\(([^)]*)\))?\s*(?:=\s*)?([A-Za-z_][A-Za-z0-9_]*)\s*\(') {
            $procName = $matches[2]
            $typedSuffix = ""
            if ($matches[1] -match '^\s*struct\b') {
                $typedSuffix = " : typed_returns"
            }
            $keywordSuffix = ""
            $procCallStart = $line.IndexOf($procName + "(")
            if ($procCallStart -ge 0) {
                $argPart = $line.Substring($procCallStart + $procName.Length)
                if ($argPart -match '=') {
                    $keywordSuffix = " : keywords"
                }
            }
            $catalog.Add(("    {0,-34} : proc : {1}{2}{3}" -f $procName, $lineNo, $typedSuffix, $keywordSuffix))
        }
    }

    $catalog.Add("")
}

Set-Content -LiteralPath $catalogPath -Value $catalog -Encoding ASCII
Write-Host "build_lcg.ps1: wrote $catalogPath"
