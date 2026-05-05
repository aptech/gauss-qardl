# qardl_pval_ecm

## Purpose

Computes asymptotic normal p-values for QARDL-ECM estimates.

## Format

```gauss
{ pv_alpha, pv_rho } = qardl_pval_ecm(qECMOut);
```

## Parameters

- `qECMOut` (*qardlECMOut structure*) - Output from `qardlECM`,
  `qardlECMRobust`, `qardlECMHAC`, or `qardlECMX`.

## Returns

- `pv_alpha` - P-values for ECM intercept estimates.
- `pv_rho` - P-values for ECM speed-of-adjustment estimates.

## Remarks

P-values are based on the covariance matrices stored in `qECMOut`.

## Examples

```gauss
{ pv_alpha, pv_rho } = qardl_pval_ecm(qECMOut);
```

## Source

`p_values_qardl.src`

## See Also

[qardlECM](qardlECM.md), [qardl_pval](qardl_pval.md)
