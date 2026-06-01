# nardlECM

## Purpose

Estimates NARDL error-correction models.

## Format

```gauss
nECMOut = nardlECM(data, ppp, qqq);
nECMOut = nardlECM(data, ppp, qqq, formula, print_results,
                   decomp_vars, control_vars, q_decomp, q_control,
                   ecm_type, case_id, d, thresh1, thresh2);
nECMOut = nardlECM(data, ppp, qqq, formula, print_results,
                   decomp_vars, control_vars, q_decomp, q_control,
                   ecm_type, case_id, d, thresh1, thresh2, symmetry);
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
- `case_id` (*scalar*) - Pesaran-Shin-Smith deterministic case `1` through
  `5` for unrestricted ECM designs. Default is `3`. Cases other than `3`
  require `ecm_type = "uecm"`.
- `d`, `thresh1`, `thresh2` - Partial-sum reset threshold controls shared
  with `nardl`. Default `"inf"` gives ordinary cumulative positive and
  negative partial sums.
- `symmetry` (*string*) - Optional symmetry restriction: `"none"` (default),
  `"SRSR"` for short-run symmetry, `"LRSR"` for long-run symmetry, or
  `"both"`.

## Returns

`nECMOut` is a `nardlECMOut` structure containing long-run positive,
negative, and optional control effects, ECM `alpha` and `rho`, their scalar
covariance entries, OLS ECM coefficients, fitted values, residuals, and NARDL
decomposition metadata including `decomp_thresholds` and
`symmetry_restriction`.

## Remarks

The default `"two-step"` estimator first estimates the NARDL long-run levels
relation, then uses one lagged error-correction term in the differenced ECM.
With `ecm_type = "uecm"`, lagged dependent and lagged level terms enter the
ECM directly, and long-run coefficients are derived as `-theta / rho`.
For unrestricted ECMs, `case_id` controls deterministic terms in the
differenced equation: Case I has no intercept/trend, Cases II-III include an
intercept, and Cases IV-V include intercept and trend. Any trend coefficient
is stored in `bt`.
The same threshold settings are used in the long-run levels relation and the
ECM design so two-step and unrestricted fits remain internally consistent.
`symmetry = "SRSR"` imposes equality on positive and negative short-run
partial-sum change coefficients. `symmetry = "LRSR"` imposes equality on the
positive and negative long-run level effects. `symmetry = "both"` applies both
restrictions.

## Examples

```gauss
library qardl;

nECMOut = nardlECM(df, 2, 2, "y ~ x1 + x2", 0,
                   "x1", "x2", 2, 1);
nUECMOut = nardlECM(df, 2, 2, "y ~ x1 + x2", 0,
                    "x1", "x2", 2, 1, "uecm");
nCaseI = nardlECM(df, 2, 2, "y ~ x1 + x2", 0,
                  "x1", "x2", 2, 1, "uecm", 1);
nThresh = nardlECM(df, 2, 2, "y ~ x1 + x2", 0,
                   "x1", "x2", 2, 1, "uecm", 3, 0);
nSym = nardlECM(df, 2, 2, "y ~ x1 + x2", 0,
                "x1", "x2", 2, 1, "uecm", 3,
                "inf", error(0), error(0), "both");
```

## Source

`nardl.src`

## See Also

[nardl](nardl.md), [nardlFull](nardlFull.md), [printNARDLECM](printNARDLECM.md)
