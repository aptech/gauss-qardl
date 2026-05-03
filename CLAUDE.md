# CLAUDE.md — GAUSS QARDL Library

Context file for Claude Code sessions working on this repository.

## What this library does

Implements the **Quantile Autoregressive Distributed Lag (QARDL)** model from Cho, Kim & Shin (2015), which extends ARDL cointegration to allow long-run and short-run parameters to vary across quantiles of the conditional distribution of `y_t`. Use cases: testing for asymmetric cointegration, studying heterogeneous adjustment speeds.

The library is a **GAUSS application package** (version 3.0.0). It loads via `library qardl;` and depends only on GAUSS's built-in `quantileFit` (no external library required).

## Repository layout

```
src/
  qardl.sdf          # Structure definitions (qardlOut, qardlECMOut, rollingQardlOut,
                     #   rollingQardlECMOut, qardlFullOut, qirfOut)
  qardl.src          # Core procedures: qardl(), qardlECM(), rollingQardl(),
                     #   rollingQardlECM(), plotQARDL(), plotQARDLbands(),
                     #   plotRollingQARDL(), plotRollingQARDLECM(),
                     #   saveQARDLResults(), saveQARDLECMResults(),
                     #   blockBootstrapQARDL(), blockBootstrapQARDLECM(),
                     #   printQARDL(), printQARDLECM(), qardlFull(), _applyFormula()
  icmean.src         # BIC-based lag order selection: icmean(), pqorder()
  p_values_qardl.src # qardl_pval(), qardl_pval_ecm() — asymptotic z-test p-values
  wtestlrb.src       # wtestlrb() — Wald test for long-run beta
  wtestsrp.src       # wtestsrp() — Wald test for short-run phi
  wtestsrg.src       # wtestsrg() — Wald test for short-run gamma
  wtestsym.src       # wtestsym() — quantile symmetry Wald test H0: theta(tau)=theta(1-tau)
  wtestconst.src     # wtestconst() — cross-quantile constancy Wald test
  ardlbounds.src     # ardlbounds(), ardlbounds_print() — PSS (2001) bounds F-test
  qirf.src           # qirf(), plotQIRF() — quantile impulse response functions
examples/
  demo.e             # Main worked example
  qardlestimation.e  # Monte Carlo simulation of QARDL estimation
  qardl_est_tests.e  # Estimation with Wald tests
  wald_tests_sim.e   # Wald test size simulation
  rolling_qardl.e    # Rolling QARDL example
  sp500.e            # S&P 500 application
tests/
  smoke_public_api.e # GAUSS 26 source-tree smoke test for public procedures
  smoke_workflow_api.e # GAUSS 26 source-tree smoke test for qardlFull/formula workflow
  package_public_api.e # Installed-package release gate using `library qardl`
  verify_package_manifest.ps1 # package.json/src consistency check
package.json         # GAUSS package manifest (name: qardl, version: 3.0.0)
GOLD_STANDARD_TODO.md # Release-readiness inventory and improvement backlog
CHANGELOG.md         # Release notes
RELEASE_CHECKLIST.md # Release validation steps
```

## The QARDL model

**Levels form** estimated by `qardl()`:

```
y_t = α(τ) + γ_0(τ)Δx_t + ... + γ_{q-1}(τ)Δx_{t-q+1}
          + θ(τ)x_t + φ_1(τ)y_{t-1} + ... + φ_p(τ)y_{t-p} + u_t(τ)
```

Derived ECM parameters (stored in `qardlOut`):
- **β(τ)** = θ(τ) / (1 − Σφ_j(τ))  — long-run coefficient, stored in `qaOut.bigbt`
- **ρ(τ)** = −(1 − Σφ_j(τ))        — speed of adjustment, stored in `qaOut.rho`
- **α(τ)** = bt[1,τ]                — intercept, stored in `qaOut.alpha`

**ECM form** directly estimated by `qardlECM()` (two-step):

```
Δy_t = α(τ) + ρ(τ)·EC_{t-1} + Σψ_j(τ)Δy_{t-j} + Σδ_j(τ)Δx_{t-j} + u_t(τ)
```

where `EC_{t-1} = y_{t-1} − β_OLS'·x_{t-1}` uses OLS β from Step 1.

## `qardlOut` structure fields

