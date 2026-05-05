# rollingQardlECM

## Purpose

Runs rolling-window two-step QARDL-ECM estimation.

## Format

```gauss
rECMOut = rollingQardlECM(data, ppp, qqq);
rECMOut = rollingQardlECM(data, ppp, qqq, tau);
```

## Parameters

- `data` - Dependent variable followed by regressors.
- `ppp`, `qqq` - Lag orders.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.

## Returns

`rECMOut` is a `rollingQardlECMOut` structure containing rolling alpha, rho,
standard errors, OLS long-run coefficients, and OLS rho.

## Remarks

Rolling ECM windows are useful for studying time variation in adjustment speed.

## Examples

```gauss
rECMOut = rollingQardlECM(data, 2, 1, tau);
plotRollingQARDLECM(rECMOut, tau);
```

## Source

`qardl.src`

## See Also

[plotRollingQARDLECM](plotRollingQARDLECM.md), [qardlECM](qardlECM.md)
