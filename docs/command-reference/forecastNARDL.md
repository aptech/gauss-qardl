# forecastNARDL

## Purpose

Computes recursive point forecasts from a NARDL levels model.

## Format

```gauss
fcst = forecastNARDL(naOut, data);
fcst = forecastNARDL(naOut, data, h, formula, future_x);
```

## Parameters

- `naOut` (*nardlOut structure*) - Output from `nardl` or `nardlFull.na`.
- `data` (*matrix or dataframe*) - Estimation data.
- `h` (*scalar*) - Forecast horizon. Default is `1`.
- `formula` (*string*) - Optional formula. If omitted, `naOut.formula` is
  reused when present.
- `future_x` (*h x k matrix*) - Optional future regressor path. If omitted,
  the final observed regressor values are held fixed.

## Returns

`fcst`, an `h x 1` forecast vector.

## Remarks

Forecasts are point forecasts. Forecast intervals are not yet implemented.
`forecastARDL` dispatches to this path when passed a `nardlOut` structure.

## Examples

```gauss
naOut = nardl(data, 2, 1, "", 0);
fcst = forecastNARDL(naOut, data, 4);
```

## Source

`nardl.src`

## See Also

[predictNARDL](predictNARDL.md), [forecastARDL](forecastARDL.md),
[nardl](nardl.md)
