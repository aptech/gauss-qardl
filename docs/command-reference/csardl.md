# csardl

## Purpose

Estimates a pooled cross-sectionally augmented ARDL levels model.

## Format

```gauss
csaOut = csardl(data, ppp, qqq);
csaOut = csardl(data, ppp, qqq, cs_lags, formula, print_results,
                group_var, time_var);
```

## Parameters

- `data` (*matrix or dataframe*) - Matrix input is a balanced panel stacked by
  unit in `[unit_id, y, x1, x2, ...]` order.
- `ppp` (*scalar*) - Autoregressive lag order. Must be at least `1`.
- `qqq` (*scalar*) - Distributed-lag order. May be `0`.
- `cs_lags` (*scalar*) - Cross-sectional-average lag order. Default is `0`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"` for
  dataframe input.
- `print_results` (*scalar*) - If `1`, print a formatted results table.
- `group_var` (*string*) - Optional panel identifier column name.
- `time_var` (*string*) - Optional panel time column name.

## Returns

`csaOut` is a `csardlOut` structure containing:

- `bigbt`, `bigbt_cov` - Pooled long-run coefficients and covariance.
- `gamma`, `gamma_cov`, `phi`, `phi_cov`, `cross_avg_coef` - Dynamic and
  cross-sectional-average coefficient blocks.
- `bt`, `fitted`, `resid`, `sigma2`, `coef_cov` - OLS results.
- `unit_ids`, `unit_nobs`, `nunits`, `cs_lags` - Panel metadata.
- Common formula, variable-name, sample, and design-diagnostic metadata.

## Remarks

Matrix input must be balanced and stacked by unit. For dataframe input,
`applyCSARDLFormula` sorts by panel identifier and time. If `group_var` or
`time_var` are empty, CS-ARDL uses GAUSS-style inference: the first
string/category column is the unit identifier, and the first date column is
the time variable, falling back to the first numeric column if no date column
exists.

Use `csardlECM` for CS-ARDL error-correction estimation, `csardlFull` for
lag selection plus levels and ECM estimation, and `csardlDiagnostics` for
mean-group, poolability, slope-homogeneity, and cross-sectional-dependence
diagnostics.

## Examples

```gauss
library qardl;

csaOut = csardl(panel, 2, 1, 1, "", 0);

csaFormula = csardl(df_panel, 2, 1, 1, "y ~ x1 + x2", 0,
                    "country", "year");
```

## Source

`csardl.src`

## See Also

[csardlECM](csardlECM.md), [csardlFull](csardlFull.md),
[csardlDiagnostics](csardlDiagnostics.md),
[applyCSARDLFormula](applyCSARDLFormula.md)
