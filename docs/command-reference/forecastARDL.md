# forecastARDL

## Purpose

Computes recursive forecasts for estimated ARDL-family models.

## Format

```gauss
fcst = forecastARDL(modelOut, data);
fcst = forecastARDL(modelOut, data, h, formula);
```

## Parameters

- `modelOut` (*structure*) - Output returned by `ardl`, `qardl`, `nardl`,
  `csardl`, or the corresponding full workflow.
- `data` (*matrix or dataframe*) - Historical data used for forecast lags.
- `h` (*scalar*) - Forecast horizon. Default is `1`.
- `formula` (*string*) - Optional formula string for dataframe input.

## Returns

`fcst` is an `h x 1` vector for ARDL, NARDL, and CS-ARDL outputs, and an
`h x S` matrix for QARDL outputs.

## Remarks

`forecastARDL` infers the model family from the output structure and dispatches
to the matching model-specific forecast logic. `forecastQARDL` is preserved as
a backward-compatible QARDL alias.

Future regressor levels are held fixed at their last observed values and
future differenced-x terms are set to zero where applicable.

TODO: Validate multi-step ARDL forecast examples against published applied
workflows before using them for publication-grade forecasting.

## Examples

```gauss
library qardl;

qfOut = qardlFull(data, tau = { 0.25, 0.5, 0.75 }, verbose = 0);
fcst = forecastARDL(qfOut.qa, data, 4);
```

## Source

`ardl_dispatch.src`

## See Also

[ardl](ardl.md), [qardl](qardl.md), [nardl](nardl.md), [csardl](csardl.md),
[predictARDL](predictARDL.md), [forecastQARDL](forecastQARDL.md)
