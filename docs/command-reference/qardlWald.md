# qardlWald

## Purpose

Runs QARDL Wald tests through one named-argument interface.

## Format

```gauss
wOut = qardlWald(qaOut, data = data, test = "constancy");
wOut = qardlWald(qaOut, data = data, test = "symmetry");
wOut = qardlWald(qaOut, data = data, test = "custom",
                 family = "beta", restrictions = restrictions);
```

## Parameters

- `qaOut` - `qardlOut` structure returned by `qardl`, `qardlRobust`, `qardlHAC`, or `qardlX`.
- `data` - Data matrix used for QARDL estimation. Supply this as a named argument.
- `test` - Wald test to run: `"custom"` (default), `"constancy"`, or `"symmetry"`.
- `family` - Parameter family for custom tests: `"beta"`, `"gamma"`, or `"phi"`. Aliases include `"long-run"`/`"lr"` for beta and `"ar"` for phi.
- `restrictions` - String array of custom restrictions. Equality restrictions may be written directly, for example `"beta[x1,0.25] = beta[x1,0.50]"`.
- `rhs` - Optional right-hand-side vector when custom restrictions are written as left-hand expressions, for example `"beta[x1,0.25] - beta[x1,0.50]"` with `rhs = 0`.
- `formula` - Optional formula string used to recover regressor names when `qaOut` does not already contain the desired names.
- `print_results` - Optional scalar, `1` to print results and interpretation notes, `0` to return results silently.

## Returns

`qardlWaldOut` structure with the following key members:

- `test` - Normalized test name.
- `family` - `"all"` for built-in tests or the selected family for custom tests.
- `wald` - Wald statistic vector. Built-in tests return beta, gamma, and phi rows.
- `pv` - P-value vector matching `wald`.
- `wald_beta`, `pv_beta` - Beta-family statistic and p-value.
- `wald_gamma`, `pv_gamma` - Gamma-family statistic and p-value.
- `wald_phi`, `pv_phi` - Phi-family statistic and p-value.
- `bigR`, `smr` - Generated restriction matrix and right-hand side for custom tests.

## Remarks

Built-in tests:

- `test = "constancy"` dispatches to the package's cross-quantile parameter constancy Wald test.
- `test = "symmetry"` dispatches to the package's quantile symmetry Wald test.

Custom parameter references use:

- `beta[xvar,tau]` for long-run coefficients.
- `gamma[xvar,tau]` for short-run x-level coefficients.
- `phi[lag,tau]` for short-run autoregressive coefficients.

The custom parser supports multiple restrictions, equality syntax, plus/minus linear combinations, and scalar multiplication such as `2*gamma[x1,0.25]`.

`qardlWald` preserves the existing QARDL Wald-test conventions. Custom restrictions are parsed into `bigR` and `smr`, then evaluated through `wtestlrb`, `wtestsrg`, or `wtestsrp`. Built-in constancy and symmetry tests preserve the existing `wtestconst` and `wtestsym` calculations.

## Examples

```gauss
qaOut = qardl(data, 2, 1, { 0.25, 0.50, 0.75 });

// Built-in constancy test.
wConst = qardlWald(qaOut, data = data, test = "constancy");

// Built-in symmetry test.
wSym = qardlWald(qaOut, data = data, test = "symmetry");

// Custom equality restriction.
wBeta = qardlWald(qaOut, data = data, test = "custom",
                  family = "beta",
                  restrictions = "beta[x1,0.25] = beta[x1,0.50]");

// Equivalent GAUSS waldTest-style expression plus numeric right-hand side.
wBeta = qardlWald(qaOut, data = data, test = "custom",
                  family = "beta",
                  restrictions = "beta[x1,0.25] - beta[x1,0.50]",
                  rhs = 0);

// Multiple restrictions.
restr = "beta[x1,0.25] = beta[x1,0.50]" $|
        "beta[x1,0.50] = beta[x1,0.75]";

wBeta = qardlWald(qaOut, data = data, test = "custom",
                  family = "beta", restrictions = restr);
```

## Source

`qardl.src`

## See Also

[qardlRestriction](qardlRestriction.md), [printQARDLWald](printQARDLWald.md), [wtestlrb](wtestlrb.md), [wtestsrp](wtestsrp.md), [wtestsrg](wtestsrg.md), [wtestconst](wtestconst.md), [wtestsym](wtestsym.md)
