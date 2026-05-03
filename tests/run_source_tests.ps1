param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe"
)

$testsDir = Join-Path $RepoRoot "tests"
$escapedTestsDir = ($testsDir -replace "\\", "\\")

& powershell -ExecutionPolicy Bypass -File (Join-Path $testsDir "verify_package_manifest.ps1") -RepoRoot $RepoRoot
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$gaussTests = @(
    "smoke_public_api.e",
    "smoke_workflow_api.e",
    "smoke_export_api.e"
)

foreach ($test in $gaussTests) {
    & $GaussExe -nb -b -x -e "d=`"`"$escapedTestsDir`"`"; chdir ^d; run $test;"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "run_source_tests.ps1: PASS"
