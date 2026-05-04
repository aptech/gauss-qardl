# GAUSS QARDL Library

A [GAUSS](https://www.aptech.com) application package implementing the **Quantile Autoregressive Distributed Lag (QARDL)** model from Cho, Kim & Shin (2015). QARDL extends standard ARDL cointegration to allow long-run and short-run parameters to vary across quantiles of the conditional distribution of `y_t`, enabling tests for asymmetric cointegration and heterogeneous adjustment speeds.

> This library is based on original GAUSS code by [Jin Seo Cho](https://web.yonsei.ac.kr/jinseocho/qardl.htm), updated to use GAUSS structures, the built-in `quantileFit` procedure, and modern language features.

---

## Contents

- [What is GAUSS?](#what-is-gauss)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Formula String Support](#formula-string-support)
- [The QARDL Model](#the-qardl-model)
- [Procedures](#procedures)
  - [Integrated Workflow](#integrated-workflow)
  - [Lag Order Selection](#lag-order-selection)
  - [QARDL Levels Estimation](#qardl-levels-estimation)
  - [QARDL-ECM Estimation](#qardl-ecm-estimation)
  - [Inference](#inference)
  - [Rolling Estimation](#rolling-estimation)
  - [Bootstrap Confidence Intervals](#bootstrap-confidence-intervals)
  - [Quantile Impulse Responses](#quantile-impulse-responses)
  - [Plotting](#plotting)
  - [Export](#export)
- [Output Structures](#output-structures)
- [Wald Tests](#wald-tests)
- [ARDL Bounds Test](#ardl-bounds-test)
- [Examples](#examples)
- [Development and Tests](#development-and-tests)
- [Usage Guide](#usage-guide)
- [Reference](#reference)

---

## What is GAUSS?

[**GAUSS**](https://www.aptech.com) is a fast, matrix-based environment for statistical computing, estimation, simulation, and visualization. The QARDL library loads via `library qardl;`, requires **GAUSS 26 or later**, and depends only on GAUSS's built-in `quantileFit` — no additional libraries needed.

---

## Installation

**GAUSS 26+ (Package Manager)**

Install and update directly from within GAUSS using the [GAUSS Package Manager](https://www.aptech.com/blog/gauss-package-manager-basics/).

**Manual installation**

1. Download `qardl_3.0.0.zip` from the [Releases page](https://github.com/aptech/gauss-qardl/releases).
2. In GAUSS, select **Tools > Install Application** and follow the prompts.
3. Load the library in your program:

```gauss
library qardl;
```

---

## Quick Start

```gauss
library qardl;

// Load data: column 1 = y, remaining columns = x
data = loadd("mydata.csv");

// One-call workflow: lag selection + bounds test + QARDL + ECM
qfOut = qardlFull(data, 8, 8);

// Or step by step:
{ pst, qst } = pqorder(data);
qaOut = qardl(data, pst, qst);
printQARDL(qaOut);
plotQARDL(qaOut);
```

---

## Formula String Support

The library supports Wilkinson formula strings (`"y ~ x1 + x2"`) for working with named-column dataframes without manually reordering columns.

**Preprocessing with `applyQARDLFormula`** (works with all procedures):

```gauss
data = loadd("macro.csv");  // columns: date, gdp, consumption, income, wealth

// Preprocess once, then use with any procedure
data = applyQARDLFormula(data, "consumption ~ income + wealth");
{ pst, qst } = pqorder(data);
qaOut = qardl(data, pst, qst);
```

**Integrated formula in `qardlFull`** (formula applied internally):

```gauss
data = loadd("macro.csv");
qfOut = qardlFull(data, 8, 8, formula = "consumption ~ income + wealth");
```

The formula syntax is `"y ~ x1 + x2 + ..."`. Variable names are matched case-insensitively against dataframe column names.

---

## The QARDL Model

**Levels form** estimated by `qardl()`:

```
y_t = α(τ) + γ_0(τ)Δx_t + ... + γ_{q-1}(τ)Δx_{t-q+1}
          + θ(τ)x_t + φ_1(τ)y_{t-1} + ... + φ_p(τ)y_{t-p} + u_t(τ)
```

Derived ECM parameters returned alongside the levels estimates:

| Symbol | Formula | Description |
|--------|---------|-------------|
| β(τ) | θ(τ) / (1 − Σφ_j(τ)) | Long-run coefficient |
| ρ(τ) | −(1 − Σφ_j(τ)) | Speed of adjustment |
| α(τ) | bt[1, τ] | Intercept |

**ECM form** directly estimated by `qardlECM()` (two-step):

```
Δy_t = α(τ) + ρ(τ)·EC_{t-1} + Σψ_j(τ)Δy_{t-j} + Σδ_j(τ)Δx_{t-j} + u_t(τ)
```

where `EC_{t-1} = y_{t-1} − β_OLS'·x_{t-1}`.

---

## Procedures

### Integrated Workflow

#### `qardlFull`

Runs the complete QARDL pipeline in a single call: BIC lag selection → ARDL bounds test → levels estimation → ECM estimation. Results are printed automatically.

```gauss
qfOut = qardlFull(data, pend, qend);
qfOut = qardlFull(data, pend, qend, tau = { 0.25, 0.5, 0.75 }, formula = "", verbose = 1);
qfOut = qardlFull(data, 8, 8, tau, "", 0, "aic");
qfOut = qardlFull(data, 8, 8, tau, "", 0, "bic", "hac", 4);
```

| Argument | Default | Description |
|----------|---------|-------------|
| `data` | — | `(T × (1+k))` matrix or dataframe |
| `pend` | — | Maximum AR lag to search |
| `qend` | — | Maximum DL lag to search |
| `tau` | `{ 0.25, 0.5, 0.75 }` | Quantile vector |
| `formula` | `""` | Wilkinson formula string |
| `verbose` | `1` | `1` prints workflow summaries; `0` computes silently |
| `criterion` | `"bic"` | Lag-selection criterion: `"bic"`, `"aic"`, `"hq"`, or `"hqc"` |
| `cov_type` | `"iid"` | Covariance estimator: `"iid"`, `"robust"`, or `"hac"` |
| `hac_lags` | `0` | HAC lag truncation; `0` selects the automatic bandwidth |

Returns a `qardlFullOut` structure (see [Output Structures](#output-structures)).

---

### Lag Order Selection

#### `pqorder`

Information-criterion selection of ARDL lag orders. BIC is the default.

```gauss
{ pst, qst } = pqorder(data);
{ pst, qst } = pqorder(data, pend = 8, qend = 8);
{ pst, qst } = pqorder(data, 8, 8, "aic");
{ pst, qst } = pqorderRange(data, 2, 8, 1, 4, "bic");
ic_grid = pqorderGrid(data, 8, 8, "bic");
```

| Argument | Default | Description |
|----------|---------|-------------|
| `data` | — | `(n × (1+k))` matrix, y in column 1 |
| `pend` | `8` | Maximum AR lag to search |
| `qend` | `8` | Maximum distributed lag to search |
| `criterion` | `"bic"` | `"bic"`, `"aic"`, `"hq"`, or `"hqc"` |

Use `pqorderRange(data, pstart, pend, qstart, qend, criterion)` to restrict the
searched grid. Setting `pstart == pend` or `qstart == qend` pins that lag order.
Use `pqorderGrid` or `pqorderRangeGrid` to return the full search table with
columns `[p, q, IC]`.

---

### QARDL Levels Estimation

#### `qardl`

```gauss
qaOut = qardl(data, ppp, qqq);
qaOut = qardl(data, ppp, qqq, tau = { 0.25, 0.5, 0.75 });
qaOut = qardl(data, ppp, qqq, tau, "hac", 4);
qaOut = qardlRobust(data, ppp, qqq, tau);
qaOut = qardlHAC(data, ppp, qqq, tau, 4);
```

| Argument | Default | Description |
|----------|---------|-------------|
| `data` | — | `(n × (1+k))` matrix |
| `ppp` | — | AR lag order p ≥ 1 |
| `qqq` | — | Distributed-lag order q ≥ 1 |
| `tau` | `{ 0.25, 0.5, 0.75 }` | `(s × 1)` quantile vector |
| `cov_type` | `"iid"` | `"iid"`, `"robust"`, or `"hac"` |
| `hac_lags` | `0` | HAC lag truncation; `0` selects the automatic bandwidth |

Returns a `qardlOut` structure. The default `qardl` covariance preserves the
original QARDL asymptotic covariance formulas. Use `qardlRobust` for a
heteroskedasticity-robust QR sandwich covariance, or `qardlHAC` for a
Newey-West/Bartlett HAC QR sandwich covariance with delta-method long-run beta
covariance. Passing `hac_lags = 0` to `qardlHAC` uses
`floor(4*(T/100)^(2/9))`.

---

### QARDL-ECM Estimation

#### `qardlECM`

Two-step estimator: OLS long-run relationship → quantile ECM.

```gauss
qECMOut = qardlECM(data, ppp, qqq);
qECMOut = qardlECM(data, ppp, qqq, tau = { 0.25, 0.5, 0.75 });
qECMOut = qardlECM(data, ppp, qqq, tau, "hac", 4);
qECMOut = qardlECMRobust(data, ppp, qqq, tau);
qECMOut = qardlECMHAC(data, ppp, qqq, tau, 4);
```

Returns a `qardlECMOut` structure. The default `qardlECM` covariance is the
stationary-regressor QR asymptotic covariance. Use `qardlECMRobust` for a
heteroskedasticity-robust QR sandwich covariance, or `qardlECMHAC` for a
Newey-West/Bartlett HAC QR sandwich covariance. Passing `hac_lags = 0` to
`qardlECMHAC` uses the automatic bandwidth `floor(4*(T/100)^(2/9))`.

```gauss
print qECMOut.beta_lr;            // OLS long-run coefficients
print qECMOut.rho;                // speed of adjustment at each quantile
print sqrt(diag(qECMOut.rho_cov)); // standard errors of rho
```

---

### Inference

#### `qardl_pval` — individual z-test p-values

```gauss
{ p_beta, p_phi, p_gamma } = qardl_pval(qaOut);
```

Uses asymptotic standard normal. Do **not** use t-distribution; QR asymptotics are normal.

#### `qardl_pval_ecm` — ECM p-values

```gauss
{ p_alpha, p_rho } = qardl_pval_ecm(qECMOut);
```

#### `printQARDL` — formatted levels results table

```gauss
printQARDL(qaOut);
printQARDL(qaOut, tau = { 0.25, 0.5, 0.75 });
```

#### `printQARDLECM` — formatted ECM results table

Prints OLS long-run coefficients plus quantile-varying α(τ) and ρ(τ) with SE, z-stat, and p-value.

```gauss
printQARDLECM(qECMOut);
printQARDLECM(qECMOut, tau = { 0.25, 0.5, 0.75 });
```

---

### Rolling Estimation

#### `rollingQardl`

Rolling-window QARDL with Wald tests. Window size is fixed at 10% of the series length.

```gauss
struct waldTestRestrictions waldR;
waldR.bigR_beta  = ...;   waldR.smlr_beta  = ...;
waldR.bigR_phi   = ...;   waldR.smlr_phi   = ...;
waldR.bigR_gamma = ...;   waldR.smlr_gamma = ...;

rqaOut = rollingQardl(data, pend, qend, tau, waldR);
```

Returns a `rollingQardlOut` structure.

#### `rollingQardlECM`

Rolling-window QARDL-ECM.

```gauss
rECMOut = rollingQardlECM(data, ppp, qqq);
rECMOut = rollingQardlECM(data, ppp, qqq, tau = { 0.25, 0.5, 0.75 });
```

Returns a `rollingQardlECMOut` structure.

---

### Bootstrap Confidence Intervals

#### `blockBootstrapQARDL`

Moving-block bootstrap (Künsch 1989) CIs for β, γ, and φ.

```gauss
{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDL(data, ppp, qqq);
{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDL(data, ppp, qqq,
    tau = { 0.25, 0.5, 0.75 }, B = 999, blk_len = 0, alpha = 0.05);
{ ci_beta, ci_gamma, ci_phi } =
    blockBootstrapQARDLMethod(data, ppp, qqq, tau, 999, 0, 0.05, "circular");
{ ci_beta, ci_gamma, ci_phi, boot_diag } =
    blockBootstrapQARDLDiag(data, ppp, qqq, tau, 999, 0, 0.05, 12345);
```

Each CI output is a `(dim × 2)` matrix of `[lower, upper]` bounds. The
diagnostic variant sets `rndseed` when `seed > 0` and returns diagnostics
`[B requested, B completed, B failed, blk_len, seed]`.
Rank-deficient bootstrap resamples are skipped and counted as failed
replications.
`blockBootstrapQARDLMethod` supports `"moving"`, `"circular"`, and
`"stationary"` resampling.

#### `blockBootstrapQARDLECM`

Moving-block bootstrap CIs for the ECM speed-of-adjustment ρ(τ) and intercept α(τ).

```gauss
{ ci_rho, ci_alpha } = blockBootstrapQARDLECM(data, ppp, qqq);
{ ci_rho, ci_alpha } = blockBootstrapQARDLECM(data, ppp, qqq,
    tau = { 0.25, 0.5, 0.75 }, B = 999, blk_len = 0, alpha = 0.05);
{ ci_rho, ci_alpha } =
    blockBootstrapQARDLECMMethod(data, ppp, qqq, tau, 999, 0, 0.05, "stationary");
{ ci_rho, ci_alpha, boot_diag } =
    blockBootstrapQARDLECMDiag(data, ppp, qqq, tau, 999, 0, 0.05, 12345);
```

Each CI output is an `(ss × 2)` matrix of `[lower, upper]` bounds.
`blockBootstrapQARDLECMMethod` supports `"moving"`, `"circular"`, and
`"stationary"` resampling.

---

### Quantile Impulse Responses

#### `qirf`

Computes quantile impulse response functions from a fitted QARDL model. Uses all coefficient information stored in `qaOut.bt` to trace the dynamic response of y to a unit shock in x variable `k_x`.

```gauss
qirfOut = qirf(qaOut, ppp, qqq, H);
qirfOut = qirf(qaOut, ppp, qqq, H,
    tau = { 0.25, 0.5, 0.75 }, k_x = 1, permanent = 1);
```

| Argument | Default | Description |
|----------|---------|-------------|
| `qaOut` | — | `qardlOut` from `qardl()` |
| `ppp` | — | AR lag order used in estimation |
| `qqq` | — | DL lag order used in estimation |
| `H` | — | Maximum horizon |
| `tau` | `{ 0.25, 0.5, 0.75 }` | Quantile vector |
| `k_x` | `1` | Index of shocked x variable (1-based) |
| `permanent` | `1` | `1` = permanent shock; `0` = temporary (one-period) shock |

Returns a `qirfOut` structure. The long-run response converges to β(τ) for a permanent shock when |Σφ_j| < 1.

#### `plotQIRF`

```gauss
plotQIRF(qirfOut);
```

Produces one panel per quantile, showing the response path over horizons 0,...,H.

---

### Plotting

#### `plotQARDL` — quantile process plots

```gauss
plotQARDL(qaOut);
plotQARDL(qaOut, tau = { 0.25, 0.5, 0.75 });
```

Produces a 4-row layout: β, γ, φ, and α/ρ vs. τ.

#### `plotQARDLbands` — plots with ±1.96·SE bands

```gauss
plotQARDLbands(qaOut);
plotQARDLbands(qaOut, tau = { 0.25, 0.5, 0.75 });
```

3-row layout (β, γ, φ) with dashed 95% pointwise confidence bands.

#### `plotRollingQARDLECM` — rolling ECM parameter plot

```gauss
plotRollingQARDLECM(rECMOut);
plotRollingQARDLECM(rECMOut, tau = { 0.25, 0.5, 0.75 }, dates = 0);
```

2-row layout: ρ(τ,t) (top) and α(τ,t) (bottom), one panel per quantile, with ±1.96·SE bands. Pass a `(num_est × 1)` date vector for the x-axis, or `0` (default) to use window indices.

#### `plotRollingQARDL` — rolling long-run beta plot

```gauss
plotRollingQARDL(rqaOut);
plotRollingQARDL(rqaOut, tau = { 0.25, 0.5, 0.75 }, dates = 0);
```

Grid with ss rows (quantiles) × k columns (x variables), showing rolling β(τ,t) with ±1.96·SE bands.

---

### Export

#### `saveQARDLResults`

Writes β, γ, φ, and ECM parameters to CSV files.

```gauss
saveQARDLResults(qaOut);
saveQARDLResults(qaOut, tau, outdir = "results/");
```

Output files: `qardl_beta.csv`, `qardl_gamma.csv`, `qardl_phi.csv`, `qardl_ecm.csv`.

#### `saveQARDLECMResults`

Writes OLS long-run coefficients and quantile ECM parameters to CSV files.

```gauss
saveQARDLECMResults(qECMOut);
saveQARDLECMResults(qECMOut, tau, outdir = "results/");
```

Output files: `qardl_ecm_lr.csv` (OLS β), `qardl_ecm_qr.csv` (QR α and ρ with SE, z, p-value).

---

## Output Structures

### `qardlOut`

Returned by `qardl()`, `qardlRobust()`, and `qardlHAC()`.

| Member | Dimensions | Description |
|--------|-----------|-------------|
| `tau` | `s × 1` | Quantile vector used in estimation |
| `p` | scalar | AR lag order used in estimation |
| `q` | scalar | Distributed-lag order used in estimation |
| `nobs` | scalar | Effective estimation sample size after lag alignment |
| `k` | scalar | Number of regressors |
| `bigbt` | `(k·s) × 1` | Long-run β, stacked by quantile |
| `bigbt_cov` | `(k·s) × (k·s)` | Asymptotic covariance of β |
| `phi` | `(p·s) × 1` | Short-run φ, stacked by quantile |
| `phi_cov` | `(p·s) × (p·s)` | Asymptotic covariance of φ |
| `gamma` | `(k·s) × 1` | Short-run γ (x-level θ), stacked by quantile |
| `gamma_cov` | `(k·s) × (k·s)` | Asymptotic covariance of γ |
| `alpha` | `s × 1` | Intercept α(τ) at each quantile |
| `rho` | `s × 1` | Adjustment speed ρ(τ) at each quantile |
| `bt` | `(1+q·k+k+p) × s` | Full quantileFit coefficient matrix (used by `qirf`) |

Parameters are stacked quantile-first: all k variables at τ₁, then τ₂, etc.

### `qardlECMOut`

Returned by `qardlECM()`, `qardlECMRobust()`, and `qardlECMHAC()`.

| Member | Dimensions | Description |
|--------|-----------|-------------|
| `tau` | `s × 1` | Quantile vector used in estimation |
| `p` | scalar | AR lag order used in estimation |
| `q` | scalar | Distributed-lag order used in estimation |
| `nobs` | scalar | Effective ECM sample size after lag alignment |
| `k` | scalar | Number of regressors |
| `beta_lr` | `k × 1` | OLS long-run coefficients (Step 1) |
| `rho_ols` | `1 × 1` | OLS speed of adjustment |
| `alpha` | `s × 1` | ECM intercept α(τ) |
| `rho` | `s × 1` | Speed of adjustment ρ(τ) |
| `rho_cov` | `s × s` | Covariance of rho, using the selected ECM covariance estimator |
| `alpha_cov` | `s × s` | Covariance of alpha, using the selected ECM covariance estimator |

### `qardlFullOut`

Returned by `qardlFull()`.

| Member | Type | Description |
|--------|------|-------------|
| `pst` | scalar | Selected AR lag order |
| `qst` | scalar | Selected DL lag order |
| `tau` | `s × 1` | Quantile vector used in estimation |
| `nobs` | scalar | Number of observations in the input sample |
| `ardl_fstat` | scalar | ARDL bounds test F-statistic |
| `ardl_cv` | `3 × 2` | I(0)/I(1) critical values at 10%, 5%, 1% |
| `qa` | `qardlOut` | QARDL levels estimates |
| `ecm` | `qardlECMOut` | QARDL-ECM two-step estimates |

### `qirfOut`

Returned by `qirf()`.

| Member | Type | Description |
|--------|------|-------------|
| `irf` | `(H+1) × s` | Response at each horizon (row 1 = h=0 baseline) |
| `tau` | `s × 1` | Quantile vector |
| `H` | scalar | Maximum horizon |
| `k_x` | scalar | Shocked variable index |
| `permanent` | scalar | 1 = permanent shock; 0 = temporary |

### `rollingQardlECMOut`

Returned by `rollingQardlECM()`. Each row is one estimation window.

| Member | Dimensions | Description |
|--------|-----------|-------------|
| `alpha` | `num_est × s` | Rolling α(τ) |
| `rho` | `num_est × s` | Rolling ρ(τ) |
| `alpha_se` | `num_est × s` | SE of α |
| `rho_se` | `num_est × s` | SE of ρ |
| `beta_lr` | `num_est × k` | Rolling OLS β |
| `rho_ols` | `num_est × 1` | Rolling OLS ρ |

---

## Wald Tests

Five Wald test procedures are available for joint hypotheses.

| Procedure | Tests | Scaling |
|-----------|-------|---------|
| `wtestlrb(beta, cov, R, r, data)` | Long-run β | (n−1)² |
| `wtestsrp(phi, cov, R, r, data)` | Short-run φ | (n−1) |
| `wtestsrg(gamma, cov, R, r, data)` | Short-run γ | (n−1) |
| `wtestsym(qaOut, tau, data)` | Symmetry: θ(τ) = θ(1−τ) | (n−1)² / (n−1) |
| `wtestconst(qaOut, tau, data)` | Constancy: θ(τ₁) = ... = θ(τₛ) | (n−1)² / (n−1) |

All return `{ wt, pv }` — test statistic and chi-squared p-value (except `wtestsym` and `wtestconst` which return 6 values: `{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi }`).

### Constancy test

`wtestconst` tests whether parameters are constant across **all** supplied quantiles simultaneously. Rejection means quantile-varying parameters are statistically significant — i.e., QARDL adds value over OLS ARDL.

```gauss
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } = wtestconst(qaOut, tau, data);
```

### Symmetry test

`wtestsym` tests θ(τ) = θ(1−τ) for all symmetric pairs in the tau grid:

```gauss
tau = { 0.25, 0.5, 0.75 };
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } = wtestsym(qaOut, tau, data);
```

### Setting up custom restriction matrices

Parameters are stored quantile-first. For `k=2` variables and `tau = {0.25, 0.5, 0.75}`, the column order of β is:

```
β₁(0.25)  β₂(0.25)  β₁(0.50)  β₂(0.50)  β₁(0.75)  β₂(0.75)
```

To test H₀: β₁(0.25) = β₁(0.50) = β₁(0.75):

```gauss
bigR = { 1 0 -1 0  0 0,
         0 0  1 0 -1 0 };
smlr = { 0, 0 };

{ wt, pv } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, bigR, smlr, data);
```

---

## ARDL Bounds Test

`ardlbounds` implements the Pesaran, Shin & Smith (2001) F-test for the existence of a long-run levels relationship.

```gauss
{ Fstat, cv } = ardlbounds(data, ppp, qqq);
ardlbounds_print(Fstat, cv, k);
```

`cv` is a `(3 × 2)` matrix of I(0)/I(1) critical value bounds at 10%, 5%, and 1% for up to k=10 regressors (Case III: unrestricted intercept, no trend).

---

## Examples

The `examples/` directory contains the following worked programs:

| File | Description |
|------|-------------|
| `demo.e` | Modern end-to-end workflow with `qardlFull`, metadata, automatic tests, QIRF, bootstrap, and plots |
| `qardlestimation.e` | Simulated-data workflow using `qardlFull(..., verbose = 0)`, p-values, QIRF, and ECM bootstrap |
| `qardl_est_tests.e` | Estimation and inference with formatted print helpers, automatic tests, and custom Wald restrictions |
| `rolling_qardl.e` | Rolling QARDL and rolling ECM using metadata and modern plot helpers |
| `sp500.e` | S&P 500 application using dataframe formula support and the integrated workflow |
| `wald_tests_sim.e` | Long Monte Carlo simulation for custom Wald-test distributions |

More discussion of the model and results can be found in the blog post [The Quantile Autoregressive-Distributed Lag Parameter Estimation and Interpretation in GAUSS](https://www.aptech.com/blog/the-quantile-autoregressive-distributed-lag-parameter-estimation-and-interpretation-in-gauss/).

---

## Development and Tests

The `tests/` directory contains GAUSS 26 smoke tests for the source tree and installed package. See `GOLD_STANDARD_TODO.md` for the current release-readiness backlog and `RELEASE_CHECKLIST.md` for release steps.

From the GAUSS command line or terminal, run from the `tests` directory:

```gauss
run smoke_public_api.e;
run smoke_workflow_api.e;
run smoke_export_api.e;
```

From Windows PowerShell, one equivalent batch command is:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_source_tests.ps1
```

The modern examples can be smoke-tested with:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_examples_smoke.ps1
```

Before publishing a release, reinstall the package and verify that `library qardl;` exposes every procedure listed in `package.json`, especially newer files such as `wtestconst.src` and `qirf.src`.

```gauss
run package_public_api.e;
```

---

## Usage Guide

For guidance on choosing between `qardlFull`, `qardl`, and `qardlECM`, formula dataframe workflows, parameter stacking, bootstrap intervals, QIRF, and current limitations, see [`docs/USAGE_GUIDE.md`](docs/USAGE_GUIDE.md).

---

## Reference

- Cho, J.S., Kim, T-H., Shin, Y. (2015). Quantile cointegration in the autoregressive distributed-lag modeling framework. *Journal of Econometrics*, 188(1), 281–300.
- Pesaran, M.H., Shin, Y. & Smith, R.J. (2001). Bounds testing approaches to the analysis of level relationships. *Journal of Applied Econometrics*, 16(3), 289–326.
- Künsch, H.R. (1989). The jackknife and the bootstrap for general stationary observations. *Annals of Statistics*, 17(3), 1217–1241.
- Original author's page: https://web.yonsei.ac.kr/jinseocho/qardl.htm

---

## Authors

[Eric Clower](mailto:eric@aptech.com) — [Aptech Systems, Inc](https://www.aptech.com/)

[![Facebook](https://www.aptech.com/wp-content/uploads/2019/02/fb.png)](https://www.facebook.com/GAUSSAptech/)
[![GitHub](https://www.aptech.com/wp-content/uploads/2019/02/gh.png)](https://github.com/aptech)
[![LinkedIn](https://www.aptech.com/wp-content/uploads/2019/02/li.png)](https://linkedin.com/in/ericaclower)
