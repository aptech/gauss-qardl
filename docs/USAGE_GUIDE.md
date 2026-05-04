# QARDL Usage Guide

This guide summarizes the main API choices and output conventions for the
GAUSS QARDL package.

## Choosing An API

Use `qardlFull` when you want the standard applied workflow:

```gauss
qfOut = qardlFull(data, 8, 8);
qfOut = qardlFull(data, 8, 8, tau = { 0.25, 0.5, 0.75 }, formula = "", verbose = 1);
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

Use `qardlECM` when you specifically want the two-step ECM estimator:

```gauss
qECMOut = qardlECM(data, 2, 1, tau);
printQARDLECM(qECMOut, tau);
```

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
```

Set `blk_len = 0` to use the default `floor(T^(1/3))` block length. For
reproducible intervals, use `blockBootstrapQARDLDiag` or
`blockBootstrapQARDLECMDiag` with a positive seed. The diagnostic return is
`[B requested, B completed, B failed, blk_len, seed]`.

## Quantile Impulse Responses

`qirf` traces the dynamic response of `y` to a unit shock in an x variable:

```gauss
qOut = qirf(qaOut, qaOut.p, qaOut.q, 20, qaOut.tau, k_x = 1, permanent = 1);
plotQIRF(qOut);
```

For a permanent shock, the response should approach the long-run beta when the
estimated AR dynamics are stable. For a temporary shock, set `permanent = 0`.

## Limitations

- Individual p-values use asymptotic normal approximations.
- Wald tests use chi-squared asymptotics and depend on correctly specified
  restriction matrices.
- `ardlbounds` currently implements PSS Case III tabulated critical values for
  up to 10 regressors.
- Rolling window length is fixed internally at 10 percent of the sample.
- Bootstrap defaults are convenient starting points; applied work should
  report the chosen number of replications, block length, and seed.
- `p = 0` and `q = 0` models are not currently supported.
