# predictNARDL

## Purpose

Returns in-sample fitted values from a NARDL levels model.

## Format

```gauss
fit = predictNARDL(naOut, data);
fit = predictNARDL(naOut, data, formula);
```

## Parameters

- `naOut` (*nardlOut structure*) - Output from `nardl` or `nardlFull.na`.
- `data` (*matrix or dataframe*) - Estimation data.
- `formula` (*string*) - Optional formula. If omitted, `naOut.formula` is
  reused when present.

## Returns

`fit`, an `nobs x 1` vector of fitted values.

## Remarks

`predictARDL` dispatches to the same NARDL fitted-value path when passed a
`nardlOut` structure.

## Examples

```gauss
naOut = nardl(df, 2, 1, "y ~ x1 + x2", 0);
fit = predictNARDL(naOut, df);
```

## Source

`nardl.src`

## See Also

[nardl](nardl.md), [forecastNARDL](forecastNARDL.md), [predictARDL](predictARDL.md)
