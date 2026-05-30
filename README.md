# GAUSS QARDL Library

A [GAUSS](https://www.aptech.com) application package for **Quantile
Autoregressive Distributed Lag (QARDL)** estimation, based on Cho, Kim, and
Shin (2015). QARDL extends ARDL cointegration workflows by allowing long-run
relationships, short-run dynamics, and adjustment speeds to vary across
conditional quantiles.

This library is based on original GAUSS code by
[Jin Seo Cho](https://web.yonsei.ac.kr/jinseocho/qardl.htm), updated for
GAUSS 26 with structures, `quantileFit`, modern workflow helpers, robust/HAC
inference, ARDL/NARDL/CS-ARDL workflows, bootstrap tools, and release tests.

## Requirements

- GAUSS 26 or later.
- No external GAUSS packages are required.

## Installation

Install the release zip in GAUSS using **Tools > Install Application**, then
load the library:

```gauss
library qardl;
```

Manual release artifacts are available from the
[GitHub Releases page](https://github.com/aptech/gauss-qardl/releases).

## Quick Start

```gauss
library qardl;

// Column 1 = dependent variable, remaining columns = regressors.
data = loadd("mydata.csv");
tau = { 0.25, 0.50, 0.75 };

// Integrated workflow: lag selection, bounds test, QARDL, and QARDL-ECM.
qfOut = qardlFull(data, tau = tau, verbose = 1,
                  criterion = "bic", cov_type = "hac", hac_lags = 0);

printQARDL(qfOut.qa, tau);
printQARDLECM(qfOut.ecm, tau);
```

Named GAUSS dataframes can be used with formula strings:

```gauss
macro = loadd("macro.csv");
qfOut = qardlFull(macro, tau = tau,
                  formula = "consumption ~ income + wealth");
```

## Main Features

- Levels-form ARDL and QARDL estimation: `ardl`, `qardl`, `qardlRobust`,
  `qardlHAC`, `qardlX`.
- ECM estimation with two-step defaults and unrestricted ECM options:
  `ardlECM`, `qardlECM`, `qardlECMRobust`, `qardlECMHAC`, `qardlECMX`.
- NARDL and CS-ARDL model families with levels, ECM, full-workflow,
  print, prediction, and forecast hooks. NARDL also supports explicit
  decomposed-variable and linear-control specifications through optional
  arguments on `nardl`, `nardlECM`, and `nardlFull`.
- Unified `predictARDL` and `forecastARDL` dispatch for ARDL, QARDL, NARDL,
  and CS-ARDL outputs; `predictQARDL` and `forecastQARDL` remain available.
- Direct estimator calls print GAUSS-style result tables by default, with a
  final `print_results = 0` option for silent scripting.
- Integrated workflows: `ardlFull`, `qardlFull`, `nardlFull`, `csardlFull`,
  with default maximum lag search bounds of `8` and `8`.
- Formula dataframe support across ARDL-family workflows, including
  GAUSS-style panel identifier inference and explicit `group_var`/`time_var`
  overrides for CS-ARDL dataframe formulas.
- Lag selection with BIC, AIC, HQ, and HQC in the order/grid helpers; scalar
  GETS is available in `pqorder`, `pqorderRange`, and the full workflows.
- ARDL bounds testing for Pesaran-Shin-Smith Cases I-V, with bundled
  asymptotic critical values and simulation critical-value APIs.
- CS-ARDL panel diagnostics, including Pesaran CD/CD(p) and
  Pesaran-Yamagata slope homogeneity tests.
- Robust and Newey-West/Bartlett HAC covariance paths.
- Cross-quantile Wald tests, p-value helpers, QIRF with bootstrap confidence
  bands, rolling estimation, block bootstrap confidence intervals,
  confidence-band plot options, CSV export, and generic Markdown/LaTeX/CSV
  coefficient-table export.

## Documentation

The technical documentation now follows the standard Aptech GAUSS library
style:

- [Documentation home](docs/index.md): package overview,
  installation, and grouped command list.
- [Command reference](docs/COMMAND_REFERENCE.md): one page per documented
  user-facing command, with purpose, format, parameters, returns, examples,
  source, and related commands.
- [Usage guide](docs/USAGE_GUIDE.md): workflow guidance, output conventions,
  bootstrap intervals, QIRF, and limitations.
- [Migration guide](docs/MIGRATION_GUIDE.md): changes for users moving from
  QARDL-only versions to the ARDL/QARDL/NARDL/CS-ARDL package.
- [Methodology notes](docs/guides/METHODOLOGY_NOTES.md): concise estimator-family
  definitions and current inference policy.
- [Feature support matrix](docs/FEATURE_SUPPORT_MATRIX.md): diagnostics,
  forecasting, plotting, intervals, and validation support by model family.
- [Diagnostics guide](docs/guides/DIAGNOSTICS_GUIDE.md): residual and panel
  diagnostic workflows and interpretation notes.
- [Forecasting guide](docs/guides/FORECASTING_GUIDE.md): unified prediction and
  forecasting calls, future-regressor-path behavior, and interval policy.
- [Data handling and lag alignment](docs/guides/DATA_HANDLING.md): missing-value
  policy, effective estimation samples, formula parity, and future regressor
  path validation.
- [Published replication notes](docs/validation/PUBLISHED_REPLICATIONS.md): replication
  targets and the Cho-Kim-Shin dividend-policy scaffold.
- [QARDL validation](docs/validation/QARDL_VALIDATION.md): author-demo validation,
  bootstrap interval fixtures, and exact empirical-replication gaps.
- [NARDL validation](docs/validation/NARDL_VALIDATION.md): partial-sum decomposition,
  asymmetric effects, bounds, and dynamic-multiplier validation status.
- [CS-ARDL validation](docs/validation/CSARDL_VALIDATION.md): balanced-panel handling,
  cross-sectional averages, lag alignment, sorting, and diagnostics status.
- [Bounds testing support](docs/guides/BOUNDS_TESTING_SUPPORT.md): supported PSS
  cases, critical-value sources, model-family integration, and validation.
- [Prediction and forecast validation](docs/validation/FORECASTING_VALIDATION.md):
  unified dispatch, future-regressor-path assumptions, and interval gaps.
- [ARDL/NARDL R-package validation](docs/validation/R_PACKAGE_VALIDATION.md):
  optional cross-implementation checks against the CRAN `ardl.nardl` package.
- [Inference interval support](docs/guides/INFERENCE_INTERVALS.md): covariance,
  bootstrap interval, forecast interval, and simultaneous-band support.
- [Reporting and plotting support](docs/guides/REPORTING_AND_PLOTTING.md): table
  export, plot confidence-band behavior, and headless plot smoke testing.
- [Performance and numerical reliability](docs/validation/PERFORMANCE_NUMERICAL_RELIABILITY.md):
  timing smoke targets, rank/conditioning policy, and remaining reliability
  TODOs.
- [Validation tolerances](docs/validation/VALIDATION_TOLERANCES.md): expected-output
  tolerance policy for deterministic, published-reference, bootstrap, and
  performance tests.
- [LLM reference](llms.txt): compact package guide for users who want to point
  an AI assistant at the QARDL API.
- [Citation guide](CITATION.md),
  [3.1.0 release article](docs/release/QARDL_3_1_0_RELEASE_ARTICLE.md), and
  [3.0.0 release article](docs/archive/QARDL_RELEASE_ARTICLE.md): preferred software
  citation materials for research users.

## Examples

The `examples/` directory contains runnable GAUSS programs:

| File | Description |
| --- | --- |
| `demo.e` | Modern end-to-end workflow with `qardlFull`, tests, QIRF, bootstrap, and plots |
| `ardl_example.e` | Step-by-step OLS ARDL estimation, lag selection, printing, and diagnostics |
| `ardl_full_example.e` | Integrated ARDL workflow with bounds testing, prediction, and forecast |
| `qardlestimation.e` | Simulated-data workflow with p-values, QIRF, and ECM bootstrap |
| `qardl_est_tests.e` | Estimation, formatted output, automatic tests, and custom Wald restrictions |
| `nardl_example.e` | Step-by-step fixed-order NARDL estimation and asymmetry diagnostics |
| `nardl_full_example.e` | Integrated NARDL workflow with formula input, ECM output, prediction, and forecast |
| `csardl_example.e` | Step-by-step fixed-order CS-ARDL panel estimation and diagnostics |
| `csardl_full_example.e` | Integrated CS-ARDL formula workflow with ECM output, prediction, and forecast |
| `rolling_forecast_example.e` | Rolling-origin ARDL forecasts with supplied future regressor paths |
| `rolling_qardl.e` | Rolling QARDL and rolling QARDL-ECM workflows |
| `sp500.e` | Shiller dividend/earnings application using formula support |
| `replicate_cho_dividend_policy.e` | Public-data scaffold for the Cho-Kim-Shin dividend-policy application |
| `wald_tests_sim.e` | Longer Monte Carlo simulation for Wald-test behavior |

More background is available in the Aptech blog post
[The Quantile Autoregressive-Distributed Lag Parameter Estimation and Interpretation in GAUSS](https://www.aptech.com/blog/the-quantile-autoregressive-distributed-lag-parameter-estimation-and-interpretation-in-gauss/).

## Testing

Run source-tree tests from PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_source_tests.ps1
```

Run the example smoke suite:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_examples_smoke.ps1
```

Run deterministic validation fixtures:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_validation_benchmarks.ps1
```

After rebuilding and reinstalling the package, verify the installed public API:

```gauss
run tests/package_public_api.e;
```

Build and verify a release artifact:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_package.ps1 -Force
```

Run the release gate, including optional artifact installation into the GAUSS
package directory:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_release_verification.ps1 -InstallArtifact
```

## Citation

If you use this library in academic, policy, consulting, or commercial
research, please cite the QARDL software release article and the underlying
QARDL methodology. See [CITATION.md](CITATION.md) and the
[3.1.0 release article](docs/release/QARDL_3_1_0_RELEASE_ARTICLE.md). The historical
3.0.0 article remains available at
[docs/archive/QARDL_RELEASE_ARTICLE.md](docs/archive/QARDL_RELEASE_ARTICLE.md),
with a PDF copy at
[docs/archive/QARDL_RELEASE_ARTICLE.pdf](docs/archive/QARDL_RELEASE_ARTICLE.pdf).

This repository also includes [CITATION.cff](CITATION.cff), which GitHub and
software archives can use to generate citation metadata.

## License

The package license is listed in `package.json`.

## References

- Cho, J. S., Kim, T.-H., and Shin, Y. (2015). Quantile cointegration in the
  autoregressive distributed-lag modeling framework. *Journal of Econometrics*,
  188(1), 281-300. https://doi.org/10.1016/j.jeconom.2015.05.003
- Pesaran, M. H., Shin, Y., and Smith, R. J. (2001). Bounds testing approaches
  to the analysis of level relationships. *Journal of Applied Econometrics*,
  16(3), 289-326. https://doi.org/10.1002/jae.616
- Pesaran, M. H. (2004). General diagnostic tests for cross section dependence
  in panels. *SSRN Electronic Journal*. https://doi.org/10.2139/ssrn.572504
- Pesaran, M. H., and Yamagata, T. (2008). Testing slope homogeneity in large
  panels. *Journal of Econometrics*, 142(1), 50-93.
  https://doi.org/10.1016/j.jeconom.2007.05.010
- Koenker, R., and Bassett, G. Jr. (1978). Regression quantiles.
  *Econometrica*, 46(1), 33-50. https://www.jstor.org/stable/1913643
- Newey, W. K., and West, K. D. (1987). A simple, positive semi-definite,
  heteroskedasticity and autocorrelation consistent covariance matrix.
  *Econometrica*, 55(3), 703-708. https://doi.org/10.2307/1913610
- Kunsch, H. R. (1989). The jackknife and the bootstrap for general stationary
  observations. *The Annals of Statistics*, 17(3), 1217-1241.
  https://doi.org/10.1214/aos/1176347265

Additional methodological references are listed in the usage guide and command
reference.

## Authors

[Eric Clower](mailto:eric@aptech.com), Aptech Systems, Inc.
