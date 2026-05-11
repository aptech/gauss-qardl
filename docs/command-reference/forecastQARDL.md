# forecastQARDL

## Purpose

Computes recursive QARDL forecasts by quantile.

## Format

```gauss
fcst = forecastQARDL(qaOut, data);
fcst = forecastQARDL(qaOut, data, h, formula);
```

## Parameters

- `qaOut` (*qardlOut struct*) - Output returned by `qardl`, `qardlRobust`,
  `qardlHAC`, or `qardlX`.
- `data` (*matrix or dataframe*) - Historical data used for forecast lags.
- `h` (*scalar*) - Forecast horizon. Default is `1`.
- `formula` (*string*) - Optional formula string for dataframe input.

## Returns

`fcst` is an `h x S` matrix of forecasts, where `S` is the number of
quantiles.

## Remarks

Future regressor levels are held fixed at their last observed values and
future differenced-x terms are set to zero.

TODO: Validate multi-step quantile forecast behavior against external QARDL
forecast references before using it for publication results.

## Examples

```gauss
library qardl;

tau = { 0.25, 0.50, 0.75 };
qaOut = qardl(data, 2, 1, tau, "iid", 0, 0);
fcst = forecastQARDL(qaOut, data, 4);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [predictQARDL](predictQARDL.md), [qirf](qirf.md)
