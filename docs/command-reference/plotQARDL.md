# plotQARDL

## Purpose

Plots QARDL parameter estimates across quantiles.

## Format

```gauss
plotQARDL(qaOut);
plotQARDL(qaOut, tau);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Levels-form QARDL output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use in interactive GAUSS sessions. Batch/headless environments may not display
plots.

## Examples

```gauss
plotQARDL(qaOut, tau);
```

## Source

`qardl.src`

## See Also

[plotQARDLbands](plotQARDLbands.md), [qardl](qardl.md)