| Field | Dimensions | Description |
|-------|-----------|-------------|
| `tau` | `s x 1` | Quantile vector used in estimation |
| `p` | scalar | AR lag order used in estimation |
| `q` | scalar | Distributed-lag order used in estimation |
| `nobs` | scalar | Effective estimation sample size after lag alignment |
| `k` | scalar | Number of regressors |
| `bigbt` | `(k·s) x 1` | Long-run β, stacked: all k vars at τ_1, then τ_2, ... |
| `bigbt_cov` | `(k·s) x (k·s)` | Asymptotic covariance of bigbt |
| `phi` | `(p·s) x 1` | Short-run φ lags, stacked by quantile |
| `phi_cov` | `(p·s) x (p·s)` | Asymptotic covariance of phi |
| `gamma` | `(k·s) x 1` | Short-run γ (x-level θ coefficient), stacked by quantile |
| `gamma_cov` | `(k·s) x (k·s)` | Asymptotic covariance of gamma |
| `alpha` | `s x 1` | Intercept α(τ) at each quantile |
| `rho` | `s × 1` | ECM adjustment speed ρ(τ) at each quantile |
| `bt` | `(1+q·k+k+p) x s` | Full quantileFit coefficient matrix; used by `qirf()` |

## `qardlECMOut` structure fields

| Field | Dimensions | Description |
|-------|-----------|-------------|
| `tau` | `s x 1` | Quantile vector used in estimation |
| `p` | scalar | AR lag order used in estimation |
| `q` | scalar | Distributed-lag order used in estimation |
| `nobs` | scalar | Effective ECM sample size after lag alignment |
| `k` | scalar | Number of regressors |
| `beta_lr` | `k x 1` | OLS long-run coefficients (used for EC term) |
| `rho_ols` | `1 x 1` | OLS speed of adjustment |
| `alpha` | `s x 1` | ECM intercept at each quantile |
| `rho` | `s x 1` | Directly estimated speed of adjustment at each quantile |
| `rho_cov` | `s x s` | Asymptotic covariance of ρ across quantiles |
| `alpha_cov` | `s x s` | Asymptotic covariance of α across quantiles |

## `rollingQardlECMOut` structure fields

| Field | Dimensions | Description |
|-------|-----------|-------------|
| `alpha` | `num_est x s` | Rolling α(τ); each row is one window |
| `rho` | `num_est x s` | Rolling ρ(τ); each row is one window |
| `alpha_se` | `num_est x s` | Rolling SE of α |
| `rho_se` | `num_est x s` | Rolling SE of ρ |
| `beta_lr` | `num_est x k` | Rolling OLS long-run β |
| `rho_ols` | `num_est x 1` | Rolling OLS ρ |

## New procedures (April 2026 additions)

| Procedure | File | Description |
|-----------|------|-------------|
| `qardlFull(data, pend, qend, tau, formula)` | qardl.src | Integrated workflow: lag select + bounds test + qardl + qardlECM + print |
| `printQARDLECM(qECMOut, tau)` | qardl.src | Formatted results table for qardlECMOut |
| `saveQARDLECMResults(qECMOut, tau, outdir)` | qardl.src | Export ECM α, ρ to CSV |
| `plotRollingQARDLECM(rECMOut, tau, dates)` | qardl.src | Plot rolling ρ(τ,t) and α(τ,t) with SE bands |
| `plotRollingQARDL(rqaOut, tau, dates)` | qardl.src | Plot rolling β(τ,t) with SE bands (ss×k grid) |
| `blockBootstrapQARDLECM(data, p, q, tau, B, blk_len, alpha)` | qardl.src | Moving-block bootstrap CIs for ECM ρ and α |
| `wtestconst(qaOut, tau, data)` | wtestconst.src | Wald test H₀: θ(τ₁)=…=θ(τₛ) for all quantiles simultaneously |
| `qirf(qaOut, p, q, H, tau, k_x, permanent)` | qirf.src | Quantile impulse response functions using qaOut.bt |
| `plotQIRF(qirfOut)` | qirf.src | Plot QIRF paths, one panel per quantile |

## New procedures (March 2026 additions)

| Procedure | File | Description |
|-----------|------|-------------|
| `plotQARDLbands(qaOut, tau)` | qardl.src | 3-row quantile process plot with ±1.96·SE bands for β, γ, φ |
| `saveQARDLResults(qaOut, tau, outdir)` | qardl.src | Export β, γ, φ, ECM to CSV files in `outdir/` |
| `rollingQardlECM(data, p, q, tau)` | qardl.src | Rolling-window `qardlECM`; returns `rollingQardlECMOut` |
| `blockBootstrapQARDL(data, p, q, tau, B, blk_len, alpha)` | qardl.src | Moving-block bootstrap CIs for β, γ, φ; returns 3 `(dim x 2)` matrices |
| `wtestsym(qaOut, tau, data)` | wtestsym.src | Wald test H₀: θ(τ)=θ(1−τ) for all symmetric pairs in tau |
| `ardlbounds(data, p, q)` | ardlbounds.src | PSS (2001) bounds F-test; returns `(Fstat, cv)` |
| `ardlbounds_print(Fstat, cv, k)` | ardlbounds.src | Print formatted bounds test summary |

