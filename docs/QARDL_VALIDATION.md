# QARDL Validation

This note tracks the current QARDL validation status separately from the broader
ARDL-family benchmark registry.

## Active Reference Targets

### Author GAUSS Demo

`published-qardl-author-demo1` validates against the author-provided GAUSS demo
archive linked from Jin Seo Cho's QARDL page for Cho, Kim, and Shin (2015).

Validation case:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1 -IncludePublished
```

Files:

- `tests/validation_cases/published/qardl_author_demo1.e`
- `tests/fixtures/expected/published/qardl_author_demo1_*.csv`
- `tests/fixtures/expected/published/qardl_author_demo2_*.csv`

Specification:

- Data: `examples/qardl_data.dat`, columns 1:3.
- Variables: first column is `y`; columns 2 and 3 are regressors.
- Lag search: BIC over `pend = 7`, `qend = 7`.
- Selected order: `p = 2`, `q = 1`.
- Quantiles: `0.25`, `0.50`, `0.75` for demo 1; `0.50` for demo 2.
- Covariance: original/iid QARDL covariance.

Validated outputs:

- selected `p` and `q`;
- long-run beta estimates and covariance;
- short-run phi estimates and covariance;
- short-run gamma estimates and covariance;
- author-demo Wald tests and p-values;
- median-quantile coefficient, standard-error, t-statistic, and p-value tables.

This is a published-reference software validation target. It is not the exact
empirical dividend-policy table replication from the journal article.

### QARDL Bootstrap Intervals

`synthetic-qardl-bootstrap` validates deterministic bootstrap interval output
for the QARDL implementation.

Specification:

- Data: first 250 rows of `examples/qardl_data.dat`.
- Model: `p = 1`, `q = 1`.
- Quantiles: `0.25`, `0.50`, `0.75`.
- Bootstrap: block size `2`, `B = 10`, `alpha = 0.10`, seed `12345`.

Stored outputs:

- `tests/fixtures/expected/synthetic/intervals/qardl_bootstrap_ci_beta.csv`
- `tests/fixtures/expected/synthetic/intervals/qardl_bootstrap_ci_gamma.csv`
- `tests/fixtures/expected/synthetic/intervals/qardl_bootstrap_ci_phi.csv`
- `tests/fixtures/expected/synthetic/intervals/qardl_bootstrap_diag.csv`

This is an implementation-drift fixture, not an external published interval
benchmark.

## Pending Exact Empirical Replication

The exact Cho, Kim, and Shin (2015) U.S. dividend-policy empirical replication
remains pending.

Before marking the empirical replication complete, document:

1. raw data source and redistribution status;
2. dependent variable and regressor definitions;
3. transformations and frequency conversion;
4. exact sample window;
5. deterministic terms and bounds-test case;
6. fixed lag order or lag-selection rule;
7. quantile grid and covariance assumptions;
8. target paper tables or figures;
9. expected coefficients, standard errors, Wald tests, bounds tests, long-run
   estimates, and any interval outputs.

## Cross-Implementation Validation

The R `qardlr` package is tracked as a candidate cross-implementation benchmark.
Do not add a pass/fail claim until the R data-generating process, lag-selection
defaults, covariance definitions, and parameter stacking conventions are matched
to the GAUSS implementation.

## Known Differences And Notes

- The current GAUSS library uses built-in `quantileFit`; the original GAUSS
  demo used the older Qreg library with documented source edits.
- The author demo readme reports printed table values rounded to display
  precision, so table validations use a wider tolerance than stored full
  coefficient vectors.
- The package does not redistribute the downloaded author archives; validation
  uses expected outputs and the bundled demo dataset already present in
  `examples/`.

