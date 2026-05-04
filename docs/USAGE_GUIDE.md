# QARDL Usage Guide

This guide summarizes the main API choices and output conventions for the
GAUSS QARDL package.

## Choosing An API

Use `qardlFull` when you want the standard applied workflow:

```gauss
qfOut = qardlFull(data, 8, 8);
qfOut = qardlFull(data, 8, 8, tau = { 0.25, 0.5, 0.75 }, formula = "", verbose = 1);
qfOut = qardlFull(data, 8, 8, tau, "", 0, "bic", "hac", 4);
```

It performs information-criterion lag selection, ARDL bounds testing, QARDL
levels estimation, QARDL-ECM estimation, and optional printing. BIC is the
default lag-selection criterion. Set `verbose = 0` for scripts that need the
results without console output.

Use `qardl` when you already know the lag orders and want levels-form QARDL
estimates:

```gauss
qaOut = qardl(data, 2, 1, tau);
printQARDL(qaOut, tau);
```

For levels-form covariance estimates that are robust to heteroskedasticity or
serial dependence in the quantile score, use the levels covariance variants:

```gauss
qaRobust = qardlRobust(data, 2, 1, tau);
qaHAC = qardlHAC(data, 2, 1, tau, 4);
qaAutoHAC = qardlHAC(data, 2, 1, tau, 0);
```

`qardlHAC(..., 0)` uses the automatic Newey-West bandwidth
`floor(4*(T/100)^(2/9))`. The parameter estimates are the same as `qardl`;
only `bigbt_cov`, `gamma_cov`, and `phi_cov` change.

Use `qardlECM` when you specifically want the two-step ECM estimator:

```gauss
qECMOut = qardlECM(data, 2, 1, tau);
printQARDLECM(qECMOut, tau);
```

For ECM covariance estimates that are robust to heteroskedasticity or serial
dependence in the quantile score, use the ECM covariance variants:

```gauss
qECMRobust = qardlECMRobust(data, 2, 1, tau);
qECMHAC = qardlECMHAC(data, 2, 1, tau, 4);
qECMAutoHAC = qardlECMHAC(data, 2, 1, tau, 0);
```

`qardlECMHAC(..., 0)` uses the automatic Newey-West bandwidth
`floor(4*(T/100)^(2/9))`. The parameter estimates are the same as `qardlECM`;
only `alpha_cov` and `rho_cov` change.

Use `pqorder` directly when you only need lag selection:

```gauss
{ pst, qst } = pqorder(data, pend = 8, qend = 8);
{ pst, qst } = pqorder(data, pend = 8, qend = 8, criterion = "aic");
{ pst, qst } = pqorderRange(data, 2, 8, 1, 4, "bic");
ic_grid = pqorderGrid(data, 8, 8, "bic");
```

Supported lag-selection criteria are `"bic"` (default), `"aic"`, `"hq"`, and
`"hqc"`. `qardlFull` accepts the same criterion as its final optional argument:

```gauss
qfOut = qardlFull(data, 8, 8, tau, "", 0, "hq");
```

Use `pqorderRange` when you need a restricted lag-search grid. For example,
`pqorderRange(data, 2, 8, 1, 4, "bic")` searches p from 2 through 8 and q from
1 through 4. Setting the start and end equal fixes a lag order.
Use `pqorderGrid` or `pqorderRangeGrid` to inspect the full search table. The
returned matrix has columns `[p, q, IC]`; the selected model is the row with the
smallest IC value.

## Formula And Dataframe Workflow

Matrix-based procedures expect data ordered as `[y, x1, x2, ...]`. For named
GAUSS dataframes, use a formula to select and reorder columns:

```gauss
df = loadd("macro.csv");
data = applyQARDLFormula(df, "consumption ~ income + wealth");
qaOut = qardl(data, 2, 1);
```

`qardlFull` can apply the formula internally:

```gauss
qfOut = qardlFull(df, 8, 8, formula = "consumption ~ income + wealth");
```

Formula variable matching is case-insensitive. The RHS order is preserved in
the output data, so `"y ~ x2 + x1"` intentionally produces `[y, x2, x1]`.

## Metadata

Core output structures carry enough metadata for downstream code:

```gauss
print qaOut.tau;
print qaOut.p~qaOut.q~qaOut.k~qaOut.nobs;
print qECMOut.p~qECMOut.q~qECMOut.k~qECMOut.nobs;
```

`qardlFullOut` stores selected lag orders as `pst` and `qst`, plus the input
sample size in `nobs`.

