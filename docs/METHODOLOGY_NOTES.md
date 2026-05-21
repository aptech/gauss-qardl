# Methodology Notes

This file summarizes the estimator definitions implemented by the package.
It is intentionally concise; command-reference pages document argument syntax
and return structures.

## ARDL

The ARDL workflow estimates levels-form autoregressive distributed lag models
by OLS. `ardlFull` combines lag selection, Pesaran-Shin-Smith style bounds
testing where supported, and final levels-form estimation.

Automatic lag selection uses information criteria over candidate maximum lag
bounds. If omitted in automatic workflows, the current default maximum search
bounds are `p = 8` and `q = 8`.

Classical OLS covariance and asymptotic p-values are the current default
inference path. Residual diagnostics are available through
`ardlResidualDiagnostics`.

## QARDL

QARDL estimates quantile ARDL models for a user-specified quantile grid.
Levels-form, per-regressor lag-order, and two-step ECM workflows are available.
Robust and HAC covariance paths are implemented for QARDL-specific workflows.

QARDL full workflows use the same lag-selection and bounds-testing helper
patterns as the ARDL workflow where model definitions overlap. Quantile impulse
responses are available through `qirf`, and bootstrap QIRF bands are available
through `blockBootstrapQIRF`.

The original QARDL public APIs remain supported. Unified `predictARDL` and
`forecastARDL` also dispatch to QARDL outputs.

## NARDL

NARDL decomposes each selected regressor into positive and negative partial
sums, then estimates asymmetric long-run and short-run responses. The package
stores positive and negative long-run effects and exposes long-run asymmetry
tests where the output structure contains the required statistics.

Dynamic multiplier paths are available through `nardlDynamicMultipliers`.
NARDL bounds output is a bounds-style UECM statistic; exact finite-sample
critical-value integration remains documented separately.

## CS-ARDL

CS-ARDL estimates balanced-panel cross-sectionally augmented ARDL models.
Dataframe formula workflows infer panel identifiers using GAUSS panel-data
behavior: the first string or category variable is the unit variable, and the
first date variable, or numeric fallback, is the time variable.

The current implementation sorts by unit and time before estimation and treats
unbalanced panels as unsupported. Diagnostics exposed through
`csardlDiagnostics` include mean-group summaries, poolability Wald statistics,
slope heterogeneity summaries, and Pesaran CD residual cross-sectional
dependence checks.

## Prediction And Forecasting

`predictARDL` returns in-sample fitted values where the output structure stores
the metadata needed for reconstruction. `forecastARDL` computes recursive point
forecasts. When `future_x` is omitted, supported forecast paths use documented
hold-last behavior for exogenous regressors.

Forecast intervals are not yet statistically standardized across model
families. See `docs/FORECASTING_GUIDE.md` and
`docs/INFERENCE_INTERVALS.md`.

## Validation Policy

Synthetic deterministic fixtures validate algebra, dispatch, and regression
stability. Published-result validation is tracked separately because exact
datasets, transformations, deterministic terms, and sample ranges must match
the source references before numerical differences are meaningful.
