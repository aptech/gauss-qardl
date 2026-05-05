# rollingQardl

## Purpose

Runs rolling-window levels-form QARDL estimation with user-supplied Wald-test
restrictions.

## Format

```gauss
rqaOut = rollingQardl(data, pend, qend, tau, wCtl);
```

## Parameters

- `data` - Dependent variable followed by regressors.
- `pend`, `qend` - Lag-search limits used in each rolling window.
- `tau` - Quantiles.
- `wCtl` (*waldTestRestrictions structure*) - Restriction matrices and
  right-hand-side vectors for beta, gamma/theta, and phi tests.

## Returns

`rqaOut` is a `rollingQardlOut` structure containing rolling parameter arrays,
standard errors, and rolling Wald-test results.

## Remarks

Use this for exploratory stability analysis; rolling estimates can be
computationally expensive.

## Examples

```gauss
rqaOut = rollingQardl(data, 4, 4, tau, wCtl);
plotRollingQARDL(rqaOut, tau);
```

## Source

`qardl.src`

## See Also

[plotRollingQARDL](plotRollingQARDL.md), [rollingQardlECM](rollingQardlECM.md)
