param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe"
)

$examplesDir = Join-Path $RepoRoot "examples"

$examples = @(
    "demo.e",
    "qardlestimation.e",
    "qardl_est_tests.e",
    "rolling_qardl.e",
    "sp500.e"
)

foreach ($example in $examples) {
    $path = Join-Path $examplesDir $example
    & $GaussExe -nb -b -x $path
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "run_examples_smoke.ps1: PASS"
