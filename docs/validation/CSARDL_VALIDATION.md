# CS-ARDL Validation

This note records the current CS-ARDL validation status and panel-data
contract. The active checks are deterministic source-tree validation fixtures,
not exact published Chudik-Pesaran Monte Carlo replications.

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

The CS-ARDL formula workflow follows GAUSS panel-data conventions unless
explicit `group_var` and `time_var` inputs are supplied:

- the first string or category variable is the unit variable
- the first date variable is the time variable
- if no date variable exists, the first numeric variable is used as the time
  variable

Formula input is sorted by the resolved unit/time variables before the
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
- recomputing the mean-group-centered long-run slope heterogeneity Wald
  statistic from unit-specific long-run covariance matrices
- recomputing the Pesaran-Yamagata Delta and bias-adjusted Delta statistics
  for direct CS-ARDL dynamic slopes
- recomputing the long-run Pesaran-Yamagata Delta and bias-adjusted Delta
  statistics for CS-ARDL long-run coefficients
- recomputing the all-pairs Pesaran CD statistic from the balanced matrix of
  unit-specific residuals
- recomputing a fixed-order `CD(1)` statistic from the same residual matrix
- confirming formula/dataframe diagnostics match matrix diagnostics after
  sorting

The current poolability statistic is a Wald-style diagnostic convenience
measure. The long-run slope heterogeneity statistic is also a Wald-style
diagnostic convenience measure centered on the mean-group long-run slopes.
The Pesaran-Yamagata fields implement the standardized Swamy-style Delta and
bias-adjusted Delta diagnostics for direct dynamic slopes and for transformed
long-run coefficients. The Pesaran CD fields include the all-pairs CD statistic
and metadata for pair count, average residual correlation, average absolute
residual correlation, and pairwise residual counts.

Finite-sample behavior against exact published dynamic CCE/CS-ARDL designs
remains a separate validation target, but the panel diagnostic formulas are
covered by deterministic manual-reproduction fixtures.

## Unsupported Cases

Unbalanced CS-ARDL panels are not supported in the current implementation. A
user should first align or balance the panel before calling `csardl`,
`csardlECM`, `csardlFull`, or `csardlDiagnostics`.

Expected-failure tests under `tests/invalid_input_cases/` verify that
unbalanced matrix inputs, unstacked matrix inputs, and unbalanced formula
diagnostic inputs stop with explicit panel-layout errors.

Explicit unit/time arguments are supported through `group_var` and `time_var`.
If these are left as `""`, arrange and type the dataframe so the desired unit
column is the first string/category variable and the desired time column is the
first date variable, or first numeric variable if no date variable is present.

## Pending Published Validation

Exact Chudik-Pesaran style Monte Carlo validation remains pending until a specific
redistributable Monte Carlo grid or empirical replication target is selected.
The pending work is to document the DGP, cross-sectional-average lag choices,
estimator variant, bias-correction policy, and target coefficient/diagnostic
tables before adding published expected-output fixtures.

## Diagnostic Method References

- Pesaran, M. H. (2004). General diagnostic tests for cross section dependence
  in panels. SSRN Electronic Journal. https://doi.org/10.2139/ssrn.572504
- Pesaran, M. H., and Yamagata, T. (2008). Testing slope homogeneity in large
  panels. Journal of Econometrics, 142(1), 50-93.
  https://doi.org/10.1016/j.jeconom.2007.05.010