## Parameter Stacking

`qardlOut.bigbt`, `qardlOut.gamma`, and `qardlOut.phi` are stacked by quantile.
For `k = 2` and `tau = {0.25, 0.50, 0.75}`, long-run beta is ordered as:

```text
beta_1(0.25)
beta_2(0.25)
beta_1(0.50)
beta_2(0.50)
beta_1(0.75)
beta_2(0.75)
```

For `p = 2`, phi is ordered as:

```text
phi_1(0.25)
phi_2(0.25)
phi_1(0.50)
phi_2(0.50)
phi_1(0.75)
phi_2(0.75)
```

This ordering is used by the custom Wald-test procedures. Automatic tests such
as `wtestconst` and `wtestsym` build the restriction matrices for you.

## Gamma Naming

Historically, `qaOut.gamma` stores the x-level coefficient block used as the
long-run numerator. In the model documentation this coefficient is often
called theta. The full differenced-x lag coefficients are available in
`qaOut.bt` but are not yet exposed as a separate named field. Keep this in mind
when interpreting `gamma` output and when building custom restrictions.

## Bootstrap Confidence Intervals

The bootstrap helpers are intended for applied uncertainty checks:

```gauss
{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDL(data, 2, 1, tau, 999, 0, 0.05);
{ ci_rho, ci_alpha } = blockBootstrapQARDLECM(data, 2, 1, tau, 999, 0, 0.05);
{ ci_beta, ci_gamma, ci_phi, boot_diag } =
    blockBootstrapQARDLDiag(data, 2, 1, tau, 999, 0, 0.05, 12345);
{ ci_beta_c, ci_gamma_c, ci_phi_c } =
    blockBootstrapQARDLMethod(data, 2, 1, tau, 999, 0, 0.05, "circular");
{ ci_rho_s, ci_alpha_s } =
    blockBootstrapQARDLECMMethod(data, 2, 1, tau, 999, 0, 0.05, "stationary");
```

Set `blk_len = 0` to use the default `floor(T^(1/3))` block length. For
reproducible intervals, use `blockBootstrapQARDLDiag` or
`blockBootstrapQARDLECMDiag` with a positive seed. The diagnostic return is
`[B requested, B completed, B failed, blk_len, seed]`.
The diagnostic wrappers skip rank-deficient bootstrap resamples and keep
drawing until they complete the requested number of valid replications or reach
the internal attempt limit.
The method variants support `"moving"`, `"circular"`, and `"stationary"`
resampling.

## Quantile Impulse Responses

`qirf` traces the dynamic response of `y` to a unit shock in an x variable:

```gauss
qOut = qirf(qaOut, qaOut.p, qaOut.q, 20, qaOut.tau, k_x = 1, permanent = 1);
plotQIRF(qOut);
```

For a permanent shock, the response should approach the long-run beta when the
estimated AR dynamics are stable. For a temporary shock, set `permanent = 0`.

## ARDL Bounds Cases

`ardlbounds(data, p, q)` remains the Case III compatibility wrapper. Use
`ardlboundsCase` when you need a different deterministic specification or the
lagged-dependent-level t-statistic:

```gauss
{ Fstat, tstat, cv, case_id, q_restrict } = ardlboundsCase(data, 2, 1, 5);
ardlboundsCase_print(Fstat, tstat, cv, cols(data)-1, case_id);
```

Cases follow the Pesaran, Shin & Smith convention: I no intercept/no trend, II
restricted intercept/no trend, III unrestricted intercept/no trend, IV
unrestricted intercept/restricted trend, and V unrestricted
intercept/unrestricted trend. This package currently ships Case III critical
values; other cases return missing critical values but still report the F and t
statistics.

## Limitations

- Individual p-values use asymptotic normal approximations.
- Wald tests use chi-squared asymptotics and depend on correctly specified
  restriction matrices.
- HAC/robust covariance support is available for levels-form beta/gamma/phi
  covariance and two-step ECM alpha/rho covariance. The default estimators
  preserve the original covariance formulas unless an alternate covariance type
  is requested.
- `ardlboundsCase` computes deterministic Cases I-V and the bounds t-statistic,
  but tabulated critical values are currently bundled only for Case III with up
  to 10 regressors.
- Rolling window length is fixed internally at 10 percent of the sample.
- Bootstrap defaults are convenient starting points; applied work should
  report the chosen number of replications, block length, and seed.
- `p = 0` and `q = 0` models are not currently supported.
