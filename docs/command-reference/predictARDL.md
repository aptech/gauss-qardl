# predictARDL

## Purpose

Returns in-sample fitted values from an estimated ARDL-family model.

## Format

```gauss
fit = predictARDL(modelOut, data);
fit = predictARDL(modelOut, data, formula);
fit = predictARDL(modelOut, data, formula, group_var, time_var);
```

## Parameters

- `modelOut` (*structure*) - Output returned by `ardl`, `qardl`, `nardl`,
  `csardl`, or the corresponding full workflow.
- `data` (*matrix or dataframe*) - Data used to build the prediction design.
- `formula` (*string*) - Optional formula string for dataframe input.
- `group_var` (*string*) - Optional CS-ARDL panel group variable name. The
  default `""` uses GAUSS-style inference.
- `time_var` (*string*) - Optional CS-ARDL panel time variable name. The
  default `""` uses GAUSS-style inference.

## Returns

`fit` is an `nobs x 1` vector for ARDL, NARDL, and CS-ARDL outputs, and an
`nobs x S` matrix for QARDL outputs.

## Remarks

`predictARDL` infers the model family from the output structure and dispatches
to the matching model-specific prediction logic. `predictQARDL` is preserved as
a backward-compatible QARDL alias.

`group_var` and `time_var` are used only for CS-ARDL dataframe formula input.

## Examples

```gauss
library qardl;

qfOut = qardlFull(data, tau = { 0.25, 0.5, 0.75 }, verbose = 0);
fit = predictARDL(qfOut.qa, data);
```

## Source

`ardl_dispatch.src`

## See Also

[ardl](ardl.md), [qardl](qardl.md), [nardl](nardl.md), [csardl](csardl.md),
[forecastARDL](forecastARDL.md), [predictQARDL](predictQARDL.md)
