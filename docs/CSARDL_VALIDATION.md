# CS-ARDL Validation

This note records the current CS-ARDL validation status and panel-data
contract. The active checks are deterministic source-tree validation fixtures,
not exact published Chudik-Pesaran replications.

## Active Validation Cases

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1
```

The CS-ARDL validation coverage includes:

- `tests/validation_cases/synthetic/csardl_panel_validation.e`
- `tests/validation_cases/synthetic/expected_outputs.e`

Stored expected outputs live under:

- `tests/fixtures/expected/synthetic/panels/`
- `tests/fixtures/expected/synthetic/coefficients/`
- `tests/fixtures/expected/synthetic/diagnostics/`
- `tests/fixtures/expected/synthetic/forecasts/`

## Panel Layout

Matrix input is a balanced panel stacked by unit:

```gauss
[unit_id, y, x1, x2, ...]
```

The time index is implicit within each equal-length unit block. The current
implementation rejects missing values, noninteger implied panel lengths, and
panels that are not stacked in equal-length unit blocks.

Dataframe formula input uses:

```gauss
"y ~ x1 + x2"
```

The CS-ARDL formula workflow follows GAUSS panel-data conventions:

- the first string or category variable is the unit variable
- the first date variable is the time variable
- if no date variable exists, the first numeric variable is used as the time
  variable

Formula input is sorted by the inferred unit/time variables before the
estimator matrix is built. The validation case verifies that coefficient,
cross-sectional-average, and diagnostic outputs are invariant to input row
ordering when the same balanced panel is identified by unit/time variables.

## Cross-Sectional Averages And Lag Alignment

`csardl_panel_validation.e` uses a small hand-specified balanced panel with
known cross-sectional averages. It validates:

- cross-sectional averages of `[y, x1, x2]`
- the dependent-variable estimation vector for `p = 1`, `q = 1`,
  `cs_lags = 1`
- the full levels design matrix, including lagged dependent variables, lagged
  regressors, current cross-sectional averages, and lagged cross-sectional
  averages

These fixtures protect the panel-stacking and lag-alignment contract used by
`csardl`, `csardlECM`, `csardlDiagnostics`, prediction, and forecasting.

## Diagnostics

The validation case checks the optional diagnostic layer by:

- comparing pooled long-run coefficients with stored deterministic fixtures
- comparing mean-group long-run coefficients with stored deterministic
  fixtures
- recomputing mean-group coefficients and mean-group standard errors from the
  stored unit-level long-run coefficients
- recomputing the poolability Wald statistic from unit-specific long-run
  covariance matrices
- confirming formula/dataframe diagnostics match matrix diagnostics after
  sorting

The current poolability statistic is a Wald-style diagnostic convenience
measure. Its finite-sample distribution and exact published-reference behavior
remain TODO.

## Unsupported Cases

Unbalanced CS-ARDL panels are not supported in the current implementation. A
user should first align or balance the panel before calling `csardl`,
`csardlECM`, `csardlFull`, or `csardlDiagnostics`.

Explicit unit/time arguments are also not part of the public CS-ARDL formula
API. To choose identifiers, arrange and type the dataframe so the desired unit
column is the first string/category variable and the desired time column is the
first date variable, or first numeric variable if no date variable is present.

## Pending Published Validation

Exact Chudik-Pesaran style validation remains pending until a specific
redistributable Monte Carlo grid or empirical replication target is selected.
The pending work is to document the DGP, cross-sectional-average lag choices,
estimator variant, bias-correction policy, and target coefficient/diagnostic
tables before adding published expected-output fixtures.
