# Published QARDL Replication Notes

This note tracks published examples that are useful for validating and
demonstrating the GAUSS QARDL library.

## Replication Inventory

| Target | Status | Notes |
| --- | --- | --- |
| Cho, Kim, and Shin (2015), U.S. dividend-policy application | Public-data scaffold added | `examples/replicate_cho_dividend_policy.e` uses the bundled Shiller real dividend and earnings data as a transparent approximation. Exact numerical replication still requires the authors' exact dataset, transformations, sample window, and lag specification. |
| Cho, Kim, Greenwood-Nimmo, and Shin (2023), asymmetric dividend response to earnings news | Candidate | Closely aligned with the bundled Shiller dividend/earnings example. Add once data and specification are confirmed. |
| Galvao, Montes-Rojas, and Park (2013), QADL house-price returns | Candidate, adjacent methodology | This is a quantile ARDL model with stationary covariates rather than the Cho-Kim-Shin quantile cointegration setup. Useful as an adjacent validation target if data are public. |
| R `qardlr` simulated QARDL dataset | Benchmark candidate | Not an empirical paper replication, but the documented simulated QARDL(2,2) DGP is useful for cross-implementation testing. |

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

## Sources

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
