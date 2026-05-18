# Changelog

## 3.0.1 - Unreleased

### Planned
- LaTeX export helpers for publication-ready QARDL result tables.

### Added
- Direct levels-form and ECM estimator calls now print GAUSS-style result
  tables by default, with a final `print_results = 0` option for silent
  scripts, tests, simulations, rolling windows, and bootstrap workflows.
- `printQARDL` and `printQARDLECM` now include diagnostic headers,
  coefficient table bodies, z-statistics, p-values, and 95% confidence limits.
- Printed coefficient tables now include significance asterisks
  (`***` p < 0.01, `**` p < 0.05, `*` p < 0.10).
- NARDL and CS-ARDL model families with output structures, levels and ECM
  estimators, information-criterion lag selection, print helpers, formula
  hooks, prediction/forecast hooks, and deterministic source smoke tests.
- Optional CS-ARDL mean-group and poolability diagnostics, plus deterministic
  synthetic NARDL/CS-ARDL benchmark entry points and published-validation
  tracking notes.
- User-facing OLS ARDL workflow with `ardl`, `ardlFull`, `printARDL`,
  `predictARDL`, `forecastARDL`, `ardlOut`, and `ardlFullOut`.
- QARDL prediction and forecast hooks: `predictQARDL` and `forecastQARDL`.
- Unified `predictARDL` and `forecastARDL` dispatch for ARDL, QARDL, NARDL,
  and CS-ARDL output structures, with `predictQARDL` and `forecastQARDL`
  preserved for backward compatibility.
- Default maximum lag search bounds of `p = 8` and `q = 8` for `pqorder`,
  `pqorderX`, `pqorderGrid`, `qardlFull`, `ardlFull`, `nardlFull`,
  `nardlOrder`, `csardlFull`, and `csardlOrder` when users omit maximum lags.
- Confidence-band display controls for `plotQARDL`, `plotQARDLbands`,
  `plotRollingQARDL`, `plotRollingQARDLECM`, and graceful QIRF handling when
  interval data are not available.
- `blockBootstrapQIRF` for QIRF point estimates with empirical bootstrap
  confidence bands stored in `qirfOut.irf_lb` and `qirfOut.irf_ub`.
- Standardized ARDL-family output metadata fields for model family, formula,
  variable names, lag vectors, sample ranges, deterministic terms, covariance
  type, and lag-selection criterion, plus `docs/OUTPUT_SCHEMA.md` and schema
  parity tests.
- Validation fixture registry, stored synthetic expected outputs, and
  `tests/run_validation_benchmarks.ps1` for deterministic ARDL/QARDL/NARDL/
  CS-ARDL coefficient, diagnostic, and forecast checks.
- Published-reference QARDL validation against the author-provided Cho-Kim-Shin
  GAUSS demo outputs, plus stored QARDL bootstrap interval fixtures.
- `nardlDynamicMultipliers` plus deterministic NARDL validation fixtures for
  partial-sum decomposition, asymmetric effects, bounds diagnostics, and
  dynamic multipliers.
- CS-ARDL dataframe formulas now follow GAUSS panel-data conventions:
  `y ~ x1 + x2` infers the first string/category column as the unit variable
  and the first date column, or first numeric fallback, as the time variable.
- Source-tree NARDL and CS-ARDL examples covering fixed-order estimation,
  formula workflows, lag/model selection, print helpers, output fields,
  prediction/forecast hooks, and supported diagnostics.
- Examples now use `library qardl;` only and no longer include package source
  files directly.
- Usage-guide diagnostic workflow notes documenting implemented diagnostics
  and TODO gaps for standalone residual serial-correlation,
  heteroskedasticity, normality, and classical stability tests.
- `CITATION.cff`, `CITATION.md`, and a QARDL software release article for
  users who need a preferred citation for the package.
- Licensing guidance explaining why MIT does not prevent ports/translations
  and why a reviewed source-available license is a better fit for a no-port
  release policy.

## 3.0.0 - 2026-05-03

### Added
- GAUSS 26 source smoke tests for public APIs and workflow APIs.
- GAUSS 26 source smoke tests for CSV export helpers.
- Installed-package release gate for `library qardl`.
- Statistical benchmark test for a seeded QARDL DGP, scalar/vector q-order
  equivalence, and audited PSS bounds table values.
- Robust/HAC covariance benchmark replication checks, including hand-computed
  QR sandwich covariance comparisons and automatic HAC bandwidth equivalence.
- Additional seeded simulation regression checks for q=0 and heterogeneous
  per-regressor q-order DGPs.
