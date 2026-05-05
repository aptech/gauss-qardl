# blockBootstrapQARDL

## Purpose

Computes moving-block bootstrap confidence intervals for levels-form QARDL
long-run beta, gamma/theta, and phi estimates.

## Format

```gauss
{ beta_ci, gamma_ci, phi_ci } = blockBootstrapQARDL(data, ppp, qqq);
{ beta_ci, gamma_ci, phi_ci } = blockBootstrapQARDL(data, ppp, qqq, tau,
                                                    B, blk_len, alpha);
```

## Parameters

- `data` - Dependent variable followed by regressors.
- `ppp`, `qqq` - Lag orders.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `B` - Number of bootstrap replications. Default is `999`.
- `blk_len` - Block length. Use `0` for automatic length.
- `alpha` - Confidence level tail probability. Default is `0.05`.

## Returns

Bootstrap confidence interval matrices for beta, gamma/theta, and phi.

## Remarks

Use `blockBootstrapQARDLMethod` for circular or stationary resampling and
`blockBootstrapQARDLDiag` for seeded diagnostic runs.

## Examples

```gauss
{ beta_ci, gamma_ci, phi_ci } = blockBootstrapQARDL(data, 2, 1, tau, 499, 0, 0.05);
```

## Source

`qardl.src`

## See Also

[blockBootstrapQARDLMethod](blockBootstrapQARDLMethod.md),
[blockBootstrapQARDLDiag](blockBootstrapQARDLDiag.md)
