# ardl

## Purpose

Estimates the levels-form Autoregressive Distributed Lag model by OLS.

## Format

```gauss
arOut = ardl(data, ppp, qqq);
arOut = ardl(data, ppp, qqq, formula, print_results);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`. Formula input may use a named GAUSS dataframe.
- `ppp` (*scalar*) - Autoregressive lag order. Must be at least `1`.
- `qqq` (*scalar*) - Distributed-lag order for each regressor. May be `0`.
- `formula` (*string*) - Optional formula string such as `"y ~ x1 + x2"`.
  Default is `""`.
- `print_results` (*scalar*) - If `1`, print a formatted results table.
  Default is `1`.

## Returns

`arOut` is an `ardlOut` structure containing:

- `bigbt`, `bigbt_cov` - Long-run parameters and covariance.
- `phi`, `phi_cov` - Lagged dependent-variable parameters and covariance.
- `gamma`, `gamma_cov` - Current x-level coefficients and covariance.
- `dx_coef` - Differenced-x lag coefficients when `q > 0`.
- `alpha`, `rho` - Intercept and implied adjustment speed.
- `bt`, `fitted`, `resid`, `sigma2`, `coef_cov` - OLS results.
- `p`, `q`, `qvec`, `nobs`, `k` - Estimation metadata.

## Remarks

`ardl` is the user-facing OLS ARDL estimator. It shares the same data ordering,
lag validation, formula handling, print conventions, and downstream
prediction/forecast style as the QARDL family.

## Examples

```gauss
library qardl;

data = loadd("qardl_data.dat");
arOut = ardl(data, 2, 1, "", 0);
printARDL(arOut);

fit = predictARDL(arOut, data);
fcst = forecastARDL(arOut, data, 4);
```

## Source

`qardl.src`

## See Also

[ardlFull](ardlFull.md), [printARDL](printARDL.md),
[predictARDL](predictARDL.md), [forecastARDL](forecastARDL.md),
[qardl](qardl.md)
