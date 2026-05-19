# forecastARDL

## Purpose

Computes recursive forecasts for estimated ARDL-family models.

## Format

```gauss
fcst = forecastARDL(modelOut, data);
fcst = forecastARDL(modelOut, data, h, formula);
fcst = forecastARDL(modelOut, data, h, formula, future_x);
```

## Parameters

- `modelOut` (*structure*) - Output returned by `ardl`, `qardl`, `nardl`,
  `csardl`, or the corresponding full workflow.
- `data` (*matrix or dataframe*) - Historical data used for forecast lags.
- `h` (*scalar*) - Forecast horizon. Default is `1`.
- `formula` (*string*) - Optional formula string for dataframe input.
- `future_x` (*matrix*) - Optional `h x k` future regressor path for ARDL,
  QARDL, and NARDL outputs.

## Returns

`fcst` is an `h x 1` vector for ARDL, NARDL, and CS-ARDL outputs, and an
`h x S` matrix for QARDL outputs.

## Remarks

`forecastARDL` infers the model family from the output structure and dispatches
to the matching model-specific forecast logic. For full-workflow outputs, pass
the nested estimator output such as `afOut.ar`, `qfOut.qa`, `nfOut.na`, or
`cfOut.csa`. `forecastQARDL` is preserved as a backward-compatible QARDL alias.

Future regressor levels are held fixed at their last observed values and
future contemporaneous differenced-x terms are set to zero where applicable
when `future_x` is omitted. Lagged historical differenced-x terms still enter
the first forecast periods when `q > 1`. If `future_x` is supplied, future
differenced-x terms are computed from the combined historical/future regressor
path.

CS-ARDL `future_x` panel paths are not yet supported. Forecast intervals are
not currently implemented for `forecastARDL`; see
`docs/FORECASTING_VALIDATION.md`.

## Examples

```gauss
library qardl;

qfOut = qardlFull(data, tau = { 0.25, 0.5, 0.75 }, verbose = 0);
future_x = data[rows(data), 2:cols(data)] + seqa(1, 1, 4)*(0.10~0.05);
fcst = forecastARDL(qfOut.qa, data, 4, "", future_x);
```

## Source

`ardl_dispatch.src`

## See Also

[ardl](ardl.md), [qardl](qardl.md), [nardl](nardl.md), [csardl](csardl.md),
[predictARDL](predictARDL.md), [forecastQARDL](forecastQARDL.md)
