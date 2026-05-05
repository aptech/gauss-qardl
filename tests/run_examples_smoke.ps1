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
    "sp500.e",
    "replicate_cho_dividend_policy.e"
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

foreach ($example in $examples) {
    $path = Join-Path $examplesDir $example
    $result = Invoke-GaussBatch -Exe $GaussExe -Arguments @("-nb", "-b", "-x", $path)
    $output = $result.Output
    $output
    if ($result.ExitCode -ne 0 -or ($output -match "Program execute failed|error G[0-9]+|Program compile failed")) {
        exit 1
    }
}

Write-Host "run_examples_smoke.ps1: PASS"
