# plotRollingQARDL

## Purpose

Plots rolling levels-form QARDL estimates.

## Format

```gauss
plotRollingQARDL(rqaOut);
plotRollingQARDL(rqaOut, tau, dates);
```

## Parameters

- `rqaOut` (*rollingQardlOut structure*) - Output from `rollingQardl`.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `dates` - Optional date labels. Default is `0`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use in interactive sessions after rolling estimation.

## Examples

```gauss
plotRollingQARDL(rqaOut, tau);
```

## Source

`qardl.src`

## See Also

[rollingQardl](rollingQardl.md)
