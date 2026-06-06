# plotQARDLbands

## Purpose

Plots QARDL parameter estimates with confidence bands across quantiles.

## Format

```gauss
plotQARDLbands(qaOut);
plotQARDLbands(qaOut, tau);
plotQARDLbands(qaOut, tau, alpha);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Levels-form QARDL output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `alpha` (*scalar*) - Significance level for pointwise bands. Default is
  `0.05`.

## Returns

Nothing. Produces GAUSS plots.

## Remarks

Confidence bands are computed from the covariance matrices stored in `qaOut`.
No uncertainty is recomputed inside the plotting helper. The standard-error
normalization matches `printQARDL`, `qardl_pval`, and the published QARDL
author-demo validation tables. For the original iid levels-form QARDL
covariance path with `q > 0`, this applies the author-demo scaling before
forming pointwise normal bands.

These are coefficient-path bands over `tau`; they are not QIRF bootstrap bands.
Use `blockBootstrapQIRF` followed by `plotQIRF(qOut, 1)` for impulse-response
bands over forecast horizons.

## Examples

```gauss
plotQARDLbands(qaOut, tau, 0.05);
```

## Source

`qardl.src`

## See Also

[plotQARDL](plotQARDL.md), [blockBootstrapQARDL](blockBootstrapQARDL.md)
