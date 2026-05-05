# plotQIRF

## Purpose

Plots quantile impulse response functions.

## Format

```gauss
plotQIRF(qOut);
```

## Parameters

- `qOut` (*qirfOut structure*) - Output from `qirf`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use after computing QIRFs with `qirf`.

## Examples

```gauss
qOut = qirf(qaOut, qaOut.p, qaOut.q, 20, tau);
plotQIRF(qOut);
```

## Source

`qirf.src`

## See Also

[qirf](qirf.md)
