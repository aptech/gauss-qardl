# blockBootstrapQARDLDiag

## Purpose

Computes seeded levels-form QARDL block-bootstrap confidence intervals with
simple run diagnostics.

## Format

```gauss
{ beta_ci, gamma_ci, phi_ci, diag } =
    blockBootstrapQARDLDiag(data, ppp, qqq, tau, B, blk_len, alpha, seed);
```

## Parameters

Parameters match `blockBootstrapQARDL`, with an additional `seed` scalar.

## Returns

Bootstrap confidence interval matrices plus `diag`, containing requested,
completed, and failed replication counts, block length, and seed.

## Remarks

Rank-deficient bootstrap resamples are skipped and counted in diagnostics.

## Examples

```gauss
{ beta_ci, gamma_ci, phi_ci, diag } =
    blockBootstrapQARDLDiag(data, 2, 1, tau, 499, 0, 0.05, 12345);
```

## Source

`qardl.src`

## See Also

[blockBootstrapQARDL](blockBootstrapQARDL.md)
