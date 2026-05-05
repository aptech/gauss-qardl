# qardl

## Purpose

Estimates the levels-form Quantile Autoregressive Distributed Lag model.

## Format

```gauss
qaOut = qardl(data, ppp, qqq);
qaOut = qardl(data, ppp, qqq, tau);
qaOut = qardl(data, ppp, qqq, tau, cov_type, hac_lags);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Column 1 is the dependent variable and columns
  2 through `k+1` are regressors.
- `ppp` (*scalar*) - Autoregressive lag order. Must be at least `1`.
- `qqq` (*scalar*) - Distributed-lag order for each regressor. May be `0`.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `cov_type` (*string*) - `"iid"`, `"robust"`, or `"hac"`. Default is
  `"iid"`.
- `hac_lags` (*scalar*) - HAC truncation lag. Use `0` for automatic bandwidth.
  Default is `0`.

## Returns

`qaOut` is a `qardlOut` structure containing:

- `bigbt`, `bigbt_cov` - Long-run parameters and covariance.
- `phi`, `phi_cov` - Lagged dependent-variable parameters and covariance.
- `gamma`, `gamma_cov` - Current x-level coefficients and covariance.
- `alpha`, `rho` - Derived intercept and ECM adjustment speed by quantile.
- `bt` - Full quantile-regression coefficient matrix.
- `tau`, `p`, `q`, `nobs`, `k` - Estimation metadata.

## Remarks

Use `qardlRobust` and `qardlHAC` as convenience wrappers for robust and HAC
covariance estimates. For per-regressor distributed lags, use `qardlX`.

## Examples

```gauss
library qardl;

data = loadd("qardl_data.dat");
tau = { 0.25, 0.50, 0.75 };

qaOut = qardl(data, 2, 1, tau, "robust", 0);
printQARDL(qaOut, tau);
```

## Source

`qardl.src`

## See Also

[qardlFull](qardlFull.md), [qardlRobust](qardlRobust.md),
[qardlHAC](qardlHAC.md), [qardlX](qardlX.md), [qardl_pval](qardl_pval.md)
