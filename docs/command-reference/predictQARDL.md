# predictQARDL

## Purpose

Returns in-sample fitted values from an estimated QARDL model.

## Format

```gauss
fit = predictQARDL(qaOut, data);
fit = predictQARDL(qaOut, data, formula);
```

## Parameters

- `qaOut` (*qardlOut struct*) - Output returned by `qardl`, `qardlRobust`,
  `qardlHAC`, or `qardlX`.
- `data` (*matrix or dataframe*) - Data used to build the prediction design.
- `formula` (*string*) - Optional formula string for dataframe input.

## Returns

`fit` is an `nobs x S` matrix of fitted values, where `S` is the number of
quantiles.

## Remarks

The prediction design is rebuilt from `qaOut.p` and `qaOut.qvec`, preserving
scalar-q and per-regressor-q QARDL workflows.

## Examples

```gauss
library qardl;

tau = { 0.25, 0.50, 0.75 };
qaOut = qardl(data, 2, 1, tau, "iid", 0, 0);
fit = predictQARDL(qaOut, data);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [forecastQARDL](forecastQARDL.md), [qardlX](qardlX.md)
