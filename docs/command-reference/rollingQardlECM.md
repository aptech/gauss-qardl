# rollingQardlECM

## Purpose

Runs rolling-window QARDL-ECM estimation.

## Format

```gauss
rECMOut = rollingQardlECM(data, ppp, qqq);
rECMOut = rollingQardlECM(data, ppp, qqq, tau);
rECMOut = rollingQardlECM(data, ppp, qqq, tau, ecm_type);
```

## Parameters

- `data` - Dependent variable followed by regressors.
- `ppp`, `qqq` - Lag orders.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `ecm_type` - `"two-step"` (default) for the restricted two-stage ECM or
  `"uecm"` for the unrestricted ECM.

## Returns

`rECMOut` is a `rollingQardlECMOut` structure containing `ecm_type`, rolling
alpha, rho, standard errors, long-run coefficients, and OLS rho.

## Remarks

Rolling ECM windows are useful for studying time variation in adjustment speed.
For `"two-step"`, `beta_lr` is `num_est x k`. For `"uecm"`, `beta_lr` is
`num_est x (k*rows(tau))`, stacked by quantile and then regressor within each
window.

## Examples

```gauss
rECMOut = rollingQardlECM(data, 2, 1, tau);
rUECMOut = rollingQardlECM(data, 2, 1, tau, "uecm");
plotRollingQARDLECM(rECMOut, tau);
```

## Source

`qardl.src`

## See Also

[plotRollingQARDLECM](plotRollingQARDLECM.md), [qardlECM](qardlECM.md)
