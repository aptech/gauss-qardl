param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GaussExe = "C:\gauss26\tgauss.exe"
)

$testsDir = Join-Path $RepoRoot "tests"

$cases = @(
    @{
        Name = "ardl_rank_deficient"
        Script = "invalid_input_cases/ardl_rank_deficient.e"
        Expected = "ardl: levels design matrix is rank deficient"
    },
    @{
        Name = "ardl_tiny_sample"
        Script = "invalid_input_cases/ardl_tiny_sample.e"
        Expected = "ardl: not enough observations for the requested lag orders"
    },
    @{
        Name = "csardl_unbalanced_diagnostics"
        Script = "invalid_input_cases/csardl_unbalanced_diagnostics.e"
        Expected = "csardlDiagnostics: panel must be balanced and stacked by unit"
    },
    @{
        Name = "csardl_unstacked"
        Script = "invalid_input_cases/csardl_unstacked.e"
        Expected = "csardl: panel must be stacked by unit with equal-length blocks"
    },
    @{
        Name = "csardl_formula_unbalanced_diagnostics"
        Script = "invalid_input_cases/csardl_formula_unbalanced_diagnostics.e"
        Expected = "csardlDiagnostics: panel must be balanced and stacked by unit"
    }
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

foreach ($case in $cases) {
    $scriptPath = Join-Path $testsDir $case.Script
    $wrapper = Join-Path ([System.IO.Path]::GetTempPath()) ("qardl_invalid_" + [System.Guid]::NewGuid().ToString("N") + ".e")
    $gaussRepoDir = $RepoRoot -replace "\\", "/"
    $gaussScript = $scriptPath -replace "\\", "/"

    Set-Content -Path $wrapper -Value @(
        "new;",
        "chdir `"$gaussRepoDir`";",
        "run `"$gaussScript`";"
    )

    try {
        $result = Invoke-GaussBatch -Exe $GaussExe -Arguments @("-nb", "-b", "-x", $wrapper)
        $output = $result.Output
        if ($output -notmatch [regex]::Escape($case.Expected)) {
            $output
            Write-Error ("{0}: expected error message not found: {1}" -f $case.Name, $case.Expected)
            exit 1
        }
        Write-Host ("{0}: PASS" -f $case.Name)
    } finally {
        Remove-TemporaryFile -Path $wrapper
    }
}

Write-Host "run_invalid_input_tests.ps1: PASS"
