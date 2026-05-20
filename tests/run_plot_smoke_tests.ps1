param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe"
)

if ($env:QARDL_RUN_PLOT_TESTS -ne "1") {
    Write-Host "run_plot_smoke_tests.ps1: SKIP (set QARDL_RUN_PLOT_TESTS=1 to exercise GAUSS plot calls)"
    exit 0
}

$testsDir = Join-Path $RepoRoot "tests"
$srcDir = Join-Path $RepoRoot "src"
$wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_plot_" + [System.Guid]::NewGuid().ToString("N") + ".e")
$gaussTestsDir = $testsDir -replace "\\", "/"
$gaussSrcDir = $srcDir -replace "\\", "/"

Set-Content -Path $wrapper -Value @(
    "new;",
    "chdir `"$gaussSrcDir`";",
    "run `"$gaussTestsDir/smoke_plot_api.e`";"
)

try {
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

    $output = $stdout + $stderr
    $output

    if ($proc.ExitCode -ne 0 -or ($output -match "Program execute failed|error G[0-9]+|Program compile failed")) {
        exit 1
    }
} finally {
    Remove-Item -LiteralPath $wrapper -ErrorAction SilentlyContinue
}

Write-Host "run_plot_smoke_tests.ps1: PASS"
