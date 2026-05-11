param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe"
)

$testsDir = Join-Path $RepoRoot "tests"
$srcDir = Join-Path $RepoRoot "src"
$benchmark = "benchmark_nardl_csardl.e"

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

$wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_bench_" + [System.Guid]::NewGuid().ToString("N") + ".e")
$gaussTestsDir = $testsDir -replace "\\", "/"
$gaussSrcDir = $srcDir -replace "\\", "/"
Set-Content -Path $wrapper -Value @(
    "new;",
    "chdir `"$gaussSrcDir`";",
    "run `"$gaussTestsDir/$benchmark`";"
)

$watch = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $result = Invoke-GaussBatch -Exe $GaussExe -Arguments @("-nb", "-b", "-x", $wrapper)
    $watch.Stop()
    $output = $result.Output
    $output
    if ($result.ExitCode -ne 0 -or ($output -match "Program execute failed|error G[0-9]+|Program compile failed")) {
        exit 1
    }
} finally {
    if ($watch.IsRunning) {
        $watch.Stop()
    }
    Remove-TemporaryFile -Path $wrapper
}

Write-Host ("run_new_model_benchmarks.ps1: PASS in {0:N3} seconds" -f $watch.Elapsed.TotalSeconds)
