# QARDL Usage Guide

This guide summarizes the main API choices and output conventions for the
GAUSS QARDL package.

## Choosing An API

Use `qardlFull` when you want the standard applied workflow:

```gauss
qfOut = qardlFull(data);
qfOut = qardlFull(data, tau = { 0.25, 0.5, 0.75 }, formula = "", verbose = 1);
qfOut = qardlFull(data, 8, 8, tau, "", 0, "bic", "hac", 4);
```

It performs lag selection, ARDL bounds testing, QARDL levels estimation,
QARDL-ECM estimation, and optional printing. BIC is the default lag-selection
criterion, and GETS is available with `criterion = "gets"`. Set `verbose = 0`
for scripts that need the results without console output.
When `pend` and `qend` are omitted, full workflows use default maximum lag
search bounds of `8` and `8`.

Use `qardl` when you already know the lag orders and want levels-form QARDL
estimates:

```gauss
qaOut = qardl(data, 2, 1, tau);
printQARDL(qaOut, tau);
```

Use `ardl` when you want the standard OLS ARDL companion estimator with the
same data ordering, formula workflow, print style, and output conventions.
Use `ardlECM` when you want the corresponding ARDL error-correction estimator.
The default is the package's two-step ECM; pass `ecm_type = "uecm"` for the
unrestricted ECM. ARDL ECMs also accept `case_id = 1` through `5` for
Pesaran-Shin-Smith deterministic cases in the differenced equation:

```gauss
arOut = ardl(data, 2, 1, "", 0);
arECMOut = ardlECM(data, 2, 1, "", 0);
arCaseI2 = ardlECM(data, 2, 1, "", 0, "two-step", 1);
arUECMOut = ardlECM(data, 2, 1, "", 0, "uecm");
arCaseV = ardlECM(data, 2, 1, "", 0, "uecm", 5);
printARDL(arOut);
afOut = ardlFull(data, verbose = 0, criterion = "bic");
acOut = ardlAutoCase(data, 4, 4, "", 0, 0.05);
sparseACOut = ardlAutoCase(data, 4, 4, "", 0, 0.05, "sparse");
```

`ardlAutoCase` runs GETS lag selection, estimates a Case V UECM, infers the
admissible deterministic case set from the intercept/trend p-values, and
returns case-specific bounds rows.
Use `gets_mode = "sparse"` when you want individual non-level UECM terms
pruned from the Case V starting model instead of hierarchical lag-block
reduction. Sparse selection results are stored in `sparse_*` fields on the
auto-case output.

Direct estimator calls print GAUSS-style results tables by default. Add
`print_results = 0` as the final argument when you only want the returned
structure:

```gauss
qaOut = qardl(data, 2, 1, tau, "iid", 0, 0);
qECMOut = qardlECM(data, 2, 1, tau, "iid", 0, 0);
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

Use `qardlECM` when you specifically want the ECM estimator. The default is
the two-step restricted ECM; pass `ecm_type = "uecm"` for the unrestricted ECM:

```gauss
qECMOut = qardlECM(data, 2, 1, tau);
qUECMOut = qardlECM(data, 2, 1, tau, "iid", 0, 0, "uecm");
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
The robust and HAC wrappers accept the same final `ecm_type` argument.

Use `pqorder` directly when you only need lag selection:

```gauss
{ pst, qst } = pqorder(data);
{ pst, qst } = pqorder(data, pend = 8, qend = 8, criterion = "aic");
{ pg, qg } = pqorder(data, pend = 8, qend = 8, criterion = "gets",
                     gets_pval = 0.1);
{ pst, qst } = pqorderRange(data, 2, 8, 1, 4, "bic");
ic_grid = pqorderGrid(data, 8, 8, "bic");
```

Supported lag-selection criteria are `"bic"` (default), `"aic"`, `"hq"`,
`"hqc"`, and `"gets"`. GETS starts from the maximum lag orders and removes
highest-order lag blocks while their Wald p-values exceed `gets_pval`
(default `0.1`). `qardlFull` accepts the same criterion:

```gauss
qfOut = qardlFull(data, tau = tau, verbose = 0, criterion = "hq");
qfGets = qardlFull(data, tau = tau, verbose = 0, criterion = "gets",
                   gets_pval = 0.1);
```

