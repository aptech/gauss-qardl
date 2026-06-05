# qardlWald

## Purpose

Runs QARDL Wald tests from user-friendly string restrictions.

## Format

```gauss
{ wt, pv, bigR, smr } = qardlWald(qaOut, family, restrictions, data);
{ wt, pv, bigR, smr } = qardlWald(qaOut, family, restrictions, data, rhs, formula);
```

## Parameters

- `qaOut` - `qardlOut` structure returned by `qardl`, `qardlRobust`, `qardlHAC`, or `qardlX`.
- `family` - Parameter family to test: `"beta"`, `"gamma"`, or `"phi"`. Aliases include `"long-run"`/`"lr"` for beta and `"ar"` for phi.
- `restrictions` - String array of restrictions. Equality restrictions may be written directly, for example `"beta[x1,0.25] = beta[x1,0.50]"`.
- `data` - Data matrix used for QARDL estimation.
- `rhs` - Optional right-hand-side vector when restrictions are written as left-hand expressions, for example `"beta[x1,0.25] - beta[x1,0.50]"` with `rhs = 0`.
- `formula` - Optional formula string used to recover regressor names when `qaOut` does not already contain the desired names.

## Returns

- `wt` - QARDL Wald statistic.
- `pv` - Chi-square p-value using the existing QARDL Wald scaling.
- `bigR` - Generated restriction matrix.
- `smr` - Generated restriction right-hand-side vector.

## Remarks

Parameter references use:

- `beta[xvar,tau]` for long-run coefficients.
- `gamma[xvar,tau]` for short-run x-level coefficients.
- `phi[lag,tau]` for short-run autoregressive coefficients.

The parser supports multiple restrictions, equality syntax, plus/minus linear combinations, and scalar multiplication such as `2*gamma[x1,0.25]`.

`qardlWald` preserves the QARDL package Wald-test conventions. It parses restrictions into `R` and `r`, then delegates to `wtestlrb`, `wtestsrg`, or `wtestsrp` so the statistic, scaling, p-values, and rank-handling remain consistent with the existing implementation.

## Examples

```gauss
qaOut = qardl(data, 2, 1, { 0.25, 0.50, 0.75 });

// Test equality of the first long-run coefficient across two quantiles.
{ wt, pv, bigR, smr } = qardlWald(qaOut, "beta",
    "beta[x1,0.25] = beta[x1,0.50]", data);

// Equivalent GAUSS waldTest-style expression plus numeric right-hand side.
{ wt, pv, bigR, smr } = qardlWald(qaOut, "beta",
    "beta[x1,0.25] - beta[x1,0.50]", data, 0);

// Multiple restrictions.
restr = "beta[x1,0.25] = beta[x1,0.50]" $|
        "beta[x1,0.50] = beta[x1,0.75]";

{ wt, pv, bigR, smr } = qardlWald(qaOut, "beta", restr, data);
```

## Source

`qardl.src`

## See Also

[qardlRestriction](qardlRestriction.md), [wtestlrb](wtestlrb.md), [wtestsrp](wtestsrp.md), [wtestsrg](wtestsrg.md), [wtestconst](wtestconst.md), [wtestsym](wtestsym.md)
