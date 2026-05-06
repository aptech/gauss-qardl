# qardlECM

## Purpose

Estimates the two-step QARDL error-correction model.

## Format

```gauss
qECMOut = qardlECM(data, ppp, qqq);
qECMOut = qardlECM(data, ppp, qqq, tau, cov_type, hac_lags, print_results);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `cov_type` (*string*) - `"iid"`, `"robust"`, or `"hac"`. Default is
  `"iid"`.
- `hac_lags` (*scalar*) - HAC truncation lag. Use `0` for automatic bandwidth.
- `print_results` (*scalar*) - If `1`, print a formatted GAUSS-style results
  table after estimation. If `0`, return results silently. Default is `1`.

## Returns

`qECMOut` is a `qardlECMOut` structure containing:

- `beta_lr` - OLS long-run coefficients used to construct the error-correction
  term.
- `rho_ols` - OLS speed of adjustment.
- `alpha`, `alpha_cov` - ECM intercept estimates and covariance.
- `rho`, `rho_cov` - Quantile ECM speed-of-adjustment estimates and covariance.
- `tau`, `p`, `q`, `nobs`, `k` - Estimation metadata.

## Remarks

Direct calls print results by default. Pass `print_results = 0` for scripts,
tests, simulations, rolling windows, and other workflows that only need the
returned structure. The ECM estimator uses an OLS first-stage long-run
relationship and a quantile second-stage error-correction equation.

## Examples

```gauss
qECMOut = qardlECM(data, 2, 1, tau, "hac", 0);
printQARDLECM(qECMOut, tau);
```

## Source

`qardl.src`

## See Also

[qardlFull](qardlFull.md), [qardlECMRobust](qardlECMRobust.md),
[qardlECMHAC](qardlECMHAC.md), [qardlECMX](qardlECMX.md)