Use `pqorderRange` when you need a restricted lag-search grid. For example,
`pqorderRange(data, 2, 8, 1, 4, "bic")` searches p from 2 through 8 and q from
1 through 4. Setting the start and end equal fixes a lag order.
Use `pqorderGrid` or `pqorderRangeGrid` to inspect the full search table. The
returned matrix has columns `[p, q, IC]`; the selected model is the row with the
smallest IC value. The default `pqorder`/`pqorderGrid` search includes `q = 0`;
use `pqorderRange(..., qstart = 1, ...)` when differenced-x lag terms are
required by design.

When different regressors need different distributed-lag depths, use the vector
lag-order APIs:

```gauss
{ pst_x, qvec_x } = pqorderX(data, 4, 2, "bic");
qaOut = qardlX(data, pst_x, qvec_x, tau);
qECMOut = qardlECMX(data, pst_x, qvec_x, tau);
qUECMOut = qardlECMX(data, pst_x, qvec_x, tau, "iid", 0, 0, "uecm");
```

`qvec_x` is `k x 1`, ordered the same way as the regressors in `data`.
`pqorderXGrid` returns columns `[p, q1, ..., qk, IC]`.

## Output Metadata

ARDL-family outputs expose a shared metadata baseline for downstream scripts:

```gauss
print arOut.model_family;
print arOut.depvar;
print arOut.xvars;
print arOut.covariance_type;
print arOut.estimation_start~arOut.estimation_end;
```

Common fields include `model_family`, `formula`, `depvar`, `xvars`,
`deterministic`, `covariance_type`, `selection_criterion`, `sample_start`,
`sample_end`, `estimation_start`, and `estimation_end`. Full workflows also
store search bounds in `pmax` and `qmax`. See [OUTPUT_SCHEMA.md](developer/OUTPUT_SCHEMA.md)
for the full field map.

## Prediction And Forecast Hooks

Levels-form ARDL-family estimates support in-sample prediction and simple
recursive forecast hooks through the unified dispatcher:

```gauss
ar_fit = predictARDL(arOut, data);
ar_fcst = forecastARDL(arOut, data, 4);
ar_fcst_x = forecastARDL(arOut, data, 4, "", future_x);

qa_fit = predictARDL(qaOut, data);
qa_fcst = forecastARDL(qaOut, data, 4);
```

`predictARDL` and `forecastARDL` infer whether the output is ARDL, QARDL,
NARDL, or CS-ARDL. QARDL returns one column per quantile. `predictQARDL` and
`forecastQARDL` remain available as backward-compatible QARDL aliases.
Forecast helpers hold future regressor levels fixed at their last observed
values when `future_x` is omitted. For ARDL, QARDL, and NARDL, pass an
`h x k` `future_x` matrix to use an explicit future regressor path. CS-ARDL
future panel paths and forecast intervals are deferred. See
[FORECASTING_VALIDATION.md](validation/FORECASTING_VALIDATION.md).

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
qfOut = qardlFull(df, formula = "consumption ~ income + wealth");
```

Formula variable matching is case-insensitive. The RHS order is preserved in
the output data, so `"y ~ x2 + x1"` intentionally produces `[y, x2, x1]`.

## NARDL And CS-ARDL Workflows

Use `nardlFull` for the nonlinear ARDL workflow with positive and negative
partial-sum decompositions:

```gauss
nfOut = nardlFull(data, verbose = 0, criterion = "bic");
nfGets = nardlFull(data, verbose = 0, criterion = "gets");
nfOut = nardlFull(df, formula = "y ~ x1 + x2", verbose = 0, criterion = "bic");
nacOut = nardlAutoCase(df, 4, 4, "y ~ x1 + x2", 0,
                       "x1", "x2", 1, 0.1);
printNARDL(nfOut.na);
printNARDLECM(nfOut.ecm);

