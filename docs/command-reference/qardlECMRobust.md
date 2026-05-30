# qardlECMRobust

## Purpose

Estimates QARDL-ECM with heteroskedasticity-robust covariance for the ECM
intercept and speed-of-adjustment parameters.

## Format

```gauss
qECMOut = qardlECMRobust(data, ppp, qqq);
qECMOut = qardlECMRobust(data, ppp, qqq, tau, print_results);
qECMOut = qardlECMRobust(data, ppp, qqq, tau, print_results, ecm_type);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `print_results` (*scalar*) - If `1`, print a formatted table. Default is
  `1`.
- `ecm_type` (*string*) - `"two-step"` (default) or `"uecm"`.

## Returns

A `qardlECMOut` structure. Estimates match `qardlECM`; `alpha_cov` and
`rho_cov` use robust sandwich covariance.

## Remarks

Equivalent to
`qardlECM(data, ppp, qqq, tau, "robust", 0, print_results, ecm_type)`.

## Examples

```gauss
qECMOut = qardlECMRobust(data, 2, 1, tau);
```

## Source

`qardl.src`

## See Also

[qardlECM](qardlECM.md), [qardlECMHAC](qardlECMHAC.md)
