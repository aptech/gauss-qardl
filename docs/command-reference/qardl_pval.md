# qardl_pval

## Purpose

Computes asymptotic normal p-values for levels-form QARDL estimates.

## Format

```gauss
{ pv_beta, pv_gamma, pv_phi } = qardl_pval(qaOut);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Output from `qardl`, `qardlRobust`,
  `qardlHAC`, or `qardlX`.

## Returns

- `pv_beta` - P-values for long-run beta estimates.
- `pv_gamma` - P-values for x-level gamma/theta estimates.
- `pv_phi` - P-values for phi estimates.

## Remarks

P-values are based on the covariance matrices stored in `qaOut`, so they
reflect the covariance estimator used during estimation.

## Examples

```gauss
{ pv_beta, pv_gamma, pv_phi } = qardl_pval(qaOut);
```

## Source

`p_values_qardl.src`

## See Also

[qardl](qardl.md), [qardl_pval_ecm](qardl_pval_ecm.md)
