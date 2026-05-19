# Bounds Testing Support

This note summarizes the current ARDL-family bounds-testing support and the
validation fixtures that protect it.

## Supported Public Bounds APIs

| Procedure | Scope | Deterministic cases | Critical values |
| --- | --- | --- | --- |
| `ardlbounds` | Compatibility wrapper | Case III only | Bundled asymptotic PSS F table for Case III |
| `ardlboundsCase` | ARDL bounds F and lagged-level t-statistic | Cases I-V | Bundled asymptotic PSS F table for `k <= 10` |
| `ardlboundsCaseCV` | Critical-value lookup or simulation wrapper | Cases I-V | Bundled asymptotic table when `reps = 0`; simulated values when `reps > 0` |
| `ardlboundsCaseSim` | ARDL bounds test with simulated critical values | Cases I-V | Simulated finite-sample F bounds |
| `ardlboundsCaseSimCV` | Simulated critical values only | Cases I-V | Simulated finite-sample F bounds |

The bundled table values are asymptotic Pesaran-Shin-Smith F-statistic bounds.
Rows are 10%, 5%, and 1%; columns are I(0) lower and I(1) upper. For `k > 10`,
use the simulation APIs.

## Model-Family Integration

| Model family | Current workflow |
| --- | --- |
| ARDL | `ardlFull` runs the compatibility Case III bounds test through `ardlbounds`. Users can call `ardlboundsCase` or `ardlboundsCaseSim` directly for Cases I-V. |
| QARDL | `qardlFull` reports the same compatibility ARDL Case III bounds statistic on the underlying levels data. Quantile-specific bounds variants remain outside the current public API. |
| NARDL | `nardl` reports a UECM bounds-style F-statistic over the lagged level terms. Case-specific PSS critical-value integration remains TODO. |
| CS-ARDL | No PSS bounds-test integration. Panel cointegration diagnostics remain TODO. |

## Active Validation

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1 -IncludePublished
```

Active fixtures include:

- `tests/validation_cases/synthetic/bounds_validation.e`
- `tests/validation_cases/published/ardl_bounds_pss.e`
- `tests/fixtures/expected/synthetic/diagnostics/ardl_bounds_cases_i_v.csv`
- `tests/fixtures/expected/synthetic/diagnostics/ardl_bounds_simcv_case3_k2_t80_reps100_seed12345.csv`
- `tests/fixtures/expected/published/ardl_bounds_pss_selected_cv.csv`

The synthetic validation case checks Cases I-V on the bundled `qardl_data`
fixture, verifies that `ardlbounds` remains a Case III compatibility wrapper,
and pins a fixed-seed simulation critical-value fixture. The published-reference
case checks selected PSS table values across Cases I-V.

## Remaining Gaps

- Add invalid-case negative tests once the test harness has a standard
  error-capture pattern for expected GAUSS errors.
- Decide whether `ardlFull` and `qardlFull` should expose deterministic-case
  controls rather than always using the compatibility Case III path.
- Add NARDL critical-value policy and documentation for asymmetric bounds-style
  tests.
- Add panel cointegration/bounds diagnostics only after the CS-ARDL diagnostic
  design is finalized.
