# plotQARDL

## Purpose

Plots QARDL parameter estimates across quantiles.

## Format

```gauss
plotQARDL(qaOut);
plotQARDL(qaOut, tau);
plotQARDL(qaOut, tau, show_bands, alpha);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Levels-form QARDL output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `show_bands` (*scalar*) - If `1`, plot pointwise confidence bands using
  covariance matrices stored in `qaOut`. Default is `0`.
- `alpha` (*scalar*) - Significance level for confidence bands. Default is
  `0.05`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use in interactive GAUSS sessions. Batch/headless environments may not display
plots. If `show_bands = 1`, this delegates to `plotQARDLbands`.

## Examples

```gauss
plotQARDL(qaOut, tau, 1, 0.05);
```

## Source

`qardl.src`

## See Also

[plotQARDLbands](plotQARDLbands.md), [qardl](qardl.md)
