# QARDL 3.1.0 for GAUSS: A Broader ARDL-Family Toolkit

Eric Clower  
Aptech Systems, Inc.  

Release article for QARDL 3.1.0  
Release date: 2026-05-21

## Abstract

QARDL 3.1.0 extends the GAUSS QARDL package from a primarily QARDL-focused
library into a broader ARDL-family toolkit. The release keeps the Quantile
Autoregressive Distributed Lag workflow of Cho, Kim, and Shin (2015) at the
center of the package, while adding user-facing ARDL, NARDL, and CS-ARDL model
families, unified prediction and forecasting, richer diagnostics, publication
table export, improved examples, and release-verification tooling. The result
is a single GAUSS package for applied researchers who need conventional ARDL,
quantile ARDL, nonlinear ARDL, and cross-sectional ARDL workflows with a
consistent formula syntax, output structure style, and reporting interface.

## Suggested Citation

If you use QARDL 3.1.0 in academic work, reports, teaching materials, software
comparisons, or applied research, please cite both this software release and the
underlying econometric methods relevant to your analysis.

```bibtex
@software{clower_qardl_gauss_2026_310,
  author       = {Clower, Eric},
  title        = {{QARDL 3.1.0 for GAUSS: A Broader ARDL-Family Toolkit}},
  year         = {2026},
  version      = {3.1.0},
  publisher    = {Aptech Systems, Inc.},
  url          = {https://github.com/aptech/gauss-qardl},
  note         = {GAUSS application package}
}
```

Please also cite the original QARDL methodology when using QARDL estimation:

```bibtex
@article{cho_kim_shin_2015_qardl,
  author  = {Cho, Jin Seo and Kim, Tae-Hwan and Shin, Yongcheol},
  title   = {Quantile cointegration in the autoregressive distributed-lag modeling framework},
  journal = {Journal of Econometrics},
  year    = {2015},
  volume  = {188},
  number  = {1},
  pages   = {281--300},
  doi     = {10.1016/j.jeconom.2015.05.003}
}
```

## What Is New In 3.1.0

Version 3.1.0 adds three major model families around the existing QARDL
workflow:

- ARDL levels and full-workflow estimation.
- Nonlinear ARDL (NARDL) levels, ECM, asymmetry, and dynamic-multiplier tools.
- Cross-sectional ARDL (CS-ARDL) levels, ECM, panel formula handling, and
  mean-group/poolability diagnostics.

The release also adds:

- unified `predictARDL` and `forecastARDL` dispatch across ARDL, QARDL, NARDL,
  and CS-ARDL outputs;
- backward-compatible `predictQARDL` and `forecastQARDL` wrappers;
- residual serial-correlation, heteroskedasticity, normality, and stability
  diagnostics where supported;
- CS-ARDL Pesaran CD/CD(p), Pesaran-Yamagata, mean-group, poolability Wald,
  and slope-heterogeneity diagnostics;
- formatted significance codes across printed model and diagnostic tables;
- generic Markdown, LaTeX `tabular`, and CSV coefficient-table export;
- QIRF bootstrap confidence-band plotting and clearer QIRF band messaging;
- expanded examples split into step-by-step and full-workflow scripts;
- deterministic validation fixtures, performance smoke tests, and installed
  package release verification.

## Model Families

### ARDL

The ARDL API provides a conventional OLS levels-form estimator, formula support,
lag selection, bounds testing, diagnostics, prediction, and forecasting. Users
who want a compact workflow can call `ardlFull`; users who want more control can
select lags with `pqorder` and then call `ardl` directly.

### QARDL

The QARDL workflow remains the package's central quantile cointegration tool.
Version 3.1.0 preserves existing QARDL behavior while improving reporting,
plotting, confidence-band handling, export, output metadata, and validation.
`qardlFull` continues to provide integrated lag selection, ARDL bounds testing,
levels-form QARDL estimation, and QARDL-ECM estimation.

### NARDL

The NARDL workflow supports positive and negative partial-sum decomposition,
long-run asymmetry testing, short-run asymmetry output, ECM estimation, dynamic
multipliers, and formula-based full workflows. Optional arguments on `nardl`,
`nardlECM`, and `nardlFull` extend the workflow to explicit
decomposed-variable and linear-control specifications, while `nardl` keeps the
all-RHS-decomposed compatibility behavior. The examples include both a
fixed-order step-by-step NARDL script and a formula-based full-workflow script.

