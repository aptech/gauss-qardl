# CLAUDE.md — GAUSS QARDL Library

Context file for Claude Code sessions working on this repository.

## What this library does

Implements the **Quantile Autoregressive Distributed Lag (QARDL)** model from Cho, Kim & Shin (2015), which extends ARDL cointegration to allow long-run and short-run parameters to vary across quantiles of the conditional distribution of `y_t`. Use cases: testing for asymmetric cointegration, studying heterogeneous adjustment speeds.

The library is a **GAUSS application package** (version 1.0.1). It loads via `library qardl;` and depends only on GAUSS's built-in `quantileFit` (no external library required).

## Repository layout

```
src/
  qardl.sdf          # Structure definitions (qardlOut, qardlECMOut, rollingQardlOut, etc.)
  qardl.src          # Core procedures: qardl(), qardlECM(), rollingQardl(), plotQARDL(), helpers
  icmean.src         # BIC-based lag order selection: icmean(), pqorder()
  p_values_qardl.src # qardl_pval() — asymptotic z-test p-values for all three parameter sets
  wtestlrb.src       # wtestlrb() — Wald test for long-run beta
  wtestsrp.src       # wtestsrp() — Wald test for short-run phi
  wtestsrg.src       # wtestsrg() — Wald test for short-run gamma
examples/
  demo.e             # Main worked example
  qardlestimation.e  # Monte Carlo simulation of QARDL estimation
  qardl_est_tests.e  # Estimation with Wald tests
  wald_tests_sim.e   # Wald test size simulation
  rolling_qardl.e    # Rolling QARDL example
  sp500.e            # S&P 500 application
package.json         # GAUSS package manifest (name: qardl, version: 1.0.1)
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
| `bigbt` | `(k·s) x 1` | Long-run β, stacked: all k vars at τ_1, then τ_2, ... |
| `bigbt_cov` | `(k·s) x (k·s)` | Asymptotic covariance of bigbt |
| `phi` | `(p·s) x 1` | Short-run φ lags, stacked by quantile |
| `phi_cov` | `(p·s) x (p·s)` | Asymptotic covariance of phi |
| `gamma` | `(k·s) x 1` | Short-run γ (x differences), stacked by quantile |
| `gamma_cov` | `(k·s) x (k·s)` | Asymptotic covariance of gamma |
| `alpha` | `s x 1` | Intercept α(τ) at each quantile |
| `rho` | `s x 1` | ECM adjustment speed ρ(τ) at each quantile |

## `qardlECMOut` structure fields

| Field | Dimensions | Description |
|-------|-----------|-------------|
| `beta_lr` | `k x 1` | OLS long-run coefficients (used for EC term) |
| `rho_ols` | `1 x 1` | OLS speed of adjustment |
| `alpha` | `s x 1` | ECM intercept at each quantile |
| `rho` | `s x 1` | Directly estimated speed of adjustment at each quantile |
| `rho_cov` | `s x s` | Asymptotic covariance of ρ across quantiles |

## GAUSS language conventions for this codebase

- **Variable naming**: three-letter lowercase (`ppp`, `qqq`, `tau`, `yyi`, `eei`, `xxi`) — original author's style, preserve it.
- **Loop style**: `do until jj > ss; ... jj = jj + 1; endo;` — not `for` loops, except where `for(start, end, step)` is used in newer code.
- **Locals must be declared**: all local variables listed at top of proc in a single `local` statement.
- **Struct declarations inside procs**: `struct qfitControl qCtl;` is declared inline, not in the `local` list — this is valid GAUSS syntax.
- **Matrix concatenation**: `~` for horizontal, `|` for vertical.
- **Element-wise ops**: `.>`, `.*`, `./` etc.
- **`packr(lagn(x, seqa(-q,1,q)))`**: idiom for building lagged-difference regressors. `seqa(-q,1,q)` = `[-q,...,-1]`; `lagn` with negative lag = lead, which after `packr` (drop NAs) produces the appropriately aligned columns. This is the original author's convention — do not change it.
- **Regressor matrix ONEX**: always `ones(N,1)~X` with `qCtl.const = 0` so `quantileFit` does not add a second constant.

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

`package.json` lists all src files loaded by `library qardl`. Current version: **1.0.2**. All `.src` files in `src/` including `p_values_qardl.src` are registered. If you add a new `.src` file, add it to the `"src"` array and bump the patch version.

## Reference

- Cho, J.S., Kim, T-H., Shin, Y. (2015). "Quantile cointegration in the autoregressive distributed-lag modeling framework." *Journal of Econometrics*, 188(1), 281–300.
- Aptech GAUSS coding conventions: https://github.com/aptech/gauss-llm-reference
- Original author's page: https://web.yonsei.ac.kr/jinseocho/qardl.htm