## GAUSS language conventions for this codebase

- **Variable naming**: three-letter lowercase (`ppp`, `qqq`, `tau`, `yyi`, `eei`, `xxi`) — original author's style, preserve it.
- **Loop style**: `do until jj > ss; ... jj = jj + 1; endo;` — not `for` loops, except where `for(start, end, step)` is used in newer code.
- **Locals must be declared**: all local variables listed at top of proc in a single `local` statement.
- **Struct declarations inside procs**: `struct qfitControl qCtl;` is declared inline, not in the `local` list — this is valid GAUSS syntax.
- **Matrix concatenation**: `~` for horizontal, `|` for vertical.
- **Element-wise ops**: `.>`, `.*`, `./` etc.
- **`packr(lagn(x, seqa(-q,1,q)))`**: idiom for building lagged-difference regressors. `seqa(-q,1,q)` = `[-q,...,-1]`; `lagn` with negative lag = lead, which after `packr` (drop NAs) produces the appropriately aligned columns. This is the original author's convention — do not change it.
- **Regressor matrix ONEX**: always `ones(N,1)~X` with `qCtl.const = 0` so `quantileFit` does not add a second constant.

### Newer GAUSS language features used in this library

**Structure inference** — procs that return a user-defined struct declare the type in the return slot so callers do not need to pre-declare the variable:
```gauss
// Proc declaration
proc (struct qardlOut) = qardl(data, ppp, qqq, tau = { 0.25, 0.5, 0.75 });

// Caller — pre-declaration is now optional
qaOut = qardl(data, pst, qst, tau);          // type inferred
struct qardlOut qaOut;                        // still valid (backwards compat)
qaOut = qardl(data, pst, qst, tau);
```
Inside the proc body, local struct variables are still declared with explicit `struct TypeName varName;`.

**Named arguments** — trailing proc arguments can carry default values; callers may pass them positionally, by name, or omit them entirely:
```gauss
proc (struct qardlOut) = qardl(data, ppp, qqq, tau = { 0.25, 0.5, 0.75 });

// All three call forms are equivalent and backwards-compatible:
qaOut = qardl(data, pst, qst);                         // use default tau
qaOut = qardl(data, pst, qst, tau);                    // positional
qaOut = qardl(data, pst, qst, tau = { 0.1, 0.5, 0.9 }); // named
```
Named args are only added to **trailing** parameters to preserve positional compatibility. Struct-typed parameters (e.g., `struct waldTestRestrictions wCtl`) cannot carry default values and must remain positional.

**Applied defaults in this library:**

| Proc | Named defaults |
|------|---------------|
| `qardl` | `tau = { 0.25, 0.5, 0.75 }` |
| `qardlECM` | `tau = { 0.25, 0.5, 0.75 }` |
| `qardlFull` | `tau = { 0.25, 0.5, 0.75 }`, `formula = ""`, `verbose = 1` |
| `rollingQardlECM` | `tau = { 0.25, 0.5, 0.75 }` |
| `plotQARDL` | `tau = { 0.25, 0.5, 0.75 }` |
| `plotQARDLbands` | `tau = { 0.25, 0.5, 0.75 }` |
| `plotRollingQARDLECM` | `tau = { 0.25, 0.5, 0.75 }`, `dates = 0` |
| `plotRollingQARDL` | `tau = { 0.25, 0.5, 0.75 }`, `dates = 0` |
| `printQARDL` | `tau = { 0.25, 0.5, 0.75 }` |
| `printQARDLECM` | `tau = { 0.25, 0.5, 0.75 }` |
| `saveQARDLResults` | `tau = { 0.25, 0.5, 0.75 }`, `outdir = "."` |
| `saveQARDLECMResults` | `tau = { 0.25, 0.5, 0.75 }`, `outdir = "."` |
| `blockBootstrapQARDL` | `tau = { 0.25, 0.5, 0.75 }`, `B = 999`, `blk_len = 0`, `alpha = 0.05` |
| `blockBootstrapQARDLECM` | `tau = { 0.25, 0.5, 0.75 }`, `B = 999`, `blk_len = 0`, `alpha = 0.05` |
| `pqorder` | `pend = 8`, `qend = 8` |
| `qirf` | `tau = { 0.25, 0.5, 0.75 }`, `k_x = 1`, `permanent = 1` |

**Formula string support** — implemented via two mechanisms:

