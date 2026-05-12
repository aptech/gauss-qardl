# Published Replication Notes

This note tracks published examples that are useful for validating and
demonstrating the GAUSS QARDL library and the adjacent NARDL/CS-ARDL
model families.

## Replication Registry

| ID | Paper / target | Model family | Dataset status | Transformation status | Target tables / outputs | Expected-output path | Current validation state |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `published-ardl-pss2001` | Pesaran, Shin, and Smith (2001), ARDL bounds critical values | ARDL / bounds testing | No empirical dataset required | Not applicable; table lookup and simulation settings only | Cases I-V critical-value tables and simulated critical-value checks | `tests/fixtures/expected/published/ardl_bounds_pss_selected_cv.csv` | Selected table values pass; full support matrix pending |
| `published-qardl-author-demo1` | Cho, Kim, and Shin (2015), author GAUSS demo archive | QARDL | Bundled demo dataset available as `examples/qardl_data.dat` | No transformations; columns 1:3, BIC over `p,q <= 7`, selected `p = 2`, `q = 1`, tau = 0.25/0.50/0.75 | Selected lags, long-run beta, beta covariance, phi, phi covariance, gamma, gamma covariance, Wald tests, median-quantile SE tables | `tests/fixtures/expected/published/qardl_author_demo1_*.csv` | Passes as published-reference software validation |
| `published-qardl-cks2015` | Cho, Kim, and Shin (2015), U.S. dividend-policy application | QARDL | Exact author dataset pending; bundled Shiller data are only an approximation | Pending exact variable definitions, sample window, deterministic case, lag specification, and quantile grid | Long-run coefficient table, short-run coefficients, Wald tests, bounds test, bootstrap intervals | `tests/fixtures/expected/published/` | Scaffold only; no numerical pass/fail claim |
| `published-qardl-ckgns2023` | Cho, Kim, Greenwood-Nimmo, and Shin (2023), asymmetric dividend response to earnings news | QARDL / asymmetric QARDL candidate | Candidate pending data confirmation | Pending earnings-news construction and asymmetric specification details | Coefficient tables, asymmetry tests, QIRF or dynamic response outputs if applicable | Pending | Not started |
| `published-qadl-gmp2013` | Galvao, Montes-Rojas, and Park (2013), QADL house-price returns | Adjacent quantile ARDL | Candidate pending redistributable data | Pending stationary-return construction and estimator-definition comparison | QADL coefficient tables and cross-implementation comparison notes | Pending | Not started; adjacent methodology |
| `published-nardl-syg2014` | Shin, Yu, and Greenwood-Nimmo (2014), NARDL asymmetric cointegration and dynamic multipliers | NARDL | Exact datasets pending | Pending positive/negative partial sums, sample windows, deterministic terms, lag orders, and dynamic multiplier settings | Long-run asymmetry, dynamic multipliers, bounds tests | `tests/fixtures/expected/published/` | Pending exact data/specification |
| `published-csardl-cp2015` | Chudik and Pesaran (2015), dynamic CCE / CS-ARDL panel Monte Carlo designs | CS-ARDL | Exact Monte Carlo grid pending | Pending DGP grid, cross-sectional-average lag choices, estimator variants, and bias-correction policy | Pooled and mean-group coefficients, poolability or heterogeneity diagnostics, Monte Carlo summary tables | `tests/fixtures/expected/published/` | Pending exact DGP grid |
| `cross-qardlr-simulated` | R `qardlr` simulated QARDL dataset | QARDL cross-implementation | Benchmark candidate, not an empirical paper replication | Pending DGP alignment and estimator-default comparison | Coefficients, selected lags, long-run estimates | Pending | Not started |

## Current Scaffold

Run:

```gauss
run examples/replicate_cho_dividend_policy.e;
```

The script:

- Loads `examples/shiller_stocks_qt.csv`.
- Estimates `real_dividend ~ real_earnings` over quantiles 0.10 through 0.90.
- Uses `qardlFull(..., "bic", "robust", 0)` and a HAC comparison.
- Reports selected lag orders, the ARDL bounds statistic, long-run beta by
  quantile, and cross-quantile constancy tests.

