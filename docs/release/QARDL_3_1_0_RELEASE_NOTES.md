# QARDL 3.1.0 Release Notes

Release date: 2026-05-21

QARDL 3.1.0 expands the GAUSS QARDL package into a broader ARDL-family
toolkit. Alongside the existing Quantile ARDL workflow, this release adds
user-facing OLS ARDL, NARDL, and CS-ARDL workflows, unified prediction and
forecasting, richer diagnostics, table export helpers, expanded validation
coverage, and release-verification tooling.

## Highlights

- Added user-facing OLS ARDL workflows with `ardl`, `ardlFull`, `printARDL`,
  `ardlOut`, and `ardlFullOut`.
- Added NARDL and CS-ARDL model families, including levels and ECM estimators,
  lag selection, print helpers, formula workflows, prediction/forecast hooks,
  diagnostics, output structures, and source smoke tests.
- Added explicit NARDL decomposed-variable and linear-control specifications
  through optional arguments on `nardl`, `nardlECM`, and `nardlFull` while
  preserving the legacy all-RHS-decomposed `nardl` shortcut.
- Added R-style NARDL partial-sum reset thresholds through `d`, `thresh1`,
  and `thresh2`, with default standard cumulative sums plus `"mean"`, `0`,
  custom scalar, and per-variable threshold support.
- Added `ardlAutoCase` and `nardlAutoCase` wrappers for GETS lag selection,
  deterministic-case inference from Case V UECMs, admissible case-set
  reporting, and case-specific bounds rows.
- Added opt-in sparse GETS mode for `ardlAutoCase` and `nardlAutoCase` through
  `gets_mode = "sparse"`, storing pruned Case V UECM fit metadata in
  `sparse_*` output fields.
- Added scalar GETS lag selection through `criterion = "gets"` and optional
  `gets_pval` in ARDL/QARDL, NARDL, and CS-ARDL order-selection and full
  workflows.
- Added Pesaran-Shin-Smith deterministic Case I-V controls for ARDL and NARDL
  unrestricted ECM paths through `case_id`, with `ardlFull(..., case_id)`
  using the selected case for bounds testing.
- Added unified `predictARDL` and `forecastARDL` dispatch across ARDL, QARDL,
  NARDL, and CS-ARDL outputs.
- Preserved backward-compatible `predictQARDL` and `forecastQARDL` wrappers.
- Added ARDL-family residual diagnostics for serial correlation,
  heteroskedasticity, normality, CUSUM, and CUSUMSQ where supported.
- Added CS-ARDL Pesaran CD/CD(p), Pesaran-Yamagata slope homogeneity,
  mean-group, poolability Wald, and long-run slope heterogeneity diagnostics.
- Added `ardlLongRun` for extracting stored long-run coefficients and
  covariance matrices across supported model families.
- Added generic coefficient-table export helpers: `saveARDLTable`,
  `saveARDLMarkdown`, and `saveARDLLaTeX`.
- Added `blockBootstrapQIRF` for QIRF bootstrap confidence bands and corrected
  QIRF confidence-band alignment in `plotQIRF`.
- Added standardized ARDL-family output metadata for model family, formula,
  variable names, lag orders, sample ranges, deterministic terms, covariance
  type, and lag-selection criterion.

## Reporting And Usability

- Levels-form and ECM estimator calls now print GAUSS-style result tables by
  default.
- Silent workflows can pass final `print_results = 0` options for tests,
  simulations, rolling windows, and bootstrap scripts.
- Printed ARDL, QARDL, NARDL, and CS-ARDL coefficient and diagnostic tables now
  use consistent significance codes.
- `printQARDL` and `printQARDLECM` now include diagnostic headers,
  coefficient tables, z-statistics, p-values, and 95% confidence limits.
- Forecast hooks for ARDL, QARDL, and NARDL accept optional `future_x`
  regressor paths.
- Default maximum lag-search bounds are now `p = 8` and `q = 8` when maximum
  lags are omitted in supported order-selection and full-workflow routines.
- CS-ARDL dataframe formulas now follow GAUSS panel-data conventions by
  inferring unit and time variables from string/category and date/numeric
  columns.
- Examples now use `library qardl;` only and no longer include package source
  files directly.

## Validation, Reliability, And Tooling

- Added deterministic ARDL, QARDL, NARDL, and CS-ARDL validation fixtures for
  coefficients, diagnostics, forecasts, and output-schema parity.
- Added published-reference QARDL validation against the Cho-Kim-Shin
  author-provided GAUSS demo outputs.
- Added NARDL validation for partial-sum decomposition, asymmetric effects,
  bounds diagnostics, and dynamic multipliers.
- Added ARDL bounds-test support and validation for Pesaran-Shin-Smith Cases
  I-V, including fixed-seed simulation critical-value fixtures.
- Added CS-ARDL validation for balanced panels, cross-sectional averages, lag
  alignment, formula row-order invariance, mean-group/poolability diagnostics,
  Pesaran-Yamagata diagnostics, and Pesaran CD/CD(p) diagnostics.
- Added numerical-reliability, invalid-input, rank-deficiency, missing-data,
  malformed-forecast, unbalanced-panel, and performance smoke coverage.
- Added release artifact tooling:
  `scripts/build_package.ps1`,
  `scripts/build_lcg.ps1`,
  `scripts/verify_release_artifact.ps1`, and
  `scripts/run_release_verification.ps1`.
- Package manifest verification now checks that procedures documented in
  `docs/COMMAND_REFERENCE.md` are implemented by files listed in
  `package.json`.

## Documentation

This release adds or expands documentation for:

- migration from QARDL-only versions;
- inference intervals;
- diagnostics;
- forecasting;
- reporting and plotting;
- data handling;
- methodology notes;
- feature support;
- output schema metadata;
- validation tolerances and validation fixtures;
- ARDL bounds-test support;
- citation guidance.

The release also adds `CITATION.cff`, `CITATION.md`, and a QARDL 3.1.0 release
article for users who need a preferred software citation.

## Fixes

- Corrected QIRF bootstrap confidence-band alignment so `irf_lb` and `irf_ub`
  preserve horizon-by-quantile ordering when plotted by `plotQIRF`.
- Aligned NARDL and CS-ARDL printed significance codes in fixed-width `Sig.`
  columns.
- Standardized ARDL-family significance-code notes and table borders.
- Corrected the installed-package NARDL formula prediction smoke test so it
  uses the same dataframe used to estimate the default-lag NARDL model.
- Updated package metadata and citation files to version `3.1.0`.

## Upgrade Notes

- Existing QARDL prediction and forecasting code can continue to use
  `predictQARDL` and `forecastQARDL`.
- New cross-family workflows should prefer `predictARDL` and `forecastARDL`.
- Scripts that need silent estimator calls should pass `print_results = 0`.
- Example scripts and installed-package workflows should use `library qardl;`
  instead of directly including source files.

For the complete itemized changelog, see `CHANGELOG.md`.
