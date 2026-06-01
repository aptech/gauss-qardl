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
naOut = nardl(data, ppp, qqq, formula, print_results,
              decomp_vars, control_vars, q_decomp, q_control,
              d, thresh1, thresh2);
naOut = nardl(data, ppp, qqq, formula, print_results,
              decomp_vars, control_vars, q_decomp, q_control,
              d, thresh1, thresh2, symmetry);
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
- `d` (*string or numeric*) - Partial-sum reset threshold. Default is
  `"inf"`, which gives the standard cumulative positive and negative partial
  sums. Use `"mean"`, a scalar such as `0`, or a vector with one value per
  decomposed variable.
- `thresh1`, `thresh2` (*string or numeric*) - R-compatible aliases for the
  first and second decomposed-variable reset thresholds. If supplied, these
  override the corresponding entries implied by `d`.
- `symmetry` (*string*) - Optional symmetry restriction: `"none"` (default),
  `"SRSR"` for short-run symmetry, `"LRSR"` for long-run symmetry, or
  `"both"`.

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
- Metadata fields including `decomp_vars`, `control_vars`, `qvec`,
  `control_qvec`, `decomp_thresholds`, and `symmetry_restriction`.

## Remarks

The compatibility shortcut `nardl(data, p, q)` decomposes every RHS variable.
To decompose only selected RHS variables, pass `decomp_vars` and optionally
`control_vars`. If `control_vars` is omitted, every RHS variable not listed in
`decomp_vars` is treated as a linear control.

Use `nardlECM` for the corresponding error-correction estimator and
`nardlFull` for lag selection plus levels and ECM estimation.

Thresholds follow the CRAN `ardl.nardl` convention: the variables are still
split into positive and negative changes by sign, and the threshold controls
when the running partial sum is reset. The default `"inf"` is ordinary
cumulative-sum behavior.

`symmetry = "SRSR"` imposes equality on positive and negative short-run
partial-sum change coefficients. `symmetry = "LRSR"` imposes equality on the
positive and negative long-run level effects. `symmetry = "both"` applies both
restrictions.

## Examples

```gauss
library qardl;

// x1 is decomposed; x2 enters linearly.
naOut = nardl(df, 2, 2, formula = "y ~ x1 + x2",
              print_results = 0, decomp_vars = "x1",
              control_vars = "x2", q_control = 1);

// R-style reset threshold for the decomposed variable.
naThresh = nardl(df, 2, 2, formula = "y ~ x1 + x2",
                 print_results = 0, decomp_vars = "x1",
                 control_vars = "x2", q_control = 1,
                 d = 0);
naSym = nardl(df, 2, 2, formula = "y ~ x1 + x2",
              print_results = 0, decomp_vars = "x1",
              control_vars = "x2", q_control = 1,
              symmetry = "LRSR");

printNARDL(naOut);
```

## Source

`nardl.src`

## See Also

[nardlECM](nardlECM.md), [nardlFull](nardlFull.md),
[nardlDynamicMultipliers](nardlDynamicMultipliers.md),
[applyNARDLFormula](applyNARDLFormula.md)
