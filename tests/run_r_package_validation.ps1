param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe",
    [string]$RscriptExe = "Rscript",
    [double]$Tolerance = 1e-6,
    [double]$RelativeTolerance = 1e-6,
    [double]$MaxGaussSeconds = 30,
    [double]$MaxRSeconds = 120,
    [double]$MaxGaussToRRatio = 0,
    [switch]$InstallMissingRPackage,
    [switch]$RequireRPackage
)

$testsDir = Join-Path $RepoRoot "tests"
$srcDir = Join-Path $RepoRoot "src"
$rPackageDir = Join-Path $testsDir "r_package"
$actualDir = Join-Path $rPackageDir "actual"
$expectedDir = Join-Path $rPackageDir "r_expected"
$gaussCase = Join-Path $rPackageDir "ardl_nardl_gauss_export.e"
$rCase = Join-Path $rPackageDir "ardl_nardl_reference.R"

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

function Test-RPackageAvailable {
    $check = & $RscriptExe -e "if (!requireNamespace('ardl.nardl', quietly = TRUE)) quit(status = 42)"
    if ($LASTEXITCODE -eq 42) {
        return $false
    }
    if ($LASTEXITCODE -ne 0) {
        throw "R package availability check failed. Output: $check"
    }
    return $true
}

if (-not (Get-Command $RscriptExe -ErrorAction SilentlyContinue)) {
    $msg = "Rscript was not found; skipping R-package validation."
    if ($RequireRPackage) {
        throw $msg
    }
    Write-Host $msg
    exit 0
}

if (-not (Test-RPackageAvailable)) {
    if ($InstallMissingRPackage) {
        & $RscriptExe -e "install.packages('ardl.nardl', repos = 'https://cloud.r-project.org')"
        if ($LASTEXITCODE -ne 0) {
            throw "Installing ardl.nardl failed."
        }
    } elseif ($RequireRPackage) {
        throw "R package ardl.nardl is not installed. Run with -InstallMissingRPackage or install it manually."
    } else {
        Write-Host "R package ardl.nardl is not installed; skipping R-package validation."
        exit 0
    }
}

foreach ($dir in @($actualDir, $expectedDir)) {
    if (Test-Path -LiteralPath $dir) {
        Remove-Item -LiteralPath $dir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_rpkg_" + [System.Guid]::NewGuid().ToString("N") + ".e")
$gaussRepoDir = $RepoRoot -replace "\\", "/"
$gaussSrcDir = $srcDir -replace "\\", "/"
$gaussCasePath = $gaussCase -replace "\\", "/"
Set-Content -Path $wrapper -Value @(
    "new;",
    "chdir `"$gaussSrcDir`";",
    "run `"$gaussCasePath`";"
)

$gaussWatch = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $result = Invoke-GaussBatch -Exe $GaussExe -Arguments @("-nb", "-b", "-x", $wrapper)
    $gaussWatch.Stop()
    $output = $result.Output
    $output
    if ($result.ExitCode -ne 0 -or ($output -match "Program execute failed|error G[0-9]+|Program compile failed")) {
        exit 1
    }
} finally {
    if ($gaussWatch.IsRunning) {
        $gaussWatch.Stop()
    }
    Remove-TemporaryFile -Path $wrapper
}

if ($gaussWatch.Elapsed.TotalSeconds -gt $MaxGaussSeconds) {
    throw ("GAUSS R-package export exceeded performance budget: {0:N3}s > {1:N3}s" -f $gaussWatch.Elapsed.TotalSeconds, $MaxGaussSeconds)
}

$rWatch = [System.Diagnostics.Stopwatch]::StartNew()
& $RscriptExe $rCase `
    --repo-root $RepoRoot `
    --actual-dir $actualDir `
    --expected-dir $expectedDir `
    --tolerance $Tolerance `
    --relative-tolerance $RelativeTolerance
$rExit = $LASTEXITCODE
$rWatch.Stop()

if ($rExit -ne 0) {
    exit $rExit
}

if ($rWatch.Elapsed.TotalSeconds -gt $MaxRSeconds) {
    throw ("R ardl.nardl validation exceeded performance budget: {0:N3}s > {1:N3}s" -f $rWatch.Elapsed.TotalSeconds, $MaxRSeconds)
}

if ($MaxGaussToRRatio -gt 0 -and $rWatch.Elapsed.TotalSeconds -gt 0) {
    $ratio = $gaussWatch.Elapsed.TotalSeconds / $rWatch.Elapsed.TotalSeconds
    if ($ratio -gt $MaxGaussToRRatio) {
        throw ("GAUSS/R runtime ratio exceeded budget: {0:N3} > {1:N3}" -f $ratio, $MaxGaussToRRatio)
    }
}

$perfPath = Join-Path $actualDir "performance_summary.csv"
Set-Content -Path $perfPath -Value "engine,seconds"
Add-Content -Path $perfPath -Value ("GAUSS,{0:N6}" -f $gaussWatch.Elapsed.TotalSeconds)
Add-Content -Path $perfPath -Value ("R ardl.nardl,{0:N6}" -f $rWatch.Elapsed.TotalSeconds)

Write-Host ("run_r_package_validation.ps1: PASS. GAUSS {0:N3}s; R {1:N3}s" -f $gaussWatch.Elapsed.TotalSeconds, $rWatch.Elapsed.TotalSeconds)
