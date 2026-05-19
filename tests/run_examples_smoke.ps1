param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe"
)

$examplesDir = Join-Path $RepoRoot "examples"

$examples = @(
    "demo.e",
    "ardl_example.e",
    "qardlestimation.e",
    "qardl_est_tests.e",
    "rolling_qardl.e",
    "sp500.e",
    "rolling_forecast_example.e",
    "nardl_example.e",
    "csardl_example.e",
    "replicate_cho_dividend_policy.e",
    "wald_tests_sim.e"
)

function Invoke-GaussBatch {
    param(
        [string]$Exe,
        [string[]]$Arguments
    )

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $Exe
    $psi.Arguments = (($Arguments | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_ -replace '"', '\"') + '"'
        } else {
            $_
        }
    }) -join " ")
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()

    [pscustomobject]@{
        ExitCode = $proc.ExitCode
        Output = ($stdout + $stderr)
    }
}

function Remove-TemporaryFile {
    param([string]$Path)

    for ($i = 0; $i -lt 10; $i++) {
        try {
            Remove-Item -LiteralPath $Path -ErrorAction Stop
            return
        } catch {
            Start-Sleep -Milliseconds 100
        }
    }
}

foreach ($example in $examples) {
    $wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_example_" + [System.Guid]::NewGuid().ToString("N") + ".e")
    $gaussExamplesDir = $examplesDir -replace "\\", "/"
    Set-Content -Path $wrapper -Value @(
        "new;",
        "chdir `"$gaussExamplesDir`";",
        "run $example;"
    )

    try {
        $result = Invoke-GaussBatch -Exe $GaussExe -Arguments @("-nb", "-b", "-x", $wrapper)
        $output = $result.Output
        $output
        if ($result.ExitCode -ne 0 -or ($output -match "Program execute failed|error G[0-9]+|Program compile failed")) {
            exit 1
        }
    } finally {
        Remove-TemporaryFile -Path $wrapper
    }
}

Write-Host "run_examples_smoke.ps1: PASS"
