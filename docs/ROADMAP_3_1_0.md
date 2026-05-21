# QARDL 3.1.0 Roadmap

This roadmap captures the planned 3.1.0 release scope. The theme is
presentation, plotting uncertainty, and publication-ready table export.

## Goals

1. Improve printed result tables with GAUSS-style report headers and coefficient
   table bodies. First slice completed for `printQARDL` and `printQARDLECM`.
2. Add confidence-band estimation and visualization where relevant. Initial
   plot controls and QIRF bootstrap bands are implemented.
3. Add LaTeX export for publication-ready result tables.

## 1. Improved Printed Tables

### Motivation

Current `printQARDL` and `printQARDLECM` output is useful, but 3.1.0 should
move closer to standard GAUSS procedure output: a compact diagnostic header,
separator rules, and a coefficient body with estimates, standard errors,
test statistics, p-values, and confidence limits.

### Target Output Style

Header should include relevant model diagnostics:

- Estimator name.
- Dependent variable label if available.
- Number of observations.
- Number of regressors.
- Lag orders `p` and `q`.
- Quantile grid.
- Covariance estimator, including HAC lag length if applicable.
- ARDL bounds statistic when printing from `qardlFull`.
- Information criterion and selected lag orders when printing from
  `qardlFull`.
- Bootstrap diagnostic counts when printing bootstrap tables.

Coefficient body should include:

- Parameter group.
- Quantile.
- Variable or lag label.
- Estimate.
- Standard error.
- z-statistic or t-statistic label appropriate to the estimator.
- p-value.
- Lower confidence bound.
- Upper confidence bound.

### Proposed API

Keep existing calls backward compatible:

```gauss
printQARDL(qaOut);
printQARDLECM(qECMOut);
```

Current 3.1.0 slice adds automatic printing directly to estimation procedures:

```gauss
qaOut = qardl(data, ppp, qqq, tau, cov_type, hac_lags, print_results);
qECMOut = qardlECM(data, ppp, qqq, tau, cov_type, hac_lags, print_results);
```

Direct estimator calls default to `print_results = 1`. Internal workflows,
tests, simulations, rolling estimation, and bootstrap routines pass
`print_results = 0`.

Future optional controls:

```gauss
printQARDLControl(qaOut, ctl);
printQARDLECMControl(qECMOut, ctl);
printQARDLFull(qfOut, level, table_style);
```

Suggested defaults for future control APIs:

- `level = 0.95`
- `table_style = "standard"`

`table_style` candidates:

- `"standard"`: GAUSS-style header plus coefficient table.
- `"compact"`: shorter console output.
- `"legacy"`: preserve 3.0.0 formatting if users want it.

### Implementation Notes

- Add shared internal table helpers rather than duplicating formatting logic:
  - `_qardlPrintRule(width, char)`
  - `_qardlPrintKeyValueBlock(labels, values)`
  - `_qardlPrintCoefTable(names, coef, se, stat, pval, lb, ub)`
  - `_qardlFormatNumber(x, width, precision)`
- Add confidence limits to print output using stored covariance matrices:
  `estimate +/- zcrit*SE`.
- Consider adding metadata fields in a later release for variable names,
  covariance type, and estimator type. For 3.1.0, print available metadata and
  use generic labels such as `x1`, `x2`, `phi_l1`, and `beta_x1`.

## 2. Confidence Bands And Visualization

### Motivation

Users generally expect uncertainty bands on coefficient paths and impulse
responses. QARDL 3.1.0 should make bands visible by default where the required
uncertainty information is available.

### Coefficient Plots

Existing:

```gauss
plotQARDL(qaOut, tau);
plotQARDLbands(qaOut, tau);
```

Proposed 3.1.0 behavior:

```gauss
plotQARDL(qaOut, tau);              // bands on by default
plotQARDL(qaOut, tau, 1, 0.95);     // explicit bands on
plotQARDL(qaOut, tau, 0);           // bands off
```

Keep `plotQARDLbands` as a compatibility wrapper around `plotQARDL(...,
bands = 1)`.

### Rolling Plots

Rolling output structures already include standard errors. Update:

```gauss
plotRollingQARDL(rqaOut, tau, dates);
plotRollingQARDLECM(rECMOut, tau, dates);
```

Proposed optional arguments:

```gauss
plotRollingQARDL(rqaOut, tau, dates, bands, level);
plotRollingQARDLECM(rECMOut, tau, dates, bands, level);
```

Default:

- `bands = 1`
- `level = 0.95`

### QIRF Bands

