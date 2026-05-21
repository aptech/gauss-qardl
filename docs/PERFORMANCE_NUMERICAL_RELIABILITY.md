# Performance And Numerical Reliability

This note documents the current performance and numerical-safety policy for
the ARDL-family library.

## Performance Smoke Targets

The source tree includes a lightweight timing gate:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_performance_smoke.ps1
```

The default targets are intentionally generous so the check catches large
regressions without making local development brittle:

| Benchmark group | Default target |
| --- | ---: |
| New model benchmarks | 90 seconds |
| Validation benchmarks | 120 seconds |

Targets can be overridden from PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_performance_smoke.ps1 `
    -MaxNewModelSeconds 60 `
    -MaxValidationSeconds 90
```

These are smoke targets, not formal microbenchmarks. They should be tightened
only after repeated clean runs on the intended release machine.

## Current Optimization Policy

The package currently prioritizes validated numerical output over aggressive
optimization. The following optimization items remain open:

- cache repeated design-matrix construction in grid-search workflows
- reduce duplicated quantile fits in bootstrap workflows
- add larger workload timing profiles for ARDL, QARDL, NARDL, and CS-ARDL

Performance changes should be paired with deterministic output checks to ensure
validated coefficients, diagnostics, forecasts, and interval outputs do not
move.

## Rank And Conditioning Policy

Shared matrix safety helpers enforce the current policy:

| Context | Policy |
| --- | --- |
| Estimation design matrix | fail if observations are insufficient or columns are rank deficient |
| Direct moment-matrix inversion | fail if singular or too ill-conditioned to invert safely |
| Wald covariance inversion | use pseudoinverse with rank-adjusted degrees of freedom for rank-deficient or ill-conditioned covariance matrices |
| Mild ill-conditioning | print a warning and continue where the operation remains numerically safe |

This means estimation paths prefer clear failure over silently estimating
rank-deficient models. Wald-style diagnostics may continue with a pseudoinverse
because the effective chi-square degrees of freedom can be adjusted to the
restriction covariance rank.

## Reliability Tests

The source test suite now includes:

- invalid-input tests for rank-deficient ARDL designs
- invalid-input tests for too-small ARDL samples
- numerical helper tests for condition-number and Wald pseudoinverse behavior
- existing CS-ARDL invalid panel-layout tests

Remaining numerical reliability TODOs:

- broaden collinearity tests across NARDL and CS-ARDL
- add constant-regressor and singular-covariance tests by model family
- document candidate-lag skip versus failure behavior in every lag-selection
  command reference page
- add performance profiles for larger lag grids and bootstrap workloads
