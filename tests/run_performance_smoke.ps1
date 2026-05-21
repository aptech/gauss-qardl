param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe",
    [double]$MaxNewModelSeconds = 90,
    [double]$MaxValidationSeconds = 120
)

$testsDir = Join-Path $RepoRoot "tests"

function Invoke-TimedScript {
    param(
        [string]$Name,
        [string]$Script,
        [double]$MaxSeconds
    )

    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    & powershell -ExecutionPolicy Bypass -File $Script -RepoRoot $RepoRoot -GaussExe $GaussExe
    $exitCode = $LASTEXITCODE
    $watch.Stop()

    if ($exitCode -ne 0) {
        exit $exitCode
    }

    $elapsed = $watch.Elapsed.TotalSeconds
    Write-Host ("{0}: {1:N3} seconds (target <= {2:N3})" -f $Name, $elapsed, $MaxSeconds)

    if ($elapsed -gt $MaxSeconds) {
        Write-Error ("{0}: performance smoke target exceeded" -f $Name)
        exit 1
    }
}

Invoke-TimedScript -Name "new-model benchmarks" `
                   -Script (Join-Path $testsDir "run_new_model_benchmarks.ps1") `
                   -MaxSeconds $MaxNewModelSeconds

Invoke-TimedScript -Name "validation benchmarks" `
                   -Script (Join-Path $testsDir "run_validation_benchmarks.ps1") `
                   -MaxSeconds $MaxValidationSeconds

Write-Host "run_performance_smoke.ps1: PASS"
