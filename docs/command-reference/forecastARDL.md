# forecastARDL

## Purpose

Computes recursive ARDL forecasts.

## Format

```gauss
fcst = forecastARDL(arOut, data);
fcst = forecastARDL(arOut, data, h, formula);
```

## Parameters

- `arOut` (*ardlOut struct*) - Output returned by `ardl` or `ardlFull`.
- `data` (*matrix or dataframe*) - Historical data used for forecast lags.
- `h` (*scalar*) - Forecast horizon. Default is `1`.
- `formula` (*string*) - Optional formula string for dataframe input.

## Returns

`fcst` is an `h x 1` vector of forecasts.

## Remarks

Future regressor levels are held fixed at their last observed values and
future differenced-x terms are set to zero.

TODO: Validate multi-step ARDL forecast examples against published applied
workflows before using them for publication-grade forecasting.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);
fcst = forecastARDL(arOut, data, 4);
```

## Source

`qardl.src`

## See Also

[ardl](ardl.md), [predictARDL](predictARDL.md)
