# qirf

## Purpose

Computes quantile impulse response functions from levels-form QARDL estimates.

## Format

```gauss
qOut = qirf(qaOut, ppp, qqq, H);
qOut = qirf(qaOut, ppp, qqq, H, tau, k_x, permanent);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Output from `qardl` or related levels-form
  estimator.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `H` (*scalar*) - Maximum response horizon.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `k_x` (*scalar*) - Index of the shocked regressor. Default is `1`.
- `permanent` (*scalar*) - `1` for permanent unit shock, `0` for temporary
  one-period shock. Default is `1`.

## Returns

`qOut` is a `qirfOut` structure with fields:

- `irf` - `(H+1)xS` response matrix.
- `irf_lb`, `irf_ub` - Pointwise confidence-band matrices. These are zero
  placeholders from `qirf` and populated by `blockBootstrapQIRF`.
- `tau` - Quantiles.
- `H` - Maximum horizon.
- `k_x` - Shocked regressor index.
- `permanent` - Shock type.
- `bands_available` - `1` when `irf_lb` and `irf_ub` contain usable bands.
- `alpha` - Tail probability used for bands.
- `boot_diag` - Bootstrap diagnostics.

## Remarks

QIRFs are computed from the estimated QARDL dynamic coefficients. For
per-regressor q-vector models, pass the maximum distributed lag stored in the
`qardlOut.q` metadata field.

Use `blockBootstrapQIRF` when confidence bands are needed.

## Examples

```gauss
qaOut = qardl(data, 2, 1, tau);
qOut = qirf(qaOut, qaOut.p, qaOut.q, 20, tau, 1, 1);
plotQIRF(qOut);

qBandOut = blockBootstrapQIRF(data, qaOut.p, qaOut.q, 20, tau, 1, 1,
                              499, 0, 0.05, 12345);
plotQIRF(qBandOut, 1);
```

## Source

`qirf.src`

## See Also

[qardl](qardl.md), [blockBootstrapQIRF](blockBootstrapQIRF.md),
[plotQIRF](plotQIRF.md)
