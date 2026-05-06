# qardlRobust

## Purpose

Estimates levels-form QARDL with heteroskedasticity-robust quantile-regression
sandwich covariance.

## Format

```gauss
qaOut = qardlRobust(data, ppp, qqq);
qaOut = qardlRobust(data, ppp, qqq, tau, print_results);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `print_results` (*scalar*) - If `1`, print a formatted table. Default is
  `1`.

## Returns

A `qardlOut` structure. Parameter estimates match `qardl`; covariance fields
use the robust sandwich estimator.

## Remarks

Equivalent to `qardl(data, ppp, qqq, tau, "robust", 0, print_results)`.

## Examples

```gauss
qaOut = qardlRobust(data, 2, 1, { 0.25, 0.5, 0.75 });
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [qardlHAC](qardlHAC.md)