`plotQIRF(qOut)` cannot estimate bootstrap bands by itself unless the `qirfOut`
object already contains confidence-band fields. Therefore, the recommended
3.1.0 design is:

```gauss
qOut = qirf(qaOut, ppp, qqq, H, tau, k_x, permanent);
plotQIRF(qOut);                      // plots line only because no bands exist

qBandOut = blockBootstrapQIRF(data, ppp, qqq, H, tau, k_x, permanent,
                              B, blk_len, alpha, seed, method);
plotQIRF(qBandOut, 1);               // bands shown
plotQIRF(qBandOut, 0);               // bands off
```

### Proposed `qirfOut` Fields

Extend `qirfOut`:

- `irf`
- `irf_lb`
- `irf_ub`
- `bands_available`
- `tau`
- `H`
- `k_x`
- `permanent`
- `alpha`
- `boot_diag`

### QIRF Band API

```gauss
qBandOut = blockBootstrapQIRF(data, ppp, qqq, H, tau, k_x, permanent,
                              B, blk_len, alpha, seed, method, formula);
```

Suggested defaults:

- `B = 999`
- `blk_len = 0`
- `alpha = 0.05`
- `method = "moving"`
- `seed = 0`

Band type:

- Percentile block-bootstrap bands.
- Skip rank-deficient bootstrap replications and count them in diagnostics.

### Plotting Principle

Users should not need a second plot function for uncertainty. Plot functions
should show confidence bands by default when band information is available, and
provide an option to turn bands off.

## 3. LaTeX Table Export

### Motivation

CSV export is helpful for workflows, but publication users need direct LaTeX
table output for papers, reports, and appendices.

### Proposed API

```gauss
saveQARDLLaTeX(qaOut, tau, outpath, level, table_style);
saveQARDLECMLaTeX(qECMOut, tau, outpath, level, table_style);
saveQARDLFullLaTeX(qfOut, outpath, level, table_style);
```

Suggested defaults:

- `outpath = "qardl_results.tex"` or procedure-specific default.
- `level = 0.95`
- `table_style = "standard"`

### Output Tables

Levels-form QARDL:

- Long-run beta table.
- Gamma/theta table.
- Phi table.
- Optional alpha/rho derived-parameter table.

QARDL-ECM:

- Step 1 OLS long-run coefficients.
- Step 2 alpha/rho quantile table.

QARDL full workflow:

- Diagnostic summary.
- Bounds-test summary.
- Levels-form table.
- ECM table.

### LaTeX Style

Initial 3.1.0 should produce plain LaTeX tables with minimal dependencies:

```latex
\begin{table}
\centering
\caption{QARDL Estimates}
\begin{tabular}{llrrrrrr}
...
\end{tabular}
\end{table}
```

Optional later enhancement:

- `booktabs = 1` support for `\toprule`, `\midrule`, and `\bottomrule`.
- Significance stars.
- Longtable support.

### Implementation Notes

- Share table-building logic with the improved print functions.
- Use escaping for variable labels and captions.
- Validate output paths and fail clearly if a file cannot be opened.
- Add smoke tests that confirm files are created and contain key LaTeX tokens.

## Tests For 3.1.0

Add source tests for:

- Improved print functions compile and run.
- Confidence limits are finite and have correct shapes.
- `plotQARDL(..., bands = 0)` and `plotQARDL(..., bands = 1)` compile in batch
  or have headless-safe behavior.
- `qirfBootstrap` returns `irf`, `lb`, `ub`, and diagnostics with expected
  dimensions for small `B`.
- `plotQIRF` handles banded and unbanded `qirfOut` objects.
- LaTeX export creates files with expected `tabular`, coefficient labels, and
  numeric content.

## Documentation For 3.1.0

Update:

- README feature list.
- `llms.txt`.
- `docs/qardl-landing.md`.
- Relevant command-reference pages:
  - `printQARDL`
  - `printQARDLECM`
  - `plotQARDL`
  - `plotQARDLbands`
  - `plotRollingQARDL`
  - `plotRollingQARDLECM`
  - `qirf`
  - `plotQIRF`
  - new LaTeX export pages.
- `docs/USAGE_GUIDE.md` with examples for confidence bands and LaTeX export.

## Release Notes Draft

QARDL 3.1.0 focuses on publication-ready output. It adds GAUSS-style printed
result tables, default confidence-band plotting where uncertainty information
is available, bootstrap confidence bands for QIRFs, and LaTeX export helpers
for QARDL, QARDL-ECM, and integrated workflow results.
