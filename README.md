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
- Two-step QARDL-ECM estimation: `qardlECM`, `qardlECMRobust`,
  `qardlECMHAC`, `qardlECMX`.
- NARDL and CS-ARDL model families with levels, ECM, full-workflow,
  print, prediction, and forecast hooks.
- Unified `predictARDL` and `forecastARDL` dispatch for ARDL, QARDL, NARDL,
  and CS-ARDL outputs; `predictQARDL` and `forecastQARDL` remain available.
- Direct estimator calls print GAUSS-style result tables by default, with a
  final `print_results = 0` option for silent scripting.
- Integrated workflows: `ardlFull`, `qardlFull`, `nardlFull`, `csardlFull`,
  with default maximum lag search bounds of `8` and `8`.
- Formula dataframe support across ARDL-family workflows, including
  GAUSS-style panel identifier inference for CS-ARDL dataframe formulas.
- Lag selection with BIC, AIC, HQ, and HQC: `pqorder`, `pqorderRange`,
  `pqorderGrid`, `pqorderX`, `pqorderXGrid`.
- ARDL bounds testing for Pesaran-Shin-Smith Cases I-V, with bundled
  asymptotic critical values and simulation critical-value APIs.
- Robust and Newey-West/Bartlett HAC covariance paths.
- Cross-quantile Wald tests, p-value helpers, QIRF with bootstrap confidence
  bands, rolling estimation, block bootstrap confidence intervals,
  confidence-band plot options, CSV export, and generic Markdown/LaTeX/CSV
  coefficient-table export.

## Documentation

The technical documentation now follows the standard Aptech GAUSS library
style:

- [QARDL landing page](docs/qardl-landing.md): package overview,
  installation, and grouped command list.
- [Command reference](docs/COMMAND_REFERENCE.md): one page per documented
  user-facing command, with purpose, format, parameters, returns, examples,
  source, and related commands.
- [Usage guide](docs/USAGE_GUIDE.md): workflow guidance, output conventions,
  bootstrap intervals, QIRF, and limitations.
- [Migration guide](docs/MIGRATION_GUIDE.md): changes for users moving from
  QARDL-only versions to the ARDL/QARDL/NARDL/CS-ARDL package.
- [Methodology notes](docs/METHODOLOGY_NOTES.md): concise estimator-family
  definitions and current inference policy.
- [Feature support matrix](docs/FEATURE_SUPPORT_MATRIX.md): diagnostics,
  forecasting, plotting, intervals, and validation support by model family.
- [Diagnostics guide](docs/DIAGNOSTICS_GUIDE.md): residual and panel
  diagnostic workflows, interpretation notes, and current TODO gaps.
- [Forecasting guide](docs/FORECASTING_GUIDE.md): unified prediction and
  forecasting calls, future-regressor-path behavior, and interval policy.
- [Data handling and lag alignment](docs/DATA_HANDLING.md): missing-value
  policy, effective estimation samples, formula parity, and future regressor
  path validation.
- [Published replication notes](docs/PUBLISHED_REPLICATIONS.md): replication
  targets and the Cho-Kim-Shin dividend-policy scaffold.
- [QARDL validation](docs/QARDL_VALIDATION.md): author-demo validation,
  bootstrap interval fixtures, and exact empirical-replication gaps.
- [NARDL validation](docs/NARDL_VALIDATION.md): partial-sum decomposition,
  asymmetric effects, bounds, and dynamic-multiplier validation status.
- [CS-ARDL validation](docs/CSARDL_VALIDATION.md): balanced-panel handling,
  cross-sectional averages, lag alignment, sorting, and diagnostics status.
- [Bounds testing support](docs/BOUNDS_TESTING_SUPPORT.md): supported PSS
  cases, critical-value sources, model-family integration, and validation.
- [Prediction and forecast validation](docs/FORECASTING_VALIDATION.md):
  unified dispatch, future-regressor-path assumptions, and interval gaps.
- [Inference interval support](docs/INFERENCE_INTERVALS.md): covariance,
  bootstrap interval, forecast interval, and simultaneous-band support.
- [Reporting and plotting support](docs/REPORTING_AND_PLOTTING.md): table
  export, plot confidence-band behavior, and headless plot smoke testing.
- [Performance and numerical reliability](docs/PERFORMANCE_NUMERICAL_RELIABILITY.md):
  timing smoke targets, rank/conditioning policy, and remaining reliability
  TODOs.
- [LLM reference](llms.txt): compact package guide for users who want to point
  an AI assistant at the QARDL API.
- [3.1.0 roadmap](docs/ROADMAP_3_1_0.md): planned presentation and LaTeX
  export improvements, plus historical confidence-band planning notes.
- [Citation guide](CITATION.md) and
  [release article](docs/QARDL_RELEASE_ARTICLE.md): preferred software
  citation materials for research users.
- [Licensing options](docs/LICENSING_OPTIONS.md): notes on choosing the final
  release license before publication.

## Examples

The `examples/` directory contains runnable GAUSS programs:

| File | Description |
| --- | --- |
| `demo.e` | Modern end-to-end workflow with `qardlFull`, tests, QIRF, bootstrap, and plots |
| `ardl_example.e` | OLS ARDL estimation, formula input, full workflow, prediction, and forecast |
| `qardlestimation.e` | Simulated-data workflow with p-values, QIRF, and ECM bootstrap |
| `qardl_est_tests.e` | Estimation, formatted output, automatic tests, and custom Wald restrictions |
| `nardl_example.e` | NARDL fixed-order, formula, lag-selection, prediction, and forecast workflow |
| `csardl_example.e` | CS-ARDL panel workflow with formula input, prediction, forecast, and diagnostics |
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

Release steps are tracked in [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md).
The current release-readiness inventory and backlog are in
[GOLD_STANDARD_TODO.md](GOLD_STANDARD_TODO.md).

## Citation

If you use this library in academic, policy, consulting, or commercial
research, please cite the QARDL software release article and the underlying
QARDL methodology. See [CITATION.md](CITATION.md) and
[docs/QARDL_RELEASE_ARTICLE.md](docs/QARDL_RELEASE_ARTICLE.md). A PDF copy is
also available at [docs/QARDL_RELEASE_ARTICLE.pdf](docs/QARDL_RELEASE_ARTICLE.pdf).

This repository also includes [CITATION.cff](CITATION.cff), which GitHub and
software archives can use to generate citation metadata.

## License

The final public release license should be confirmed before publishing. The
current package metadata lists MIT, but MIT permits redistribution and ports.
If the intended policy is open GAUSS use while preventing direct translation or
porting into other languages, use a reviewed source-available custom license
instead of a standard OSI open-source license. See
[docs/LICENSING_OPTIONS.md](docs/LICENSING_OPTIONS.md).

## References

- Cho, J. S., Kim, T.-H., and Shin, Y. (2015). Quantile cointegration in the
  autoregressive distributed-lag modeling framework. *Journal of Econometrics*,
  188(1), 281-300. https://doi.org/10.1016/j.jeconom.2015.05.003
- Pesaran, M. H., Shin, Y., and Smith, R. J. (2001). Bounds testing approaches
  to the analysis of level relationships. *Journal of Applied Econometrics*,
  16(3), 289-326. https://doi.org/10.1002/jae.616
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
