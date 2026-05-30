# nardlECM

## Purpose

Estimates NARDL error-correction models.

## Format

```gauss
nECMOut = nardlECM(data, ppp, qqq);
nECMOut = nardlECM(data, ppp, qqq, formula, print_results,
                   decomp_vars, control_vars, q_decomp, q_control,
                   ecm_type);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order for decomposed variables.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `print_results` (*scalar*) - If `1`, print a formatted ECM table.
- `decomp_vars`, `control_vars`, `q_decomp`, `q_control` - Same
  decomposition and lag controls as `nardl`.
- `ecm_type` (*string*) - `"two-step"` (default) or `"uecm"`.

## Returns

`nECMOut` is a `nardlECMOut` structure containing long-run positive,
negative, and optional control effects, ECM `alpha` and `rho`, their scalar
covariance entries, OLS ECM coefficients, fitted values, residuals, and NARDL
decomposition metadata.

## Remarks

The default `"two-step"` estimator first estimates the NARDL long-run levels
relation, then uses one lagged error-correction term in the differenced ECM.
With `ecm_type = "uecm"`, lagged dependent and lagged level terms enter the
ECM directly, and long-run coefficients are derived as `-theta / rho`.

## Examples

```gauss
library qardl;

nECMOut = nardlECM(df, 2, 2, "y ~ x1 + x2", 0,
                   "x1", "x2", 2, 1);
nUECMOut = nardlECM(df, 2, 2, "y ~ x1 + x2", 0,
                    "x1", "x2", 2, 1, "uecm");
```

## Source

`nardl.src`

## See Also

[nardl](nardl.md), [nardlFull](nardlFull.md), [printNARDLECM](printNARDLECM.md)
