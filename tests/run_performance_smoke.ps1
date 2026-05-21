param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe",
    [double]$MaxNewModelSeconds = 90,
    [double]$MaxValidationSeconds = 120,
    [double]$MaxLargeWorkloadSeconds = 90
)

$testsDir = Join-Path $RepoRoot "tests"
$srcDir = Join-Path $RepoRoot "src"

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

function Invoke-GaussWorkload {
    param(
        [string]$Name,
        [string]$TestFile,
        [double]$MaxSeconds
    )

    $wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_perf_" + [System.Guid]::NewGuid().ToString("N") + ".e")
    $gaussTestsDir = $testsDir -replace "\\", "/"
    $gaussSrcDir = $srcDir -replace "\\", "/"

    Set-Content -Path $wrapper -Value @(
        "new;",
        "chdir `"$gaussSrcDir`";",
        "run `"$gaussTestsDir/$TestFile`";"
    )

    try {
        $watch = [System.Diagnostics.Stopwatch]::StartNew()
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = $GaussExe
        $psi.Arguments = "-nb -b -x `"$wrapper`""
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()
        $watch.Stop()

        $output = $stdout + $stderr
        $output
        if ($proc.ExitCode -ne 0 -or ($output -match "Program execute failed|error G[0-9]+|Program compile failed")) {
            exit 1
        }

        $elapsed = $watch.Elapsed.TotalSeconds
        Write-Host ("{0}: {1:N3} seconds (target <= {2:N3})" -f $Name, $elapsed, $MaxSeconds)
        if ($elapsed -gt $MaxSeconds) {
            Write-Error ("{0}: performance smoke target exceeded" -f $Name)
            exit 1
        }
    } finally {
        Remove-Item -LiteralPath $wrapper -ErrorAction SilentlyContinue
    }
}

Invoke-GaussWorkload -Name "large lag-grid/bootstrap workload" `
                     -TestFile "performance_large_workloads.e" `
                     -MaxSeconds $MaxLargeWorkloadSeconds

Write-Host "run_performance_smoke.ps1: PASS"