### CS-ARDL

The CS-ARDL workflow supports matrix panels and dataframe formula workflows.
For dataframe inputs, CS-ARDL follows GAUSS panel-data conventions by inferring
unit and time variables from column metadata, with optional explicit
`group_var` and `time_var` overrides. The diagnostic layer reports
pooled and mean-group long-run estimates, poolability Wald statistics,
long-run slope-heterogeneity tests, Pesaran-Yamagata Delta diagnostics,
Pesaran CD/CD(p), and average residual correlation.

## Consistent Workflow Style

The release standardizes the user-facing workflow across model families:

```gauss
library qardl;

// Full workflow.
out = ardlFull(data, formula = "y ~ x1 + x2", verbose = 0);

// Model-family output is stored inside the full-workflow structure.
printARDL(out.ar);

// Unified prediction and forecast dispatch.
fit = predictARDL(out.ar, data, "y ~ x1 + x2");
fcst = forecastARDL(out.ar, data, 4, "y ~ x1 + x2");
```

For QARDL:

```gauss
tau = { 0.25, 0.50, 0.75 };
qfOut = qardlFull(data, 8, 8, tau, "", 0, "bic", "hac", 0);

printQARDL(qfOut.qa, tau);
printQARDLECM(qfOut.ecm, tau);
```

## Reporting And Export

QARDL 3.1.0 adds generic table export helpers:

```gauss
saveARDLTable(modelOut, fpath, table_format, precision, stars, ci_level);
saveARDLMarkdown(modelOut, fpath, precision, stars, ci_level);
saveARDLLaTeX(modelOut, fpath, precision, stars, ci_level);
```

These functions dispatch on ARDL-family output structures and support ARDL,
QARDL, QARDL-ECM, NARDL, NARDL-ECM, CS-ARDL, CS-ARDL-ECM, and matching
full-workflow outputs. The LaTeX helper writes a plain `tabular` environment so
users can wrap it in their preferred table float, caption, notes, or journal
style.

The main QARDL demo now includes:

```gauss
latex_path = __FILE_DIR $+ "qardl_demo_table.tex";
saveARDLLaTeX(qfOut, latex_path, 4, 1, 0.95);
```

## Diagnostics And Inference

Version 3.1.0 makes diagnostic testing more visible and consistent:

- ARDL-family residual diagnostics include Ljung-Box, Breusch-Pagan,
  Jarque-Bera, CUSUM, and CUSUMSQ where applicable.
- CS-ARDL diagnostics include mean-group and poolability diagnostics, long-run
  slope heterogeneity, Pesaran-Yamagata Delta diagnostics, Pesaran CD/CD(p),
  and average residual correlation.
- Wald covariance handling uses rank-aware pseudoinverses where appropriate.
- Output structures record covariance type, model family, formula metadata,
  selected lags, and available diagnostic metadata.

Confidence intervals and bands are documented by workflow. Current QIRF bands
are pointwise percentile bootstrap bands generated by `blockBootstrapQIRF`.

## Examples

The example suite is organized into focused scripts:

- `ardl_example.e`, `nardl_example.e`, and `csardl_example.e` show step-by-step
  estimation and diagnostics.
- `ardl_full_example.e`, `nardl_full_example.e`, and `csardl_full_example.e`
  show compact full-workflow usage.
- `demo.e` shows the modern QARDL workflow, Wald tests, QIRF, bootstrap
  intervals, plotting, and LaTeX table export.
- `sp500.e` shows a Shiller dividend/earnings application with formula support.
- `rolling_forecast_example.e` and `rolling_qardl.e` show rolling workflows.

## Validation And Release Verification

