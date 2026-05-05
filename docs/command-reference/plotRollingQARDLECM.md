# plotRollingQARDLECM

## Purpose

Plots rolling QARDL-ECM estimates.

## Format

```gauss
plotRollingQARDLECM(rECMOut);
plotRollingQARDLECM(rECMOut, tau, dates);
```

## Parameters

- `rECMOut` (*rollingQardlECMOut structure*) - Output from `rollingQardlECM`.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `dates` - Optional date labels. Default is `0`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use in interactive sessions after rolling ECM estimation.

## Examples

```gauss
plotRollingQARDLECM(rECMOut, tau);
```

## Source

`qardl.src`

## See Also

[rollingQardlECM](rollingQardlECM.md)
