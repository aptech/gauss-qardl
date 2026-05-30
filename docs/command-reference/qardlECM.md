# qardlECM

## Purpose

Estimates the QARDL error-correction model.

## Format

```gauss
qECMOut = qardlECM(data, ppp, qqq);
qECMOut = qardlECM(data, ppp, qqq, tau, cov_type, hac_lags, print_results);
qECMOut = qardlECM(data, ppp, qqq, tau, cov_type, hac_lags,
                   print_results, ecm_type);
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
- `ecm_type` (*string*) - `"two-step"` (default) for the restricted two-stage
  ECM, or `"uecm"` for the unrestricted ECM.

## Returns

`qECMOut` is a `qardlECMOut` structure containing:

- `ecm_type` - `"two-step"` or `"uecm"`.
- `beta_lr` - Long-run coefficients. For `"two-step"` these are the OLS
  first-stage long-run coefficients; for `"uecm"` they are quantile-specific
  long-run coefficients derived from the unrestricted lagged-level terms.
- `rho_ols` - OLS speed of adjustment.
- `alpha`, `alpha_cov` - ECM intercept estimates and covariance.
- `rho`, `rho_cov` - Quantile ECM speed-of-adjustment estimates and covariance.
- `tau`, `p`, `q`, `nobs`, `k` - Estimation metadata.

## Remarks

Direct calls print results by default. Pass `print_results = 0` for scripts,
tests, simulations, rolling windows, and other workflows that only need the
returned structure. The default two-step ECM uses an OLS first-stage long-run
relationship and a quantile second-stage error-correction equation. The
unrestricted ECM estimates `y(-1)` and the lagged level regressors directly in
the quantile ECM equation and derives long-run coefficients as `-theta / rho`.

## Examples

```gauss
qECMOut = qardlECM(data, 2, 1, tau, "hac", 0);
qUECMOut = qardlECM(data, 2, 1, tau, "iid", 0, 0, "uecm");
printQARDLECM(qECMOut, tau);
```

## Source

`qardl.src`

## See Also

[qardlFull](qardlFull.md), [qardlECMRobust](qardlECMRobust.md),
[qardlECMHAC](qardlECMHAC.md), [qardlECMX](qardlECMX.md)
