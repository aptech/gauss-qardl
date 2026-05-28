# nardl

## Purpose

Estimates nonlinear ARDL models using positive and negative partial-sum
decompositions. The source includes `nardl`, `nardlECM`, `nardlFull`,
`nardlOrder`, `nardlOrderGrid`, `nardlICMean`, `printNARDL`,
`printNARDLECM`, `predictNARDL`, `forecastNARDL`, and
`applyNARDLFormula`.

## Format

```gauss
naOut = nardl(data, ppp, qqq);
naOut = nardl(data, ppp, qqq, formula, print_results,
              decomp_vars, control_vars, q_decomp, q_control);
nECMOut = nardlECM(data, ppp, qqq);
nECMOut = nardlECM(data, ppp, qqq, formula, print_results,
                   decomp_vars, control_vars, q_decomp, q_control);
nfOut = nardlFull(data);
nfOut = nardlFull(data, pend, qend, formula);
nfOut = nardlFull(data, pend, qend, formula, verbose, criterion,
                  decomp_vars, control_vars, q_control);
```

## Remarks

The levels estimator reports long-run positive and negative coefficients,
delta-method long-run covariance, a UECM bounds F-statistic, and long-run and
short-run asymmetry Wald tests.

`nardlFull`, `nardlOrder`, and `nardlOrderGrid` support information-criterion
lag selection. If `pend` and `qend` are omitted, the default maximum search
bounds are `8` and `8`.

`nardl(data, p, q)` is the compatibility shortcut that decomposes every RHS
regressor. To decompose only selected RHS variables, pass `decomp_vars` and
optionally `control_vars` to `nardl`, `nardlECM`, or `nardlFull`. If
`control_vars` is omitted, every RHS variable not listed in `decomp_vars` is
treated as a linear control. If `decomp_vars` is omitted but `control_vars` is
provided, every remaining RHS variable is decomposed.

`q_decomp` is an optional alias for the decomposed-variable lag order in
`nardl` and `nardlECM`; when it is supplied, it overrides `qqq`.
`q_control` sets the distributed-lag order for linear controls. In
`nardlFull`, `qend` remains the maximum search bound for decomposed variables,
and `q_control` is fixed across the search grid.

```gauss
// x1 is decomposed into positive and negative partial sums; x2 is linear.
naOut = nardl(df, 2, 2, formula = "y ~ x1 + x2",
              print_results = 0, decomp_vars = "x1",
              control_vars = "x2", q_control = 1);

nECMOut = nardlECM(df, 2, 2, formula = "y ~ x1 + x2",
                   print_results = 0, decomp_vars = "x1",
                   control_vars = "x2", q_control = 1);

nfOut = nardlFull(df, 4, 4, "y ~ x1 + x2", 0, "bic",
                  "x1", "x2", 1);
```

Use `nardlDynamicMultipliers` to compute positive and negative dynamic
multiplier paths from a stored `nardlOut`.

The current benchmark coverage uses deterministic synthetic decomposition,
coefficient, bounds, asymmetry, and dynamic-multiplier fixtures. Additional
published-result validation cases can be added as reference datasets and
specifications become available.

## Source

`nardl.src`

## See Also

[qardl](qardl.md), [csardl](csardl.md),
[nardlDynamicMultipliers](nardlDynamicMultipliers.md)
