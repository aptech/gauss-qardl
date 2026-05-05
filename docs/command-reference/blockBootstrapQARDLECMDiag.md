# blockBootstrapQARDLECMDiag

## Purpose

Computes seeded QARDL-ECM block-bootstrap confidence intervals with simple run
diagnostics.

## Format

```gauss
{ rho_ci, alpha_ci, diag } =
    blockBootstrapQARDLECMDiag(data, ppp, qqq, tau, B, blk_len, alpha, seed);
```

## Parameters

Parameters match `blockBootstrapQARDLECM`, with an additional `seed` scalar.

## Returns

Bootstrap confidence interval matrices plus `diag`, containing requested,
completed, and failed replication counts, block length, and seed.

## Remarks

Rank-deficient bootstrap resamples are skipped and counted in diagnostics.

## Examples

```gauss
{ rho_ci, alpha_ci, diag } =
    blockBootstrapQARDLECMDiag(data, 2, 1, tau, 499, 0, 0.05, 12345);
```

## Source

`qardl.src`

## See Also

[blockBootstrapQARDLECM](blockBootstrapQARDLECM.md)
