# plotRollingQARDL

## Purpose

Plots rolling levels-form QARDL estimates.

## Format

```gauss
plotRollingQARDL(rqaOut);
plotRollingQARDL(rqaOut, tau, dates);
plotRollingQARDL(rqaOut, tau, dates, show_bands, alpha);
```

## Parameters

- `rqaOut` (*rollingQardlOut structure*) - Output from `rollingQardl`.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `dates` - Optional date labels. Default is `0`.
- `show_bands` (*scalar*) - If `1`, show pointwise bands from rolling
  standard errors. Default is `1`.
- `alpha` (*scalar*) - Significance level for bands. Default is `0.05`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use in interactive sessions after rolling estimation. Bands are shown only
from standard-error fields already stored in `rqaOut`.

## Examples

```gauss
plotRollingQARDL(rqaOut, tau, 0, 1, 0.05);
```

## Source

`qardl.src`

## See Also

[rollingQardl](rollingQardl.md)
