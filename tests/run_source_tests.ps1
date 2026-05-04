param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe"
)

$testsDir = Join-Path $RepoRoot "tests"

& powershell -ExecutionPolicy Bypass -File (Join-Path $testsDir "verify_package_manifest.ps1") -RepoRoot $RepoRoot
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$gaussTests = @(
    "smoke_public_api.e",
    "statistical_benchmark.e",
    "smoke_workflow_api.e",
    "smoke_export_api.e"
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

foreach ($test in $gaussTests) {
    $wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_" + [System.Guid]::NewGuid().ToString("N") + ".e")
    $gaussTestsDir = $testsDir -replace "\\", "/"
    Set-Content -Path $wrapper -Value @(
        "new;",
        "chdir `"$gaussTestsDir`";",
        "run $test;"
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

Write-Host "run_source_tests.ps1: PASS"
