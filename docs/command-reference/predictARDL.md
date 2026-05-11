# predictARDL

## Purpose

Returns in-sample fitted values from an estimated ARDL model.

## Format

```gauss
fit = predictARDL(arOut, data);
fit = predictARDL(arOut, data, formula);
```

## Parameters

- `arOut` (*ardlOut struct*) - Output returned by `ardl` or `ardlFull`.
- `data` (*matrix or dataframe*) - Data used to build the prediction design.
- `formula` (*string*) - Optional formula string for dataframe input.

## Returns

`fit` is an `nobs x 1` vector of fitted values.

## Remarks

The prediction design is rebuilt from `arOut.p` and `arOut.qvec`, so it
supports the same lag alignment used during estimation.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);
fit = predictARDL(arOut, data);
```

## Source

`qardl.src`

## See Also

[ardl](ardl.md), [forecastARDL](forecastARDL.md)
