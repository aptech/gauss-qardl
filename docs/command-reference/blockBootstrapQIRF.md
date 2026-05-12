# blockBootstrapQIRF

## Purpose

Computes QIRF point estimates with block-bootstrap confidence bands.

## Format

```gauss
qOut = blockBootstrapQIRF(data, ppp, qqq, H);
qOut = blockBootstrapQIRF(data, ppp, qqq, H, tau, k_x, permanent,
                          B, blk_len, alpha, seed, method, formula);
```

## Parameters

- `data` - Dependent variable followed by regressors, or dataframe with
  `formula`.
- `ppp`, `qqq` - Lag orders.
- `H` - Maximum response horizon.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `k_x` - Shocked regressor index. Default is `1`.
- `permanent` - `1` for permanent shock, `0` for temporary shock.
- `B` - Requested bootstrap replications. Default is `999`.
- `blk_len` - Block length. Use `0` for automatic length.
- `alpha` - Confidence level tail probability. Default is `0.05`.
- `seed` - Positive value sets `rndseed`. Default is `0`.
- `method` - `"moving"`, `"circular"`, or `"stationary"`.
- `formula` - Optional formula string.

## Returns

`qOut` is a `qirfOut` structure with `irf`, `irf_lb`, `irf_ub`,
`bands_available = 1`, `alpha`, and bootstrap diagnostics in `boot_diag`.

## Remarks

Bootstrap draws that produce rank-deficient QARDL design matrices are skipped.
The diagnostic row is `[B requested, B completed, B failed, blk_len, seed]`.

## Examples

```gauss
qOut = blockBootstrapQIRF(data, 2, 1, 20, tau, 1, 1, 499, 0, 0.05, 12345);
plotQIRF(qOut, 1);
```

## Source

`qirf.src`

## See Also

[qirf](qirf.md), [plotQIRF](plotQIRF.md),
[blockBootstrapQARDL](blockBootstrapQARDL.md)
