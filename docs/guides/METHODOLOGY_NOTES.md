# Methodology Notes

This file summarizes the estimator definitions implemented by the package.
It is intentionally concise; command-reference pages document argument syntax
and return structures.

## ARDL

The ARDL workflow estimates levels-form autoregressive distributed lag models
by OLS. `ardlFull` combines lag selection, Pesaran-Shin-Smith style bounds
testing where supported, and final levels-form estimation.

`ardlECM` is the dedicated ARDL error-correction estimator. Its default
`ecm_type = "two-step"` estimates the GAUSS restricted ECM by first estimating
the levels long-run relation and then using one lagged error-correction term.
`ecm_type = "uecm"` estimates the unrestricted ECM with lagged dependent and
level regressors entered directly. UECM designs accept `case_id = 1` through
`5` to choose the Pesaran-Shin-Smith deterministic case; the default Case III
preserves the prior constant-only UECM behavior.

Automatic lag selection uses information criteria over candidate maximum lag
bounds, or `criterion = "gets"` for general-to-specific backward reduction of
the highest-order lag blocks. The GETS selector starts from the requested
maximum lags and removes lag blocks while their Wald p-values exceed
`gets_pval` (default `0.1`), preserving contiguous scalar `p/q` orders. If
omitted in automatic workflows, the current default maximum search bounds are
`p = 8` and `q = 8`.

Classical OLS covariance and asymptotic p-values are the current default
inference path. Residual diagnostics are available through
`ardlResidualDiagnostics`.

## QARDL

QARDL estimates quantile ARDL models for a user-specified quantile grid.
Levels-form, per-regressor lag-order, two-step ECM, and unrestricted ECM
workflows are available.
Robust and HAC covariance paths are implemented for QARDL-specific workflows.

QARDL full workflows use the same lag-selection and bounds-testing helper
patterns as the ARDL workflow where model definitions overlap. Quantile impulse
responses are available through `qirf`, and bootstrap QIRF bands are available
through `blockBootstrapQIRF`.

The original QARDL public APIs remain supported. Unified `predictARDL` and
`forecastARDL` also dispatch to QARDL outputs.

## NARDL

NARDL decomposes selected regressors into positive and negative partial sums,
then estimates asymmetric long-run and short-run responses. The compatibility
`nardl` workflow decomposes every RHS regressor. Optional `decomp_vars`,
`control_vars`, and `q_control` arguments on `nardl`, `nardlECM`, and
`nardlFull` let users name decomposed variables and keep other RHS variables as
linear controls.

The package stores positive and negative long-run effects, optional
linear-control long-run effects, and long-run asymmetry tests where the output
structure contains the required statistics.

`nardlECM` defaults to the same restricted two-step ECM pattern and can run a
direct unrestricted ECM with `ecm_type = "uecm"`. NARDL UECM designs accept
the same `case_id = 1` through `5` deterministic-case option. Dynamic
multiplier paths are available through `nardlDynamicMultipliers`. NARDL bounds output is a
bounds-style UECM statistic; exact finite-sample critical-value integration
remains documented separately.

## CS-ARDL

CS-ARDL estimates balanced-panel cross-sectionally augmented ARDL models.
Dataframe formula workflows infer panel identifiers using GAUSS panel-data
behavior: the first string or category variable is the unit variable, and the
first date variable, or numeric fallback, is the time variable.

The current implementation sorts by unit and time before estimation and treats
unbalanced panels as unsupported. Diagnostics exposed through
`csardlDiagnostics` include mean-group summaries, poolability Wald statistics,
long-run slope heterogeneity summaries, Pesaran-Yamagata Delta and
bias-adjusted Delta slope homogeneity tests, and Pesaran CD residual
cross-sectional dependence checks. `csardlECM` defaults to the restricted
two-step ECM and supports an unrestricted ECM with `ecm_type = "uecm"`.
Pesaran-Yamagata diagnostics are reported
for direct dynamic CS-ARDL slopes and for transformed long-run coefficients.
Pesaran CD uses all residual pairs by default and supports fixed-order `CD(p)`
through `cd_order`.

## Prediction And Forecasting

`predictARDL` returns in-sample fitted values where the output structure stores
the metadata needed for reconstruction. `forecastARDL` computes recursive point
forecasts. When `future_x` is omitted, supported forecast paths use documented
hold-last behavior for exogenous regressors.

Forecast intervals are not yet statistically standardized across model
families. See `docs/guides/FORECASTING_GUIDE.md` and
`docs/guides/INFERENCE_INTERVALS.md`.

## Validation Policy

Synthetic deterministic fixtures validate algebra, dispatch, and regression
stability. Published-result validation is tracked separately because exact
datasets, transformations, deterministic terms, and sample ranges must match
the source references before numerical differences are meaningful.
