# Changelog

## 3.0.0 - 2026-05-03

### Added
- GAUSS 26 source smoke tests for public APIs and workflow APIs.
- GAUSS 26 source smoke tests for CSV export helpers.
- Installed-package release gate for `library qardl`.
- Statistical benchmark test for a seeded QARDL DGP, scalar/vector q-order
  equivalence, and audited PSS bounds table values.
- Package manifest verifier for `package.json`/`src` consistency.
- One-command source and example smoke-test runners.
- Usage guide covering API choice, parameter stacking, formula workflows,
  bootstrap, QIRF, and current limitations.
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
