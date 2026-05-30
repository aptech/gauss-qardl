param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe",
    [string]$RscriptExe = "Rscript",
    [double]$Tolerance = 1e-6,
    [double]$RelativeTolerance = 1e-6,
    [double]$MaxGaussSeconds = 30,
    [double]$MaxRSeconds = 120,
    [double]$MaxGaussToRRatio = 0,
    [string]$ComparisonMarkdown = (Join-Path $RepoRoot "docs\validation\R_PACKAGE_COMPARISON.md"),
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

$perfPath = Join-Path $actualDir "performance_summary.csv"
Set-Content -Path $perfPath -Value "engine,seconds"
Add-Content -Path $perfPath -Value ("GAUSS,{0:N6}" -f $gaussWatch.Elapsed.TotalSeconds)
Add-Content -Path $perfPath -Value ("R ardl.nardl,{0:N6}" -f $rWatch.Elapsed.TotalSeconds)

$comparisonCsv = Join-Path $expectedDir "comparison_summary.csv"
if (Test-Path -LiteralPath $comparisonCsv) {
    $rows = Import-Csv -LiteralPath $comparisonCsv
    $ardlGauss = @(Import-Csv -LiteralPath (Join-Path $actualDir "ardl_bigbt.csv") | ForEach-Object { [double]$_.value })
    $ardlR = @(Import-Csv -LiteralPath (Join-Path $expectedDir "ardl_bigbt.csv") | ForEach-Object { [double]$_.value })
    $nardlGauss = @(Import-Csv -LiteralPath (Join-Path $actualDir "nardl_bigbt.csv") | ForEach-Object { [double]$_.value })
    $nardlR = @(Import-Csv -LiteralPath (Join-Path $expectedDir "nardl_bigbt.csv") | ForEach-Object { [double]$_.value })
    $ardlUecmGauss = @(Import-Csv -LiteralPath (Join-Path $actualDir "ardl_uecm_bt.csv") | ForEach-Object { [double]$_.value })
    $ardlUecmR = @(Import-Csv -LiteralPath (Join-Path $expectedDir "ardl_uecm_bt.csv") | ForEach-Object { [double]$_.value })
    $nardlUecmGauss = @(Import-Csv -LiteralPath (Join-Path $actualDir "nardl_uecm_bt.csv") | ForEach-Object { [double]$_.value })
    $nardlUecmR = @(Import-Csv -LiteralPath (Join-Path $expectedDir "nardl_uecm_bt.csv") | ForEach-Object { [double]$_.value })
    $nardlRecmGauss = @(Import-Csv -LiteralPath (Join-Path $actualDir "nardl_recm_bt.csv") | ForEach-Object { [double]$_.value })
    $nardlRecmR = @(Import-Csv -LiteralPath (Join-Path $expectedDir "nardl_recm_bt.csv") | ForEach-Object { [double]$_.value })
    $coefRows = @(
        [pscustomobject]@{ Model = "ARDL"; Parameter = "x1"; Gauss = $ardlGauss[0]; R = $ardlR[0] },
        [pscustomobject]@{ Model = "ARDL"; Parameter = "x2"; Gauss = $ardlGauss[1]; R = $ardlR[1] },
        [pscustomobject]@{ Model = "NARDL"; Parameter = "beta_pos_x1"; Gauss = $nardlGauss[0]; R = $nardlR[0] },
        [pscustomobject]@{ Model = "NARDL"; Parameter = "beta_neg_x1"; Gauss = $nardlGauss[1]; R = $nardlR[1] },
        [pscustomobject]@{ Model = "NARDL"; Parameter = "beta_control_x2"; Gauss = $nardlGauss[2]; R = $nardlR[2] }
    )
    $uecmCoefRows = @()
    $ardlUecmNames = @("(Intercept)", "y_1", "x1_1", "x2_1", "D.y_1", "D.y_2", "D.x1", "D.x2", "D.x1_1", "D.x1_2", "D.x2_1", "D.x2_2")
    for ($i = 0; $i -lt $ardlUecmNames.Count; $i++) {
        $uecmCoefRows += [pscustomobject]@{ Model = "ARDL UECM"; Parameter = $ardlUecmNames[$i]; Gauss = $ardlUecmGauss[$i]; R = $ardlUecmR[$i] }
    }
    $nardlUecmNames = @("(Intercept)", "y_1", "x1_pos_1", "x1_neg_1", "x2_1", "D.y_1", "D.y_2", "D.x1_pos_1", "D.x1_pos_2", "D.x1_neg_1", "D.x1_neg_2", "D.x2_1")
    for ($i = 0; $i -lt $nardlUecmNames.Count; $i++) {
        $uecmCoefRows += [pscustomobject]@{ Model = "NARDL UECM"; Parameter = $nardlUecmNames[$i]; Gauss = $nardlUecmGauss[$i]; R = $nardlUecmR[$i] }
    }
    $recmCoefRows = @()
    $nardlRecmNames = @("(Intercept)", "ec_lag", "D.y_1", "D.x1_pos", "D.x1_pos_1", "D.x1_neg", "D.x1_neg_1", "D.x2")
    for ($i = 0; $i -lt $nardlRecmNames.Count; $i++) {
        $recmCoefRows += [pscustomobject]@{ Model = "NARDL restricted ECM"; Parameter = $nardlRecmNames[$i]; Gauss = $nardlRecmGauss[$i]; R = $nardlRecmR[$i] }
    }
    $markdown = @()
    $markdown += "# ARDL/NARDL R Package Comparison"
    $markdown += ""
    $markdown += 'Generated by `tests/run_r_package_validation.ps1`.'
    $markdown += ""
    $markdown += "R ``ardl.nardl`` ECM fits are unrestricted ECMs. The UECM rows compare those fits to fixed-order GAUSS validation design matrices. The restricted ECM rows validate the public GAUSS ``nardlECM`` two-step estimator against an equivalent R reconstruction. Rows marked ``Required = FALSE`` are retained diagnostics for known convention differences rather than required parity checks."
    $markdown += ""
    $markdown += "## Long-Run Coefficient Detail"
    $markdown += ""
    $markdown += "| Model | Parameter | GAUSS | R ``ardl.nardl`` | Abs diff |"
    $markdown += "| --- | --- | ---: | ---: | ---: |"
    foreach ($row in $coefRows) {
        $markdown += ("| {0} | {1} | {2} | {3} | {4} |" -f `
            $row.Model,
            $row.Parameter,
            $row.Gauss.ToString("G10"),
            $row.R.ToString("G10"),
            ([math]::Abs($row.Gauss - $row.R)).ToString("G10"))
    }
    $markdown += ""
    $markdown += "## Restricted ECM Coefficient Detail"
    $markdown += ""
    $markdown += "| Model | Parameter | GAUSS public output | R reconstruction | Abs diff |"
    $markdown += "| --- | --- | ---: | ---: | ---: |"
    foreach ($row in $recmCoefRows) {
        $markdown += ("| {0} | {1} | {2} | {3} | {4} |" -f `
            $row.Model,
            $row.Parameter,
            $row.Gauss.ToString("G10"),
            $row.R.ToString("G10"),
            ([math]::Abs($row.Gauss - $row.R)).ToString("G10"))
    }
    $markdown += ""
    $markdown += "## UECM Coefficient Detail"
    $markdown += ""
    $markdown += "| Model | Parameter | GAUSS validation design | R ``ardl.nardl`` | Abs diff |"
    $markdown += "| --- | --- | ---: | ---: | ---: |"
    foreach ($row in $uecmCoefRows) {
        $markdown += ("| {0} | {1} | {2} | {3} | {4} |" -f `
            $row.Model,
            $row.Parameter,
            $row.Gauss.ToString("G10"),
            $row.R.ToString("G10"),
            ([math]::Abs($row.Gauss - $row.R)).ToString("G10"))
    }
    $markdown += ""
    $markdown += "## Output Comparison"
    $markdown += ""
    $markdown += "| Check | Required | GAUSS n | R n | Compared n | Length match | GAUSS first | R first | Max abs diff | Max rel diff | Pass |"
    $markdown += "| --- | --- | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | --- |"
    foreach ($row in $rows) {
        $markdown += ("| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} | {8} | {9} | {10} |" -f `
            $row.check,
            $row.required,
            $row.gauss_n,
            $row.r_n,
            $row.compared_n,
            $row.length_match,
            ([double]$row.gauss_first).ToString("G8"),
            ([double]$row.r_first).ToString("G8"),
            ([double]$row.max_abs_diff).ToString("G8"),
            ([double]$row.max_rel_diff).ToString("G8"),
            $row.pass)
    }
    $markdown += ""
    $markdown += "## Computation Time"
    $markdown += ""
    $markdown += "| Engine | Seconds |"
    $markdown += "| --- | ---: |"
    $markdown += ("| GAUSS export | {0:N6} |" -f $gaussWatch.Elapsed.TotalSeconds)
    $markdown += ("| R ``ardl.nardl`` reference | {0:N6} |" -f $rWatch.Elapsed.TotalSeconds)

    $comparisonDir = Split-Path -Parent $ComparisonMarkdown
    if (-not (Test-Path -LiteralPath $comparisonDir)) {
        New-Item -ItemType Directory -Path $comparisonDir -Force | Out-Null
    }
    Set-Content -Path $ComparisonMarkdown -Value $markdown
    Write-Host "Comparison table written to $ComparisonMarkdown"
}

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

Write-Host ("run_r_package_validation.ps1: PASS. GAUSS {0:N3}s; R {1:N3}s" -f $gaussWatch.Elapsed.TotalSeconds, $rWatch.Elapsed.TotalSeconds)