dmOut = nardlDynamicMultipliers(nfOut.na, 20);
print dmOut.pos;
print dmOut.neg;
```

`nardl` and `nardlECM` are available when lag orders are fixed. `nardlECM`
uses the GAUSS two-step ECM by default and accepts `ecm_type = "uecm"` for an
unrestricted ECM. `case_id = 1` through `5` controls deterministic terms in
both two-step and unrestricted ECM equations. The output
includes long-run positive and negative coefficients, long-run and short-run
asymmetry Wald tests, a UECM bounds F-statistic, fitted values, residuals, and
OLS covariance fields. `predictARDL` and `forecastARDL` infer NARDL output
structures; `predictNARDL` and `forecastNARDL` remain available.
`nardlDynamicMultipliers` computes the positive and negative adjustment paths
implied by the estimated levels equation.

Use optional `decomp_vars`, `control_vars`, and `q_control` arguments when
only selected RHS variables should be decomposed and the remaining variables
should enter as linear controls. Fixed-order `nardl` and `nardlECM` also
accept `q_decomp` as a named alias for the decomposed-variable lag order:

```gauss
// x1 is decomposed into positive and negative partial sums; x2 is a control.
naSpec = nardl(df, 2, 2, formula = "y ~ x1 + x2", print_results = 0,
               decomp_vars = "x1", control_vars = "x2", q_control = 1);
nECMSpec = nardlECM(df, 2, 2, formula = "y ~ x1 + x2", print_results = 0,
                    decomp_vars = "x1", control_vars = "x2", q_control = 1);
nCaseI2Spec = nardlECM(df, 2, 2, formula = "y ~ x1 + x2", print_results = 0,
                       decomp_vars = "x1", control_vars = "x2",
                       q_control = 1, case_id = 1);
nUECMSpec = nardlECM(df, 2, 2, formula = "y ~ x1 + x2", print_results = 0,
                     decomp_vars = "x1", control_vars = "x2",
                     q_control = 1, ecm_type = "uecm");
nCaseISpec = nardlECM(df, 2, 2, formula = "y ~ x1 + x2", print_results = 0,
                      decomp_vars = "x1", control_vars = "x2",
                      q_control = 1, ecm_type = "uecm", case_id = 1);
nfSpec = nardlFull(df, 4, 4, "y ~ x1 + x2", 0, "bic",
                   "x1", "x2", 1);
```

If `control_vars` is `""`, all RHS variables not named in `decomp_vars` are
treated as controls. The legacy `nardl(data, p, q)` shortcut still decomposes
every RHS regressor.

NARDL partial sums also accept R-style reset thresholds. The default
`d = "inf"` is the standard cumulative positive/negative partial-sum
construction. Use `d = "mean"`, `d = 0`, a custom scalar, a threshold vector,
or the aliases `thresh1` and `thresh2` for the first two decomposed variables:

```gauss
naThresh = nardl(df, 2, 2, formula = "y ~ x1 + x2", print_results = 0,
                 decomp_vars = "x1", control_vars = "x2",
                 q_control = 1, d = 0);
nfThresh = nardlFull(df, 4, 4, "y ~ x1 + x2", 0, "bic",
                     "x1", "x2", 1, "uecm", 0.1, 3, 0);
```

NARDL estimators also support R-style short-run and long-run symmetry
restrictions. Use `symmetry = "SRSR"` to constrain positive and negative
short-run change coefficients, `symmetry = "LRSR"` to constrain long-run
positive and negative effects, or `symmetry = "both"`:

```gauss
nSym = nardlECM(df, 2, 2, formula = "y ~ x1 + x2", print_results = 0,
                decomp_vars = "x1", control_vars = "x2",
                q_control = 1, ecm_type = "uecm",
                symmetry = "both");
```

Use `csardlFull` for pooled cross-sectionally augmented ARDL panels:

```gauss
cfOut = csardlFull(panel, cs_lags = 1, verbose = 0, criterion = "bic");
cfGets = csardlFull(panel, cs_lags = 1, verbose = 0, criterion = "gets");
cfOut = csardlFull(df_panel, cs_lags = 1, formula = "y ~ x1 + x2",
                   verbose = 0, criterion = "bic");
cfOut = csardlFull(df_panel, cs_lags = 1, formula = "y ~ x1 + x2",
                   verbose = 0, criterion = "bic",
                   group_var = "country", time_var = "year");
