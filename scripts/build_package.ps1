param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$OutputDir = "",
    [switch]$Force,
    [switch]$NoTests
)

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = $RepoRoot
}

$packagePath = Join-Path $RepoRoot "package.json"
if (-not (Test-Path -LiteralPath $packagePath)) {
    throw "package.json not found at $packagePath"
}

$pkg = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
$packageName = [string]$pkg.name
$version = [string]$pkg.version

if ([string]::IsNullOrWhiteSpace($packageName) -or [string]::IsNullOrWhiteSpace($version)) {
    throw "package.json must define name and version"
}

if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$artifactPath = Join-Path $OutputDir "$packageName $version.zip"
if ((Test-Path -LiteralPath $artifactPath) -and -not $Force) {
    throw "release artifact already exists at $artifactPath. Re-run with -Force to replace it."
}

$stageRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_pkg_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $stageRoot | Out-Null

try {
    $rootFiles = @(
        "package.json",
        "README.md",
        "CHANGELOG.md",
        "CITATION.cff",
        "CITATION.md",
        "LICENSE",
        "RELEASE_CHECKLIST.md",
        "llms.txt"
    )

    foreach ($file in $rootFiles) {
        $srcPath = Join-Path $RepoRoot $file
        if (Test-Path -LiteralPath $srcPath) {
            Copy-Item -LiteralPath $srcPath -Destination (Join-Path $stageRoot $file)
        }
    }

    $dirs = @("src", "docs", "examples", "doc", "images", "scripts")
    if (-not $NoTests) {
        $dirs += "tests"
    }

    foreach ($dir in $dirs) {
        $srcPath = Join-Path $RepoRoot $dir
        if (Test-Path -LiteralPath $srcPath) {
            Copy-Item -LiteralPath $srcPath -Destination (Join-Path $stageRoot $dir) -Recurse
        }
    }

    $generatedWrappers = Join-Path $stageRoot "tests"
    if (Test-Path -LiteralPath $generatedWrappers) {
        Get-ChildItem -LiteralPath $generatedWrappers -Recurse -File -Filter "__run_*.e" |
            Remove-Item -Force
    }

    Get-ChildItem -LiteralPath $stageRoot -Recurse -File -Filter "*.zip" |
        Remove-Item -Force

    $tmpArtifact = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_artifact_" + [System.Guid]::NewGuid().ToString("N") + ".zip")
    Compress-Archive -Path (Join-Path $stageRoot "*") -DestinationPath $tmpArtifact -Force
    [System.IO.File]::Copy($tmpArtifact, $artifactPath, $true)
    Remove-Item -LiteralPath $tmpArtifact -Force -ErrorAction SilentlyContinue
} finally {
    if (Test-Path -LiteralPath $stageRoot) {
        Remove-Item -LiteralPath $stageRoot -Recurse -Force
    }
}

& (Join-Path $PSScriptRoot "verify_release_artifact.ps1") -RepoRoot $RepoRoot -ArtifactPath $artifactPath
if (-not $?) {
    exit 1
}

Write-Host "build_package.ps1: wrote $artifactPath"
