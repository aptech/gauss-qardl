# blockBootstrapQARDLECM

## Purpose

Computes moving-block bootstrap confidence intervals for QARDL-ECM alpha and
rho estimates.

## Format

```gauss
{ rho_ci, alpha_ci } = blockBootstrapQARDLECM(data, ppp, qqq);
{ rho_ci, alpha_ci } = blockBootstrapQARDLECM(data, ppp, qqq, tau,
                                              B, blk_len, alpha);
```

## Parameters

Parameters match `blockBootstrapQARDL`.

## Returns

- `rho_ci` - Bootstrap confidence intervals for ECM speed of adjustment.
- `alpha_ci` - Bootstrap confidence intervals for ECM intercepts.

## Remarks

Use `blockBootstrapQARDLECMMethod` for alternate resampling methods and
`blockBootstrapQARDLECMDiag` for seeded diagnostics.

## Examples

```gauss
{ rho_ci, alpha_ci } = blockBootstrapQARDLECM(data, 2, 1, tau, 499, 0, 0.05);
```

## Source

`qardl.src`

## See Also

[blockBootstrapQARDLECMMethod](blockBootstrapQARDLECMMethod.md),
[qardlECM](qardlECM.md)