printCSARDL(cfOut.csa);
printCSARDLECM(cfOut.ecm);
```

`csardlECM` and `csardlFull` also use `ecm_type = "two-step"` by default and
accept `ecm_type = "uecm"` for unrestricted ECM estimation.

CS-ARDL matrix input must be a balanced panel stacked by unit in
`[unit_id, y, x1, ...]` order. Dataframe formula input uses `"y ~ x1 + x2"`;
the panel unit variable is inferred as the first string/category column and
the time variable is inferred as the first date column, falling back to the
first numeric column if no date column exists. CS-ARDL sorts dataframe input
by the inferred unit/time columns before building the estimator matrix.
Unbalanced panels and missing panel cells are not currently supported; align or
balance the panel before estimation. Formula strings do not include explicit
unit/time terms. You can choose identifiers explicitly with `group_var` and
`time_var`; leaving either as `""` uses the GAUSS panel-data convention.
Use `csardlDiagnostics` for the optional mean-group, poolability,
Pesaran-Yamagata slope homogeneity, and Pesaran CD cross-sectional dependence
diagnostic layer:

```gauss
diagOut = csardlDiagnostics(df_panel, cfOut.pst, cfOut.qst, cfOut.cs_lags,
                            "y ~ x1 + x2", 0, "country", "year");
printCSARDLDiagnostics(diagOut);
```

The default `cd_order = -1` uses all residual pairs for Pesaran CD. Pass a
positive final argument for fixed-order `CD(p)`:

```gauss
diagCD1 = csardlDiagnostics(df_panel, cfOut.pst, cfOut.qst, cfOut.cs_lags,
                            "y ~ x1 + x2", 0, "country", "year", 1);
```

## Metadata

Core output structures carry enough metadata for downstream code:

```gauss
print qaOut.tau;
print arOut.p~arOut.q~arOut.k~arOut.nobs;
print qaOut.p~qaOut.q~qaOut.k~qaOut.nobs;
print qaOut.qvec;
print qECMOut.p~qECMOut.q~qECMOut.k~qECMOut.nobs;
```

`ardlFullOut` and `qardlFullOut` store selected lag orders as `pst` and `qst`,
plus the input sample size in `nobs`.

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
qirfBandOut =
    blockBootstrapQIRF(data, 2, 1, 20, tau, 1, 1, 999, 0, 0.05, 12345);
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

## Table Export

Use the generic table exporter for publication-style coefficient tables:

```gauss
saveARDLTable(arOut, "ardl_table.md", "markdown", 4, 1, 0.95);
saveARDLMarkdown(naOut, "nardl_table.md", 4, 1, 0.95);
saveARDLLaTeX(csaOut, "csardl_table.tex", 4, 1, 0.95);
```

The exporter dispatches on ARDL, QARDL, NARDL, CS-ARDL, ECM, and full-workflow
output structures. Set `stars = 0` to omit significance codes or
`ci_level = 0` to omit confidence-interval columns.

## Plot Confidence Bands

Plot helpers use uncertainty already stored in output structures:

```gauss
plotQARDL(qaOut, tau, 1, 0.05);
plotQARDLbands(qaOut, tau, 0.05);
plotRollingQARDL(rqaOut, tau, 0, 1, 0.05);
plotRollingQARDLECM(rECMOut, tau, 0, 1, 0.05);
plotQIRF(qOut, 1);
```

`rollingQardlECM` accepts `ecm_type = "uecm"` when rolling unrestricted ECM
paths are needed.

For QIRF bands, create `qOut` with `blockBootstrapQIRF`; `qirf` itself returns
point estimates and zero band placeholders.

## Diagnostic Workflow

The standard QARDL workflow currently includes:

- Information-criterion lag selection through `pqorder`/`pqorderGrid` and
  `ardlFull`/`qardlFull`.
- ARDL bounds testing through `ardlbounds`, `ardlboundsCase`, `ardlFull`, and
  `qardlFull`.
- Parameter p-values through `qardl_pval` and `qardl_pval_ecm`.
- Quantile constancy and symmetry Wald tests through `wtestconst` and
  `wtestsym`, plus custom Wald restrictions through `wtestlrb`, `wtestsrp`,
  and `wtestsrg`.
- Robust and HAC covariance options for QARDL levels and ECM estimators.
- Bootstrap diagnostic wrappers that report requested, completed, and failed
  replications.
- Rolling QARDL and QARDL-ECM workflows for exploratory stability analysis.
- Residual diagnostics for time-series ARDL-family outputs through
  `ardlResidualDiagnostics` and `printARDLResidualDiagnostics`.

The standard ARDL workflow currently includes OLS covariance output, fitted
values, residuals, residual variance, residual serial-correlation,
heteroskedasticity, and normality diagnostics through
`ardlResidualDiagnostics`, ARDL bounds-test integration through `ardlFull`,
and `predictARDL`/`forecastARDL` hooks.

The standard NARDL workflow currently includes long-run and short-run
asymmetry Wald tests, a UECM bounds F-statistic, dynamic multipliers, fitted
values, residuals, and residual variance fields.

The standard CS-ARDL workflow currently includes pooled coefficient
diagnostics, cross-sectional-average controls, fitted values, residuals,
residual variance fields, and optional mean-group, poolability,
Pesaran-Yamagata, and Pesaran CD residual cross-sectional dependence
diagnostics.

Bounds testing support is summarized in
[BOUNDS_TESTING_SUPPORT.md](guides/BOUNDS_TESTING_SUPPORT.md). The legacy
`ardlbounds` wrapper and full ARDL/QARDL workflows use Case III, while
`ardlboundsCase`, `ardlboundsCaseCV`, and the simulation APIs support PSS
Cases I-V directly.

`ardlResidualDiagnostics` currently covers Ljung-Box and BG LM
serial-correlation diagnostics, Breusch-Pagan-style and ARCH LM
heteroskedasticity diagnostics, Jarque-Bera normality, RESET, and residual
CUSUM/CUSUMSQ stability checks for ARDL, QARDL, QARDL-ECM, NARDL, and
NARDL-ECM outputs. Full recursive-residual stability tests and unit-aware
CS-ARDL panel residual diagnostics are deferred.

## Quantile Impulse Responses

`qirf` traces the dynamic response of `y` to a unit shock in an x variable:

```gauss
qOut = qirf(qaOut, qaOut.p, qaOut.q, 20, qaOut.tau, k_x = 1, permanent = 1);
plotQIRF(qOut, 1);

