# wtestsrg

## Purpose

Runs a custom Wald test for x-level gamma/theta restrictions.

## Format

```gauss
{ wt, pv } = wtestsrg(gamma, cov, bigR, smr, data);
```

## Parameters

- `gamma` - Stacked x-level coefficient vector.
- `cov` - Gamma/theta covariance matrix.
- `bigR` - Restriction matrix.
- `smr` - Restriction right-hand-side vector.
- `data` - Data matrix used for estimation.

## Returns

- `wt` - Wald statistic.
- `pv` - Chi-square p-value.

## Remarks

The `gamma` output field stores the x-level coefficient used in long-run beta
construction.

## Examples

```gauss
{ wt, pv } = wtestsrg(qaOut.gamma, qaOut.gamma_cov, bigR, smr, data);
```

## Source

`wtestsrg.src`

## See Also

[wtestconst](wtestconst.md), [wtestsym](wtestsym.md)
