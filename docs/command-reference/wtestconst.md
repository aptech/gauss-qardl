# wtestconst

## Purpose

Tests whether QARDL parameters are constant across quantiles.

## Format

```gauss
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qaOut, tau, data);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Output from `qardl`, `qardlRobust`,
  `qardlHAC`, or `qardlX`.
- `tau` (*Sx1 vector*) - Quantiles used in estimation.
- `data` (*Tx(1+k) matrix*) - Data used to estimate the model.

## Returns

- `wt_beta`, `pv_beta` - Wald statistic and p-value for long-run beta
  constancy.
- `wt_gamma`, `pv_gamma` - Wald statistic and p-value for x-level gamma/theta
  constancy.
- `wt_phi`, `pv_phi` - Wald statistic and p-value for phi constancy.

## Remarks

If a restriction covariance matrix is singular or near-singular, the procedure
uses a pseudoinverse with rank-adjusted chi-square degrees of freedom.

## Examples

```gauss
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qaOut, tau, data);
```

## Source

`wtestconst.src`

## See Also

[wtestsym](wtestsym.md), [wtestlrb](wtestlrb.md), [wtestsrg](wtestsrg.md),
[wtestsrp](wtestsrp.md)