qBandOut = blockBootstrapQIRF(data, qaOut.p, qaOut.q, 20, qaOut.tau,
                              1, 1, 499, 0, 0.05, 12345);
plotQIRF(qBandOut, 1);
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
{ Fstat, tstat, cv_sim, case_id, q_restrict } =
    ardlboundsCaseSim(data, 2, 1, 5, 40000, 12345);
```

Cases follow the Pesaran, Shin & Smith convention: I no intercept/no trend, II
restricted intercept/no trend, III unrestricted intercept/no trend, IV
unrestricted intercept/restricted trend, and V unrestricted
intercept/unrestricted trend. This package ships tabulated PSS asymptotic F
critical values for Cases I-V and k=0 through k=10. It also provides
simulation-based critical values through `ardlboundsCaseSim` and
`ardlboundsCaseSimCV` for finite samples, non-tabulated significance levels,
and k values beyond the bundled table. Use a large replication count for
applied inference.

## Limitations

- Individual p-values use asymptotic normal approximations.
- Wald tests use chi-squared asymptotics and depend on correctly specified
  restriction matrices. Rank-deficient Wald covariance matrices use a
  pseudoinverse with rank-adjusted chi-squared degrees of freedom and print a
  warning.
- HAC/robust covariance support is available for levels-form beta/gamma/phi
  covariance and QARDL ECM alpha/rho covariance in both two-step and UECM
  modes. The default estimators preserve the original covariance formulas
  unless an alternate covariance type is requested.
- `ardlboundsCase` computes deterministic Cases I-V and the bounds t-statistic.
  PSS asymptotic F critical values are bundled for Cases I-V with up to 10
  regressors; simulation-based critical values are available for the wider
  case/k/sample surface.
- Rolling window length is fixed internally at 10 percent of the sample.
- Bootstrap defaults are convenient starting points; applied work should
  report the chosen number of replications, block length, and seed.
- Residual serial-correlation, heteroskedasticity, normality, and
  residual-bridge CUSUM/CUSUMSQ stability diagnostics are available for
  time-series ARDL-family outputs. Full recursive-residual stability tests and
  unit-aware CS-ARDL panel residual diagnostics are deferred.
- `p = 0` models are not currently supported. `q = 0` is supported for levels,
  ECM, lag-selection, QIRF, and ARDL bounds workflows.

## References

See the README references section for the full bibliography covering QARDL,
ARDL bounds testing, quantile regression, HAC covariance, lag-selection
criteria, block/stationary bootstrap methods, and panel diagnostics.
