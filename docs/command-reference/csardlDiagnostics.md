# csardlDiagnostics

## Purpose

Computes optional mean-group, poolability, Pesaran-Yamagata slope
homogeneity, and Pesaran CD cross-sectional dependence diagnostics for
CS-ARDL models.

## Format

```gauss
diagOut = csardlDiagnostics(data, ppp, qqq);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula, print_results);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula, print_results,
                            group_var, time_var);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula, print_results,
                            group_var, time_var, cd_order);
```

## Parameters

`data` is a balanced panel stacked by unit in `[unit_id, y, x1, ...]` order,
or a GAUSS dataframe used with the formula interface. Unbalanced panels are
not supported in the current implementation.

`ppp` is the scalar AR lag order.

`qqq` is the scalar distributed-lag order.

`cs_lags` is the scalar cross-sectional-average lag order.

`formula` is an optional string. For dataframe input, prefer `"y ~ x1 + x2"`;
CS-ARDL infers the panel unit and time variables using GAUSS panel-data
conventions. Formula strings do not include explicit unit/time terms.

`print_results` controls whether `printCSARDLDiagnostics` is called.

`group_var` is an optional panel group variable name for dataframe input. The
default is `""`, which uses GAUSS-style inference.

`time_var` is an optional panel time variable name for dataframe input. The
default is `""`, which uses GAUSS-style inference.

`cd_order` controls the Pesaran CD residual-pair set. The default `-1` uses
all unit pairs. A positive integer computes fixed-order `CD(p)` using only
unit pairs with index distance less than or equal to `cd_order`.

## Returns

`diagOut`, a `csardlDiagOut` structure containing unit-specific long-run
coefficients, unit-specific full coefficient vectors, mean-group long-run
coefficients and standard errors, pooled long-run coefficients, a Wald-style
poolability statistic, a Wald-style long-run slope heterogeneity statistic,
Pesaran-Yamagata delta tests, and Pesaran CD residual cross-sectional
dependence diagnostics.

## Remarks

The diagnostic estimator fits the same cross-sectionally augmented ARDL design
separately for each unit. The poolability statistic compares unit-specific
long-run coefficients with the pooled CS-ARDL long-run coefficients using the
unit-specific delta-method covariance matrices.

The long-run slope heterogeneity statistic compares unit-specific long-run
coefficients with the mean-group long-run coefficients using the same
unit-specific covariance matrices. The reported fields are
`slope_hetero_wald`, `slope_hetero_df`, and `slope_hetero_pv`.

The Pesaran-Yamagata fields report standardized Swamy-style slope homogeneity
tests. `py_swamystat`, `py_delta`, `py_delta_pv`, `py_delta_adj`,
`py_delta_adj_pv`, and `py_k` use the direct CS-ARDL dynamic slope vector,
excluding the intercept and cross-sectional-average controls. The long-run
counterparts `py_lr_swamystat`, `py_lr_delta`, `py_lr_delta_pv`,
`py_lr_delta_adj`, `py_lr_delta_adj_pv`, and `py_lr_k` apply the same delta
standardization to the CS-ARDL long-run coefficients using their delta-method
covariance matrices.

The Pesaran CD diagnostic is computed from the balanced matrix of unit-level
residuals returned by the same unit-specific diagnostic regressions. The
reported fields are `cd_stat`, `cd_pv`, `cd_pairs`, `cd_avg_corr`,
`cd_avg_abs_corr`, `cd_order`, `cd_min_t`, and `cd_max_t`. `cd_min_t` and
`cd_max_t` report the minimum and maximum pairwise common residual counts used
by the CD calculation; for the current balanced CS-ARDL estimator these match
`unit_nobs`.

This is a diagnostic layer for the CS-ARDL implementation. The
Pesaran-Yamagata tests are asymptotic slope homogeneity diagnostics; interpret
them together with the Pesaran CD result, especially when residual
cross-sectional dependence remains material after cross-sectional-average
augmentation.

Deterministic validation recomputes mean-group coefficients, mean-group
standard errors, the poolability Wald statistic, the slope heterogeneity Wald
statistic, the Pesaran-Yamagata delta tests, all-pairs Pesaran CD, and
fixed-order `CD(1)` from unit-specific fits.

## References

- Pesaran, M. H. (2004). General diagnostic tests for cross section dependence
  in panels. SSRN Electronic Journal. https://doi.org/10.2139/ssrn.572504
- Pesaran, M. H., and Yamagata, T. (2008). Testing slope homogeneity in large
  panels. *Journal of Econometrics*, 142(1), 50-93.
  https://doi.org/10.1016/j.jeconom.2007.05.010

## Source

`csardl.src`

## See Also

[printCSARDLDiagnostics](printCSARDLDiagnostics.md), [csardl](csardl.md),
[csardlFull](csardlFull.md), [nardl](nardl.md)
