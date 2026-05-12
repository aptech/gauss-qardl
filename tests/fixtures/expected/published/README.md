# Published Expected Outputs

Published-result and published-reference fixtures live here.

Active fixtures:

- `ardl_bounds_pss_selected_cv.csv`: selected Pesaran-Shin-Smith bounds
  critical values.
- `qardl_author_demo1_*.csv` and `qardl_author_demo2_*.csv`: author-provided
  QARDL GAUSS demo outputs for Cho, Kim, and Shin (2015).

Before adding a numerical expected-output file, document:

1. the paper and target table/figure;
2. the raw data source and redistribution status;
3. all transformations and sample windows;
4. lag choices, deterministic terms, covariance assumptions, and quantiles;
5. the tolerance implied by publication rounding or independent reproduction.

Pending targets are tracked in `tests/fixtures/fixture_manifest.csv` and
`docs/PUBLISHED_REPLICATIONS.md`.