The release was checked with:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_source_tests.ps1
powershell -ExecutionPolicy Bypass -File tests\run_validation_benchmarks.ps1 -IncludePublished
powershell -ExecutionPolicy Bypass -File tests\run_examples_smoke.ps1
powershell -ExecutionPolicy Bypass -File scripts\build_package.ps1 -Force
powershell -ExecutionPolicy Bypass -File scripts\run_release_verification.ps1 -InstallArtifact
```

The validation suite includes deterministic synthetic fixtures, published
reference checks where redistributable or reproducible inputs are available,
installed-package API checks, export smoke tests, example smoke tests,
performance smoke tests, and numerical reliability tests for rank-deficient and
ill-conditioned cases.

## Limitations

Some gold-standard validation tasks remain intentionally tracked as future work:

- exact published-result replication for every applied QARDL/NARDL/CS-ARDL
  benchmark is not yet complete;
- external CS-ARDL forecast validation remains open;
- package-level save-to-file plot export is not yet standardized;
- QIRF and coefficient-path bands are pointwise unless explicitly documented
  otherwise.

These limitations are documented in the validation, inference, benchmarking,
and gold-standard roadmap notes so users can distinguish implemented features
from ongoing validation work.

## Citation Expectations

Users should cite the software and the methodological sources relevant to their
analysis:

1. This QARDL 3.1.0 software release article or repository citation metadata.
2. Cho, Kim, and Shin (2015) for QARDL methodology.
3. Pesaran, Shin, and Smith (2001) when using ARDL bounds testing.
4. Shin, Yu, and Greenwood-Nimmo (2014) when using NARDL workflows.
5. Chudik and Pesaran (2015) when using CS-ARDL workflows.
6. Chudik, Mohaddes, Pesaran, and Raissi (2016) when using CS-ARDL long-run
   effect workflows.
7. Pesaran (2004) when using Pesaran CD residual cross-sectional dependence
   diagnostics.
8. Pesaran and Yamagata (2008) when using CS-ARDL slope homogeneity
   diagnostics.
9. Appropriate quantile regression, HAC, bootstrap, or other panel diagnostic
   sources when those tools are central to the analysis.

## References

- Cho, J. S., Kim, T.-H., and Shin, Y. (2015). Quantile cointegration in the
  autoregressive distributed-lag modeling framework. *Journal of Econometrics*,
  188(1), 281-300. https://doi.org/10.1016/j.jeconom.2015.05.003
- Chudik, A., and Pesaran, M. H. (2015). Common correlated effects estimation
  of heterogeneous dynamic panel data models with weakly exogenous regressors.
  *Journal of Econometrics*, 188(2), 393-420.
  https://doi.org/10.1016/j.jeconom.2015.03.007
- Chudik, A., Mohaddes, K., Pesaran, M. H., and Raissi, M. (2016). Long-run
  effects in large heterogeneous panel data models with cross-sectionally
  correlated errors. In *Essays in Honor of Aman Ullah*, Advances in
  Econometrics, 36, 85-135. Emerald.
  https://doi.org/10.1108/S0731-905320160000036013
- Koenker, R., and Bassett, G. Jr. (1978). Regression quantiles.
  *Econometrica*, 46(1), 33-50. https://www.jstor.org/stable/1913643
- Kunsch, H. R. (1989). The jackknife and the bootstrap for general stationary
  observations. *The Annals of Statistics*, 17(3), 1217-1241.
  https://doi.org/10.1214/aos/1176347265
- Newey, W. K., and West, K. D. (1987). A simple, positive semi-definite,
  heteroskedasticity and autocorrelation consistent covariance matrix.
  *Econometrica*, 55(3), 703-708. https://doi.org/10.2307/1913610
- Pesaran, M. H., Shin, Y., and Smith, R. J. (2001). Bounds testing approaches
  to the analysis of level relationships. *Journal of Applied Econometrics*,
  16(3), 289-326. https://doi.org/10.1002/jae.616
- Pesaran, M. H. (2004). General diagnostic tests for cross section dependence
  in panels. *SSRN Electronic Journal*. https://doi.org/10.2139/ssrn.572504
- Pesaran, M. H., and Yamagata, T. (2008). Testing slope homogeneity in large
  panels. *Journal of Econometrics*, 142(1), 50-93.
  https://doi.org/10.1016/j.jeconom.2007.05.010
- Shin, Y., Yu, B., and Greenwood-Nimmo, M. (2014). Modelling asymmetric
  cointegration and dynamic multipliers in a nonlinear ARDL framework. In
  *Festschrift in Honor of Peter Schmidt: Econometric Methods and
  Applications*, 281-314. Springer.
  https://doi.org/10.1007/978-1-4899-8008-3_9
