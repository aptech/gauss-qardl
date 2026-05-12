param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe",
    [switch]$IncludePublished
)

$testsDir = Join-Path $RepoRoot "tests"
$srcDir = Join-Path $RepoRoot "src"
$manifestPath = Join-Path $testsDir "fixtures\fixture_manifest.csv"
$syntheticDir = Join-Path $testsDir "validation_cases\synthetic"
$publishedDir = Join-Path $testsDir "validation_cases\published"

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "fixture manifest not found at $manifestPath"
}

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

function Invoke-ValidationCases {
    param(
        [string]$CaseRoot,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $CaseRoot)) {
        Write-Host "$Label validation: no case directory found."
        return
    }

    $cases = Get-ChildItem -LiteralPath $CaseRoot -Filter "*.e" -File | Sort-Object Name
    if ($cases.Count -eq 0) {
        Write-Host "$Label validation: no active cases."
        return
    }

    foreach ($case in $cases) {
        $wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_validation_" + [System.Guid]::NewGuid().ToString("N") + ".e")
        $gaussSrcDir = $srcDir -replace "\\", "/"
        $gaussCase = $case.FullName -replace "\\", "/"
        Set-Content -Path $wrapper -Value @(
            "new;",
            "chdir `"$gaussSrcDir`";",
            "run `"$gaussCase`";"
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
}

$watch = [System.Diagnostics.Stopwatch]::StartNew()
$manifest = Import-Csv -LiteralPath $manifestPath
$activeSynthetic = @($manifest | Where-Object { $_.dataset_kind -eq "synthetic" -and $_.status -eq "active" })
$activePublished = @($manifest | Where-Object { $_.dataset_kind -eq "published" -and $_.status -like "active-published*" })
$pendingPublished = @($manifest | Where-Object { $_.dataset_kind -eq "published" -and $_.status -eq "pending-published" })

Write-Host ("Validation manifest: {0} active synthetic fixtures, {1} active published/reference fixtures, {2} pending published fixtures." -f $activeSynthetic.Count, $activePublished.Count, $pendingPublished.Count)
Invoke-ValidationCases -CaseRoot $syntheticDir -Label "Synthetic"

if ($IncludePublished) {
    Invoke-ValidationCases -CaseRoot $publishedDir -Label "Published-result"
} else {
    Write-Host "Published-result validation skipped by default; use -IncludePublished after active cases are added."
}

$watch.Stop()
Write-Host ("run_validation_benchmarks.ps1: PASS in {0:N3} seconds" -f $watch.Elapsed.TotalSeconds)
