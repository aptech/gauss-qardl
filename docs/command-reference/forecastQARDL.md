# forecastQARDL

## Purpose

Computes recursive QARDL forecasts by quantile.

## Format

```gauss
fcst = forecastQARDL(qaOut, data);
fcst = forecastQARDL(qaOut, data, h, formula);
fcst = forecastQARDL(qaOut, data, h, formula, future_x);
```

## Parameters

- `qaOut` (*qardlOut struct*) - Output returned by `qardl`, `qardlRobust`,
  `qardlHAC`, or `qardlX`.
- `data` (*matrix or dataframe*) - Historical data used for forecast lags.
- `h` (*scalar*) - Forecast horizon. Default is `1`.
- `formula` (*string*) - Optional formula string for dataframe input.
- `future_x` (*matrix*) - Optional `h x k` future regressor path.

## Returns

`fcst` is an `h x S` matrix of forecasts, where `S` is the number of
quantiles.

## Remarks

Future regressor levels are held fixed at their last observed values and
future differenced-x terms are set to zero.

`forecastQARDL` is retained for backward compatibility. New code may call the
unified `forecastARDL(qaOut, data, ...)` dispatcher instead.

When `future_x` is omitted, future regressor levels are held fixed at the last
observed value. If supplied, `future_x` is used to compute future levels and
differenced-regressor terms.

TODO: Validate multi-step quantile forecast behavior against external QARDL
forecast references before using it for publication results.

## Examples

```gauss
library qardl;

tau = { 0.25, 0.50, 0.75 };
qaOut = qardl(data, 2, 1, tau, "iid", 0, 0);
future_x = data[rows(data), 2:cols(data)] + seqa(1, 1, 4)*(0.10~0.05);
fcst = forecastQARDL(qaOut, data, 4, "", future_x);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [forecastARDL](forecastARDL.md),
[predictQARDL](predictQARDL.md), [qirf](qirf.md)
