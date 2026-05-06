# qardlHAC

## Purpose

Estimates levels-form QARDL with Newey-West/Bartlett HAC quantile-regression
sandwich covariance.

## Format

```gauss
qaOut = qardlHAC(data, ppp, qqq);
qaOut = qardlHAC(data, ppp, qqq, tau, hac_lags, print_results);
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

A `qardlOut` structure. Parameter estimates match `qardl`; covariance fields
use the HAC sandwich estimator.

## Remarks

Equivalent to `qardl(data, ppp, qqq, tau, "hac", hac_lags, print_results)`.

## Examples

```gauss
qaHAC = qardlHAC(data, 2, 1, { 0.25, 0.5, 0.75 }, 4);
qaAuto = qardlHAC(data, 2, 1, { 0.25, 0.5, 0.75 }, 0);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [qardlRobust](qardlRobust.md)
