# plotQARDLbands

## Purpose

Plots QARDL parameter estimates with confidence bands across quantiles.

## Format

```gauss
plotQARDLbands(qaOut);
plotQARDLbands(qaOut, tau);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Levels-form QARDL output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Confidence bands are computed from the covariance matrices stored in `qaOut`.

## Examples

```gauss
plotQARDLbands(qaOut, tau);
```

## Source

`qardl.src`

## See Also

[plotQARDL](plotQARDL.md), [blockBootstrapQARDL](blockBootstrapQARDL.md)