1. **`applyQARDLFormula(data, formula)`** — public preprocessing helper. Call before any proc:
   ```gauss
   data = applyQARDLFormula(data, "consumption ~ income + wealth");
   qaOut = qardl(data, pst, qst);
   ```

2. **`qardlFull(..., formula = "")`** — formula integrated into the new pipeline proc:
   ```gauss
   qfOut = qardlFull(data, 8, 8, formula = "consumption ~ income + wealth");
   ```

The private `_applyFormula(data, formula)` helper at the bottom of `qardl.src` is the single implementation. It uses native GAUSS string functions (`strindx`, `strsect`, `strtrim`, `indcv`, `getcolnames`) — no external library dependency. Column names are matched case-insensitively.

**Why formula is NOT a named arg on individual procs**: GAUSS 26 requires all trailing named args to be supplied together positionally — once any optional arg is provided positionally, all subsequent optional args must also be provided. Adding `formula = ""` after `tau = {...}` would break existing calls like `qardl(data, p, q, tau)`. The preprocessing helper sidesteps this constraint entirely.

## `bt` coefficient vector layout

After `qardl()` estimation, `bt` is `(1 + qqq*k0 + k0 + ppp) x ss`:

| Row(s) | Contents |
|--------|---------|
| `1` | Intercept α(τ) |
| `2 : 1+qqq*k0` | γ coefficients — Δx_t, Δx_{t-1}, ..., Δx_{t-q+1} (qqq*k0 rows) |
| `2+qqq*k0 : 1+(qqq+1)*k0` | θ — contemporaneous x level (k0 rows); numerator of β |
| `2+(qqq+1)*k0 : 1+(qqq+1)*k0+ppp` | φ_1,...,φ_p — lagged y (ppp rows) |

Long-run β uses rows `2+qqq*k0 : 1+(qqq+1)*k0` divided by `(1 − sumc(φ rows))`.

## Covariance formula conventions

- **β covariance** (`bigbtmm`): `qq .*. inv(mm)` — Kronecker product, where `qq[i,j] = (min(τ_i,τ_j) − τ_i·τ_j)·b_i·b_j` and `mm` is the second-moment matrix of x after projecting out trend regressors.
- **φ/γ covariance** (`bigpi`, `bigff`): sandwich estimator using projected residual cross-products (`lll` matrix).
- **ρ covariance in `qardlECM`**: stationary-regressor sandwich: `cc[i,j] · D_inv[2,2] / N_ecm`, where `cc[i,j] = (min(τ_i,τ_j) − τ_i·τ_j) / (fh_i·fh_j)` and `D = ONEX_ecm'*ONEX_ecm/N_ecm`.
- **Density estimate `fh`**: Hendricks-Koenker kernel, bandwidth `hb[j] = (4.5·φ(Φ^{-1}(τ))^4 / (n·(2Φ^{-1}(τ)^2+1)^2))^{0.2}`.

## Inference

- **Individual parameter p-values**: use `qardl_pval(qaOut)` — returns `{ p_bigbt, p_phi, p_gamma }`, asymptotic standard normal (z-test). Do **not** use t-distribution; QR asymptotics are normal.
- **Joint / cross-quantile tests**: use `wtestlrb`, `wtestsrp`, `wtestsrg` — chi-squared Wald tests. The scaling differs: `wtestlrb` uses `(n-1)^2`, `wtestsrp`/`wtestsrg` use `(n-1)`.

## Sample sizes

- `qardl()`: uses `n − max(p,q)` observations.
- `qardlECM()`: uses `n − max(p,q) − 1` observations (one extra observation lost for first-differencing `y`).

## Package manifest

`package.json` lists all src files loaded by `library qardl`. Current version: **3.0.0**. All `.src` files in `src/` are registered, including `wtestconst.src` and `qirf.src`. If you add a new `.src` file, add it to the `"src"` array and bump the patch version.

## Source testing

Run the source-tree smoke test from GAUSS 26 before release work:

```gauss
test_dir = "path/to/gauss-qardl/tests";
chdir ^test_dir;
run smoke_public_api.e;
run smoke_workflow_api.e;
```

The test includes local `src/` files directly rather than relying on `library qardl`, so it catches source regressions even when the installed package catalog is stale. After rebuilding/installing a package, separately verify that `library qardl;` exposes the same public procedures.

```gauss
run package_public_api.e;
```

## Reference

- Cho, J.S., Kim, T-H., Shin, Y. (2015). "Quantile cointegration in the autoregressive distributed-lag modeling framework." *Journal of Econometrics*, 188(1), 281–300.
- Aptech GAUSS coding conventions: https://github.com/aptech/gauss-llm-reference
- Original author's page: https://web.yonsei.ac.kr/jinseocho/qardl.htm