Interpretation should focus on qualitative replication of the published
dividend-policy application: dividend smoothing, long-run earnings/dividend
linkages, and heterogeneity across conditional dividend quantiles. Do not claim
exact table replication until the original data and specification are matched.

## Exact-Replication Checklist

1. Identify the publication's exact dependent variable, regressor set,
   transformations, frequency, and sample window.
2. Confirm whether deterministic terms are included and which ARDL bounds case
   is appropriate.
3. Match lag selection or fixed lag orders.
4. Match quantile grid and covariance assumptions.
5. Store the raw data source, transformation script, and final GAUSS dataset
   under a reproducible path if redistribution is allowed.
6. Add an expected-results benchmark test with tolerances that reflect
   publication rounding and any implementation differences.

## Synthetic Benchmarks

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_new_model_benchmarks.ps1
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1
```

`run_new_model_benchmarks.ps1` runs deterministic synthetic NARDL and CS-ARDL
workloads and prints summary values. `run_validation_benchmarks.ps1` compares
stored expected coefficients, diagnostics, and forecasts against active
deterministic fixtures.

Active deterministic fixture metadata lives in
`tests/fixtures/fixture_manifest.csv`. Stored expected outputs are grouped under
`tests/fixtures/expected/synthetic/` by category:

- `coefficients/`
- `diagnostics/`
- `forecasts/`
- `intervals/`

Published-result expected outputs are reserved under
`tests/fixtures/expected/published/` and remain empty until exact datasets and
specifications are available.

See `docs/QARDL_VALIDATION.md` for the active QARDL author-demo validation
target, QARDL bootstrap interval fixture, and exact empirical-replication gaps.

## Tolerance Policy

Deterministic synthetic coefficient, diagnostic, and forecast fixtures use a
default tolerance of `1e-8`. Published-result fixtures should set tolerances in
the manifest according to the source table's rounding, independent reproduction
precision, and any documented estimator differences. Bootstrap and interval
fixtures must use fixed seeds and should record whether the validation target is
pointwise, simultaneous, or shape-only.

## Sources

- Pesaran, M. H., Shin, Y., and Smith, R. J. (2001). Bounds testing approaches
  to the analysis of level relationships. Journal of Applied Econometrics,
  16(3), 289-326. https://doi.org/10.1002/jae.616
- Cho, J. S., Kim, T.-H., and Shin, Y. (2015). Quantile cointegration in the
  autoregressive distributed-lag modeling framework. Journal of Econometrics,
  188(1), 281-300. https://doi.org/10.1016/j.jeconom.2015.05.003
- IDEAS working-paper record for Cho, Kim, and Shin (2014), noting the U.S.
  dividend-policy empirical application and public working-paper metadata:
  https://ideas.repec.org/p/yon/wpaper/2014rwp-69.html
- R `qardlr` reference manual, useful as a cross-implementation benchmark:
  https://cran.r-universe.dev/qardlr/doc/manual.html
- Galvao Jr., A. F., Montes-Rojas, G., and Park, S. Y. (2013). Quantile
  Autoregressive Distributed Lag Model with an Application to House Price
  Returns. Oxford Bulletin of Economics and Statistics, 75(2), 307-321.
  https://ideas.repec.org/a/bla/obuest/v75y2013i2p307-321.html
- Shin, Y., Yu, B., and Greenwood-Nimmo, M. (2014). Modelling Asymmetric
  Cointegration and Dynamic Multipliers in a Nonlinear ARDL Framework.
  Springer book chapter, pp. 281-314.
  https://doi.org/10.1007/978-1-4899-8008-3_9
- Chudik, A., and Pesaran, M. H. (2015). Common correlated effects estimation
  of heterogeneous dynamic panel data models with weakly exogenous regressors.
  Journal of Econometrics, 188(2), 393-420.
  https://doi.org/10.1016/j.jeconom.2015.03.007
