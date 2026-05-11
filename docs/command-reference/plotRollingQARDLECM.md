# plotRollingQARDLECM

## Purpose

Plots rolling QARDL-ECM estimates.

## Format

```gauss
plotRollingQARDLECM(rECMOut);
plotRollingQARDLECM(rECMOut, tau, dates);
plotRollingQARDLECM(rECMOut, tau, dates, show_bands, alpha);
```

## Parameters

- `rECMOut` (*rollingQardlECMOut structure*) - Output from `rollingQardlECM`.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `dates` - Optional date labels. Default is `0`.
- `show_bands` (*scalar*) - If `1`, show pointwise bands from rolling
  standard errors. Default is `1`.
- `alpha` (*scalar*) - Significance level for bands. Default is `0.05`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use in interactive sessions after rolling ECM estimation. Bands are shown only
from standard-error fields already stored in `rECMOut`.

## Examples

```gauss
plotRollingQARDLECM(rECMOut, tau, 0, 1, 0.05);
```

## Source

`qardl.src`

## See Also

[rollingQardlECM](rollingQardlECM.md)
