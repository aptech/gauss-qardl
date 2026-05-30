# nardl

## Purpose

Estimates a levels-form nonlinear ARDL model using positive and negative
partial-sum decompositions.

## Format

```gauss
naOut = nardl(data, ppp, qqq);
naOut = nardl(data, ppp, qqq, formula, print_results);
naOut = nardl(data, ppp, qqq, formula, print_results,
              decomp_vars, control_vars, q_decomp, q_control);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`.
- `ppp` (*scalar*) - Autoregressive lag order. Must be at least `1`.
- `qqq` (*scalar*) - Distributed-lag order for decomposed variables. May be
  `0`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `print_results` (*scalar*) - If `1`, print a formatted results table.
- `decomp_vars` (*string or string array*) - RHS variables to decompose into
  positive and negative partial sums. Empty means all non-control RHS
  variables are decomposed.
- `control_vars` (*string or string array*) - RHS variables to keep linear.
  Empty means the complement of `decomp_vars`.
- `q_decomp` (*scalar*) - Optional alias for the decomposed-variable lag
  order. If nonnegative, it overrides `qqq`.
- `q_control` (*scalar*) - Distributed-lag order for linear controls.

## Returns

`naOut` is a `nardlOut` structure containing:

- `beta_pos`, `beta_neg`, `beta_control` - Long-run coefficients.
- `bigbt`, `bigbt_cov` - Stacked long-run coefficients and covariance.
- `theta_pos`, `theta_neg`, `theta_control`, `phi`, `bt` - Levels-form
  coefficient blocks.
- `asymmetry_wald`, `asymmetry_pv`, `sr_asymmetry_wald`, `sr_asymmetry_pv` -
  Long-run and short-run asymmetry diagnostics.
- `bounds_fstat` - Bounds-style F-statistic from the NARDL UECM design.
- `fitted`, `resid`, `sigma2`, `coef_cov` - OLS diagnostics.
- Metadata fields including `decomp_vars`, `control_vars`, `qvec`, and
  `control_qvec`.

## Remarks

The compatibility shortcut `nardl(data, p, q)` decomposes every RHS variable.
To decompose only selected RHS variables, pass `decomp_vars` and optionally
`control_vars`. If `control_vars` is omitted, every RHS variable not listed in
`decomp_vars` is treated as a linear control.

Use `nardlECM` for the corresponding error-correction estimator and
`nardlFull` for lag selection plus levels and ECM estimation.

## Examples

```gauss
library qardl;

// x1 is decomposed; x2 enters linearly.
naOut = nardl(df, 2, 2, formula = "y ~ x1 + x2",
              print_results = 0, decomp_vars = "x1",
              control_vars = "x2", q_control = 1);

printNARDL(naOut);
```

## Source

`nardl.src`

## See Also

[nardlECM](nardlECM.md), [nardlFull](nardlFull.md),
[nardlDynamicMultipliers](nardlDynamicMultipliers.md),
[applyNARDLFormula](applyNARDLFormula.md)
