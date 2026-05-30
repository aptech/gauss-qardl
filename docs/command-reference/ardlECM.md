# ardlECM

## Purpose

Estimates ARDL error-correction models by OLS.

## Format

```gauss
arECMOut = ardlECM(data, ppp, qqq);
arECMOut = ardlECM(data, ppp, qqq, formula, print_results);
arECMOut = ardlECM(data, ppp, qqq, formula, print_results, ecm_type);
arECMOut = ardlECM(data, ppp, qqq, formula, print_results, "uecm", case_id);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`. Formula input may use a named GAUSS dataframe.
- `ppp` (*scalar*) - Autoregressive lag order. Must be at least `1`.
- `qqq` (*scalar*) - Distributed-lag order for each regressor. May be `0`.
- `formula` (*string*) - Optional formula string such as `"y ~ x1 + x2"`.
  Default is `""`.
- `print_results` (*scalar*) - If `1`, print a formatted ECM results table.
  Default is `1`.
- `ecm_type` (*string*) - `"two-step"` (default) for the GAUSS restricted
  two-step ECM, or `"uecm"` for the unrestricted ECM.
- `case_id` (*scalar*) - Pesaran-Shin-Smith deterministic case `1` through
  `5` for unrestricted ECM designs. Default is `3`. Cases other than `3`
  require `ecm_type = "uecm"`.

## Returns

`arECMOut` is an `ardlECMOut` structure containing:

- `ecm_type` - `"two-step"` or `"uecm"`.
- `beta_lr` - Long-run coefficients used by the two-step ECM or derived from
  the unrestricted ECM.
- `rho_ols` - Levels-form OLS speed of adjustment.
- `alpha`, `rho`, `alpha_cov`, `rho_cov` - ECM intercept, adjustment
  coefficient, and scalar covariance entries.
- `bt`, `fitted`, `resid`, `sigma2`, `coef_cov` - ECM OLS results.
- `p`, `q`, `qvec`, `nobs`, `k` - ECM estimation metadata.

## Remarks

The default `"two-step"` estimator first estimates `ardl`, then constructs one
lagged error-correction term from the levels long-run relation. With
`ecm_type = "uecm"`, lagged `y` and lagged level regressors enter the
differenced equation directly, and long-run coefficients are derived as
`-theta / rho`.

The ECM sample uses one fewer observation than the corresponding levels ARDL
fit because the dependent variable is first differenced.
For `ecm_type = "uecm"`, `case_id` controls the deterministic terms in the
differenced equation: Case I has no intercept/trend, Cases II-III include an
intercept, and Cases IV-V include intercept and trend. The trend coefficient,
when present, is stored in `bt`.

## Examples

```gauss
library qardl;

data = loadd("qardl_data.dat");

arECMOut = ardlECM(data, 2, 1, "", 0);
arUECMOut = ardlECM(data, 2, 1, "", 0, "uecm");
arCaseV = ardlECM(data, 2, 1, "", 0, "uecm", 5);

printARDLECM(arECMOut);
```

## Source

`qardl.src`

## See Also

[ardl](ardl.md), [ardlFull](ardlFull.md), [printARDLECM](printARDLECM.md),
[qardlECM](qardlECM.md), [nardlECM](nardlECM.md)
