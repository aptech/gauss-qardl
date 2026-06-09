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
- `show_bands` (*scalar*) - If `1`, plot confidence bands stored in `qOut`.
  Default is `0`.
- `alpha` (*scalar*) - Significance level for requested bands. Default is
  `0.05`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Use after computing QIRFs with `qirf` or `blockBootstrapQIRF`. Bands produced
by `blockBootstrapQIRF` are pointwise percentile bootstrap bands. If
`show_bands = 1` but `qOut.bands_available` is `0`, the response paths are
plotted without bands.

For one to four quantiles, `plotQIRF` uses the standard single-row layout. For
five or more quantiles, it automatically switches to a compact grid layout
with shared x- and y-axis ranges across quantile panels.

## Examples

```gauss
qOut = blockBootstrapQIRF(data, qaOut.p, qaOut.q, 20, tau, 1, 1, 499, 0, 0.05, 12345);
plotQIRF(qOut, 1);
```

## Source

`qirf.src`

## See Also

[qirf](qirf.md), [blockBootstrapQIRF](blockBootstrapQIRF.md)
