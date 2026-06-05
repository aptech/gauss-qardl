# qardlRestriction

## Purpose

Converts QARDL string restrictions into numeric Wald-test restriction matrices.

## Format

```gauss
{ bigR, smr } = qardlRestriction(qaOut, family, restrictions);
{ bigR, smr } = qardlRestriction(qaOut, family, restrictions, rhs, formula);
```

## Parameters

- `qaOut` - `qardlOut` structure returned by a QARDL levels estimator.
- `family` - Parameter family: `"beta"`, `"gamma"`, or `"phi"`.
- `restrictions` - String array of equality restrictions or left-hand linear expressions.
- `rhs` - Optional numeric right-hand-side vector for expression-style restrictions.
- `formula` - Optional formula string used to resolve regressor names.

## Returns

- `bigR` - Restriction matrix.
- `smr` - Restriction right-hand-side vector.

## Remarks

This helper is useful when you want to inspect or reuse the generated matrices. Most users should call `qardlWald`, which runs the test directly.

Examples of supported parameter references:

- `beta[x1,0.25]`
- `gamma[2,0.50]`
- `phi[1,0.75]`

Regressors may be referenced by variable name or by one-based index. Quantiles must match the quantiles estimated in `qaOut`.

## Examples

```gauss
restr = "beta[x1,0.25] = beta[x1,0.50]" $|
        "beta[x1,0.50] = beta[x1,0.75]";

{ bigR, smr } = qardlRestriction(qaOut, "beta", restr);
{ wt, pv } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, bigR, smr, data);
```

## Source

`qardl.src`

## See Also

[qardlWald](qardlWald.md), [wtestlrb](wtestlrb.md), [wtestsrp](wtestsrp.md), [wtestsrg](wtestsrg.md)
