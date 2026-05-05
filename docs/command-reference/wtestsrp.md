# wtestsrp

## Purpose

Runs a custom Wald test for short-run phi restrictions.

## Format

```gauss
{ wt, pv } = wtestsrp(phi, cov, bigR, smr, data);
```

## Parameters

- `phi` - Stacked phi vector.
- `cov` - Phi covariance matrix.
- `bigR` - Restriction matrix.
- `smr` - Restriction right-hand-side vector.
- `data` - Data matrix used for estimation.

## Returns

- `wt` - Wald statistic.
- `pv` - Chi-square p-value.

## Remarks

Use `wtestconst` or `wtestsym` for automatic cross-quantile restrictions.

## Examples

```gauss
{ wt, pv } = wtestsrp(qaOut.phi, qaOut.phi_cov, bigR, smr, data);
```

## Source

`wtestsrp.src`

## See Also

[wtestconst](wtestconst.md), [wtestsym](wtestsym.md)
