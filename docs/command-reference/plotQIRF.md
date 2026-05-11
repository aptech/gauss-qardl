# plotQIRF

## Purpose

Plots quantile impulse response functions.

## Format

```gauss
plotQIRF(qOut);
plotQIRF(qOut, show_bands, alpha);
```

## Parameters

- `qOut` (*qirfOut structure*) - Output from `qirf`.
- `show_bands` (*scalar*) - If `1`, request confidence-band display.
  Default is `0`.
- `alpha` (*scalar*) - Significance level for requested bands. Default is
  `0.05`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use after computing QIRFs with `qirf`. `qirfOut` does not currently store
confidence-band information, so `show_bands = 1` prints a message and plots
the response paths only.

## Examples

```gauss
qOut = qirf(qaOut, qaOut.p, qaOut.q, 20, tau);
plotQIRF(qOut, 1);
```

## Source

`qirf.src`

## See Also

[qirf](qirf.md)
