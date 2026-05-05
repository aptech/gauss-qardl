# wtestlrb

## Purpose

Runs a custom Wald test for long-run beta restrictions.

## Format

```gauss
{ wt, pv } = wtestlrb(beta, cov, bigR, smr, data);
```

## Parameters

- `beta` - Long-run beta vector.
- `cov` - Long-run beta covariance matrix.
- `bigR` - Restriction matrix.
- `smr` - Restriction right-hand-side vector.
- `data` - Data matrix used for estimation.

## Returns

- `wt` - Wald statistic.
- `pv` - Chi-square p-value.

## Remarks

Restriction dimensions must match the stacked beta vector.

## Examples

```gauss
{ wt, pv } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, bigR, smr, data);
```

## Source

`wtestlrb.src`

## See Also

[wtestconst](wtestconst.md), [wtestsym](wtestsym.md)