- Package manifest verifier for `package.json`/`src` consistency.
- One-command source and example smoke-test runners.
- Usage guide covering API choice, parameter stacking, formula workflows,
  bootstrap, QIRF, and current limitations.
- Aptech-style documentation landing page and command-reference index with
  individual command pages for the documented user-facing QARDL API.
- Condensed repository README so it acts as a project front door and delegates
  technical API details to the Aptech-style documentation pages.
- `llms.txt` compact LLM reference for users who want AI assistants to work
  from the QARDL API, data conventions, examples, and test commands.
- Published QARDL replication notes and a batch-safe Cho-Kim-Shin
  dividend-policy replication scaffold using bundled Shiller data.
- IMPLAN QARDL use-case outline moved into a separate private-repo scaffold.
- First-pass validation for plotting, Wald restriction matrices, and rolling
  estimation APIs.
- Rolling smoke coverage for levels-form QARDL and two-step ECM estimators.
- `#include qardl.sdf` in `qirf.src` for package builds that compile source
  files independently.
- AIC, BIC, HQ, and HQC lag-selection criteria in `icmean`, `pqorder`, and
  `qardlFull`; BIC remains the default.
- `pqorderRange` for restricted lag-search grids and fixed lag-order searches.
- `pqorderGrid` and `pqorderRangeGrid` for full lag-selection IC tables.
- `blockBootstrapQARDLDiag` and `blockBootstrapQARDLECMDiag` for seeded
  bootstrap runs with rank-deficient resample recovery and simple diagnostics.
- `qardlECM(..., cov_type, hac_lags)`, `qardlECMRobust`, and `qardlECMHAC`
  for robust and Newey-West/Bartlett HAC ECM covariance estimates.
- `qardl(..., cov_type, hac_lags)`, `qardlRobust`, and `qardlHAC` for robust
  and Newey-West/Bartlett HAC levels-form covariance estimates.
- `qardlFull(..., cov_type, hac_lags)` pass-through for robust/HAC covariance
  in the integrated workflow.
- `blockBootstrapQARDLMethod` and `blockBootstrapQARDLECMMethod` with
  `"moving"`, `"circular"`, and `"stationary"` resampling choices.
- `ardlboundsCase` for PSS deterministic Cases I-V plus the bounds t-statistic.
- Distributed-lag order `q = 0` support for QARDL, QARDL-ECM, lag selection,
  QIRF, and ARDL bounds workflows.
- `ardlboundsCaseSim`, `ardlboundsCaseSimCV`, and `ardlboundsCaseCV` for
  simulation-based ARDL bounds critical values across Cases I-V, finite sample
  sizes, and k values beyond the bundled asymptotic table.
- Bundled PSS asymptotic F critical-value tables for ARDL bounds Cases I, II,
  IV, and V, in addition to the existing Case III table.
- `qardlX`, `qardlECMX`, `icmeanX`, `pqorderX`, and `pqorderXGrid` for
  per-regressor distributed-lag orders.
- `qardlFull(..., verbose = 1)` option; pass `0` to compute silently.
- Metadata fields on `qardlOut`, `qardlECMOut`, and `qardlFullOut`.
- `GOLD_STANDARD_TODO.md` release-readiness inventory and improvement backlog.

### Fixed
- GAUSS 26 zero-column matrix failures in `ardlbounds`.
- GAUSS 26 compile/runtime failures in `qirf`, `wtestsym`, and `wtestconst`.
- Moving-block bootstrap index construction.
- `rollingQardl` when only one p value is tested.
- Formula lookup in `applyQARDLFormula`.
- GAUSS-compatible number formatting in `ardlbounds_print`.
- Package manifest ordering and duplicate source entries.
- CSV writer console noise and export failure handling.
- Smoke-test runners now scan GAUSS output for compile/execute failures even
  when `tgauss` returns exit code 0.
- Rectangular-grid indexing in `pqorder`.
- Rank and conditioning diagnostics for core design/moment matrices, plus
  rank-aware Wald-test pseudoinverse handling when a restriction covariance is
  singular or near-singular.

### Changed
- Minimum supported GAUSS version is GAUSS 26.
- Source tests explicitly include local `qardl.sdf` so stale installed structs
  cannot mask source-tree changes.
- Main examples now demonstrate the modern API: `qardlFull`, formula support,
  metadata fields, formatted print helpers, automatic Wald tests, QIRF,
  rolling plot helpers, and bootstrap confidence intervals.
- README and usage guide now include a fuller references section covering the
  methods implemented in the package.
