# QARDL for GAUSS: Quantile Autoregressive Distributed Lag Estimation, Inference, and Applied Workflows

Eric Clower  
Aptech Systems, Inc.  

Release article for QARDL 3.0.0  
Release date: 2026-05-03

PDF version: [QARDL_RELEASE_ARTICLE.pdf](QARDL_RELEASE_ARTICLE.pdf)

## Abstract

QARDL for GAUSS is a research software library for estimating Quantile
Autoregressive Distributed Lag models in GAUSS. The library implements the
quantile cointegration framework of Cho, Kim, and Shin (2015), extending
standard ARDL workflows to allow long-run relationships, short-run dynamics,
and adjustment speeds to vary across the conditional distribution of the
dependent variable. Version 3.0.0 updates the original GAUSS QARDL codebase for
GAUSS 26, adds metadata-rich output structures, formula-based dataframe
support, robust and HAC covariance options, expanded ARDL bounds testing,
per-regressor lag-order workflows, bootstrap tools, rolling estimation, QIRF,
plotting, export helpers, and a release-oriented test suite. This article
describes the purpose, scope, major features, and citation expectations for
the QARDL GAUSS library.

## Suggested Citation

If you use the QARDL GAUSS library in academic work, reports, teaching
materials, software comparisons, or applied research, please cite both this
software description and the underlying econometric methods.

```bibtex
@software{clower_qardl_gauss_2026,
  author       = {Clower, Eric},
  title        = {{QARDL for GAUSS: Quantile Autoregressive Distributed Lag Estimation, Inference, and Applied Workflows}},
  year         = {2026},
  version      = {3.0.0},
  publisher    = {Aptech Systems, Inc.},
  url          = {https://github.com/aptech/gauss-qardl},
  note         = {GAUSS application package}
}
```

Please also cite the original QARDL methodology:

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

## Software Scope

The library is designed for applied time-series researchers who need to study
long-run relationships and adjustment dynamics that differ across quantiles.
It is particularly useful when the lower, median, and upper portions of the
conditional distribution may respond differently to changes in regressors.

The package supports:

- Levels-form QARDL estimation.
- Two-step QARDL error-correction estimation.
- Integrated lag selection, bounds testing, QARDL, and ECM workflow.
- Robust and Newey-West/Bartlett HAC covariance estimators.
- Pesaran-Shin-Smith ARDL bounds tests for deterministic Cases I-V.
- Bundled asymptotic bounds critical values and simulation-based critical
  values.
- Per-regressor distributed-lag order selection and estimation.
- Wald tests for long-run, short-run, constancy, and symmetry restrictions.
- Bootstrap confidence intervals for QARDL and QARDL-ECM.
- Rolling-window QARDL and QARDL-ECM estimation.
- Quantile impulse response functions.
- Formatted printing, plotting, CSV export, and documentation suitable for
  applied workflows.

## Relationship To The Original Code

The QARDL GAUSS package builds on original GAUSS code by Jin Seo Cho. Version
3.0.0 modernizes the codebase for GAUSS 26, reorganizes outputs into GAUSS
structures, uses GAUSS `quantileFit`, and adds a broader applied workflow
around the core estimator.

## Core Workflow

The recommended applied workflow is:

```gauss
library qardl;

data = loadd("mydata.csv");
tau = { 0.25, 0.50, 0.75 };

qfOut = qardlFull(data, 8, 8, tau, "", 1, "bic", "hac", 0);

printQARDL(qfOut.qa, tau);
printQARDLECM(qfOut.ecm, tau);
```

This workflow performs:

1. Information-criterion lag selection.
2. ARDL bounds testing.
3. Levels-form QARDL estimation.
4. Two-step QARDL-ECM estimation.
5. Formatted reporting.

## Major Version 3.0.0 Features

Version 3.0.0 introduced a release-ready foundation:

- GAUSS 26 compatibility.
- `qardlFull` integrated workflow.
- Formula dataframe support through `applyQARDLFormula`.
- `qardlRobust`, `qardlHAC`, `qardlECMRobust`, and `qardlECMHAC`.
- Per-regressor lag-order APIs: `qardlX`, `qardlECMX`, `pqorderX`, and
  `pqorderXGrid`.
- `q = 0` distributed-lag support while retaining `p >= 1`.
- AIC, BIC, HQ, and HQC lag-selection criteria.
- ARDL bounds Cases I-V and simulation critical-value tools.
- Safer rank and conditioning diagnostics.
- Rank-aware Wald-test pseudoinverse handling.
- Moving, circular, and stationary block-bootstrap variants.
- QIRF, rolling estimation, plotting, formatted output, and CSV export.
- Source-tree tests, installed-package tests, statistical benchmark tests,
  example smoke tests, and package manifest verification.
- Aptech-style documentation and command-reference pages.

## Validation And Testing

The release is accompanied by source-tree and installed-package checks:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_source_tests.ps1
powershell -ExecutionPolicy Bypass -File tests\run_examples_smoke.ps1
```

After rebuilding and reinstalling the package:

```gauss
run tests/package_public_api.e;
```

The test suite includes public API smoke tests, workflow tests, export tests,
statistical benchmark checks, example smoke tests, and package manifest
verification.

## Limitations

The current package focuses on QARDL models with `p >= 1`. Distributed-lag
order `q = 0` is supported. QIRF confidence bands, LaTeX export, and deeper
publication-ready presentation tools are planned for post-3.0.0 work.

## Citation Expectations

Users of this library should cite:

1. This QARDL GAUSS software description or the repository citation metadata.
2. Cho, Kim, and Shin (2015) for the QARDL methodology.
3. Pesaran, Shin, and Smith (2001) when using ARDL bounds testing.
4. Other relevant methodological sources for robust/HAC covariance,
   bootstrap, or quantile regression if those features are central to the
   analysis.

## References

- Cho, J. S., Kim, T.-H., and Shin, Y. (2015). Quantile cointegration in the
  autoregressive distributed-lag modeling framework. *Journal of Econometrics*,
  188(1), 281-300. https://doi.org/10.1016/j.jeconom.2015.05.003
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
