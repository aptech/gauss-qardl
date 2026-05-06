# qardlECMHAC

## Purpose

Estimates QARDL-ECM with Newey-West/Bartlett HAC covariance for the ECM
intercept and speed-of-adjustment parameters.

## Format

```gauss
qECMOut = qardlECMHAC(data, ppp, qqq);
qECMOut = qardlECMHAC(data, ppp, qqq, tau, hac_lags, print_results);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `hac_lags` (*scalar*) - HAC truncation lag. Use `0` for automatic bandwidth.
- `print_results` (*scalar*) - If `1`, print a formatted table. Default is
  `1`.

## Returns

A `qardlECMOut` structure. Estimates match `qardlECM`; `alpha_cov` and
`rho_cov` use HAC sandwich covariance.

## Remarks

Equivalent to `qardlECM(data, ppp, qqq, tau, "hac", hac_lags, print_results)`.

## Examples

```gauss
qECMOut = qardlECMHAC(data, 2, 1, tau, 4);
```

## Source

`qardl.src`

## See Also

[qardlECM](qardlECM.md), [qardlECMRobust](qardlECMRobust.md)
