# ARDL-Family Output Schema

This page records the baseline output metadata shared by the public
ARDL-family estimators. The goal is to make downstream diagnostics, validation
fixtures, reporting, and unified prediction/forecast dispatch depend on stable
fields instead of procedure-specific assumptions.

## Common Metadata Fields

The main ARDL, QARDL, NARDL, and CS-ARDL output structures include these fields
where applicable:

- `model_family`: model family label, such as `"ARDL"`, `"QARDL"`,
  `"NARDL"`, or `"CS-ARDL"`.
- `formula`: formula string used for dataframe input. Matrix-only calls store
  `""`.
- `depvar`: dependent-variable name. Matrix-only calls use `"y"`.
- `xvars`: string array of regressor names. Matrix-only calls use `"x1"`,
  `"x2"`, and so on.
- `deterministic`: deterministic component currently used by the estimator.
  Current estimators store `"constant"`.
- `covariance_type`: covariance estimator label, such as `"ols"`, `"iid"`,
  `"robust"`, or `"hac"`.
- `ecm_type`: ECM estimator label where applicable. ECM outputs store
  `"two-step"` for the restricted two-stage ECM or `"uecm"` for the
  unrestricted ECM. Some legacy levels outputs also store `"none"`.
- `selection_criterion`: lag-selection criterion used by full workflows.
  Direct fixed-lag estimators store `"none"`.
- `sample_start`, `sample_end`: input row-index range used by the call.
- `estimation_start`, `estimation_end`: effective estimation range after lag
  alignment. For CS-ARDL outputs, these are within-unit time indices.
- `design_rank`, `design_cols`, `design_condition`: numerical diagnostics for
  the estimation design matrix where a model is estimated from an explicit
  design.

Lag metadata is stored in the existing scalar fields `p` and `q`, plus `qvec`
where a per-regressor distributed-lag vector is available. Explicit
decomposition NARDL outputs also store `q_control`, `control_qvec`, and
`decomp_thresholds` for partial-sum reset thresholds. Full workflows also store
`pmax` and `qmax` for the search bounds.

## Model Output Map

| Structure | Family | Key metadata additions | Notes |
| --- | --- | --- | --- |
| `ardlSelectOut` | ARDL-family selector | `model_family`, `selection_criterion`, `q_mode`, `return_type`, `pmax`, `qmax`, `pst`, `qst`, `qvec`, optional `grid` | Returned by `ardlSelect`; standardizes lag-selection metadata across ARDL, QARDL, NARDL, and CS-ARDL selectors. |
| `ardlOut` | ARDL | common metadata, `qvec`, row-index sample metadata | Levels-form OLS output. Use `ardlECM` for ARDL error-correction estimates. |
| `ardlECMOut` | ARDL-ECM | common metadata, `ecm_type`, `qvec`, row-index sample metadata, `beta_lr`, `rho_ols` | Dedicated ARDL ECM output; supports `"two-step"` and `"uecm"`. |
| `ardlFullOut` | ARDL | common workflow metadata, `pmax`, `qmax` | Bundles selected ARDL output in `.ar`. |
| `ardlAutoCaseOut` | ARDL-AutoCase | common workflow metadata, `pmax`, `qmax`, `gets_mode`, `case_ids`, `primary_case`, `bounds_table`, optional `sparse_*` fields | Bundles GETS-selected ARDL levels output in `.ar` and primary-case UECM output in `.ecm`; sparse mode stores the pruned Case V UECM fit separately. |
| `qardlOut` | QARDL | common metadata, `qvec`, `fitted`, `resid` | `fitted` and `resid` are `nobs x rows(tau)`. |
| `qardlECMOut` | QARDL-ECM | common metadata, `ecm_type`, `qvec`, `bt`, `fitted`, `resid` | Supports `"two-step"` and `"uecm"`; full covariance is currently exposed through `alpha_cov` and `rho_cov`. |
| `qardlFullOut` | QARDL | common workflow metadata, `pmax`, `qmax` | Propagates formula/name metadata to `.qa` and `.ecm`. |
| `nardlOut` | NARDL | common metadata, `qvec`, row-index sample metadata, `decomp_vars`, `control_vars`, `decomp_thresholds`, `symmetry_restriction` | Includes positive/negative long-run decomposition fields, optional linear-control long-run fields, and optional SRSR/LRSR constraints. |
| `nardlECMOut` | NARDL-ECM | common metadata, `ecm_type`, `qvec`, row-index sample metadata, `decomp_vars`, `control_vars`, `decomp_thresholds`, `symmetry_restriction` | Includes inherited asymmetric long-run tests, optional linear-control coefficients, and optional SRSR/LRSR constraints. |
| `nardlFullOut` | NARDL | common workflow metadata, `pmax`, `qmax`, `decomp_thresholds` | Propagates formula/name metadata to `.na` and `.ecm`. |
| `nardlAutoCaseOut` | NARDL-AutoCase | common workflow metadata, `pmax`, `qmax`, `gets_mode`, `case_ids`, `primary_case`, `bounds_table`, `decomp_thresholds`, optional `sparse_*` fields | Bundles GETS-selected NARDL levels output in `.na` and primary-case UECM output in `.ecm`; sparse mode stores the pruned Case V NARDL UECM fit separately. |
| `nardlDynMultOut` | NARDL-Dynamic-Multipliers | model family, formula, names, horizon | Contains `pos`, `neg`, and `asymmetry` multiplier matrices. |
| `csardlOut` | CS-ARDL | common metadata, `unitvar`, `timevar`, `qvec` | `estimation_start/end` are within-unit time indices. |
| `csardlECMOut` | CS-ARDL-ECM | common metadata, `ecm_type`, `unitvar`, `timevar`, `qvec` | Uses pooled long-run coefficients from CS-ARDL levels estimation for `"two-step"` and derives long-run coefficients directly for `"uecm"`. |
| `csardlDiagOut` | CS-ARDL diagnostics | common metadata, `unitvar`, `timevar`, `qvec`, `cd_stat`, `py_delta`, `py_lr_delta`, `slope_hetero_wald` | Covers mean-group, poolability, long-run slope heterogeneity, Pesaran-Yamagata slope homogeneity, and Pesaran CD residual cross-sectional dependence diagnostics. |
| `csardlFullOut` | CS-ARDL | common workflow metadata, `unitvar`, `timevar`, `pmax`, `qmax` | Propagates formula/name metadata to `.csa` and `.ecm`. |
| `ardlResidualDiagOut` | ARDL-family residual diagnostics | `source_model_family`, `nobs`, `nseries`, `lags`, `stability_available`, Ljung-Box/BG/ARCH/RESET fields | Covers Ljung-Box, BG LM, Breusch-Pagan-style, ARCH LM, Jarque-Bera, RESET, and residual CUSUM/CUSUMSQ diagnostics for time-series outputs. |
| `rollingQardlECMOut` | Rolling QARDL-ECM | `ecm_type`, rolling alpha/rho paths, `beta_lr` | `beta_lr` is `num_est x k` for `"two-step"` and `num_est x (k*rows(tau))` for `"uecm"`. |

## ECM Estimator Metadata

The ECM-capable APIs use `ecm_type = "two-step"` by default. This preserves
the historical GAUSS two-stage workflow, where the long-run relation is
estimated first and then enters the differenced ECM equation as a constructed
error-correction term.

Set `ecm_type = "uecm"` to estimate the unrestricted ECM equation with lagged
dependent and lagged level regressors directly in the ECM design. Long-run
coefficients are derived as `-theta / rho` from the unrestricted lagged-level
terms. `ardlECM`, `qardlECM`, `nardlECM`, `csardlECM`, and the matching ECM
workflows store the ECM estimates in dedicated ECM structures.

Auto-case outputs use `case_ids` for the admissible Pesaran-Shin-Smith case
set inferred from Case V UECM constant/trend p-values. When the admissible set
has two entries, `primary_case` stores the unrestricted member used for the
nested UECM estimator. `bounds_table` rows are `[case_id, Fstat, tstat,
q_restrict, cv10_I0, cv10_I1, cv5_I0, cv5_I1, cv1_I0, cv1_I1]`.

## NARDL Decomposition Metadata

`nardl` remains the compatibility path where every RHS regressor is
decomposed. In that case `ndecomp == k`, `ncontrol == 0`, and `decomp_vars`
matches `xvars`.

`nardl`, `nardlECM`, and `nardlFull` support mixed models through optional
decomposed-variable and control arguments. Their nested NARDL outputs store:

- `decomp_vars`, `decomp_indices`, `ndecomp`: variables split into positive and
  negative partial sums.
- `control_vars`, `control_indices`, `ncontrol`: variables kept in linear form.
- `q`: distributed-lag order for decomposed variables.
- `q_control`: distributed-lag order for controls.
- `decomp_thresholds`: numeric reset threshold for each decomposed variable.
  Values larger than `1e200` indicate the default ordinary cumulative-sum
  case (`d = "inf"`).
- `beta_pos`, `beta_neg`: long-run coefficients for decomposed variables.
- `beta_control`: long-run coefficients for controls.
- `bigbt`: stacked as `[beta_pos; beta_neg; beta_control]`.

## Long-Run Extraction

The `ardlLongRun(modelOut)` helper returns the stored long-run coefficient
surface and matching covariance matrix for `ardlOut`, `qardlOut`, `nardlOut`,
`csardlOut`, and the matching full-workflow output structures. It is intended
for reporting, validation fixtures, and downstream tools that should not need
to know each structure's nested field names.

`ardlLongRun` does not recompute long-run estimates, and it is intentionally
scoped to levels and full-workflow outputs until ECM long-run covariance fields
are standardized across all model families.

## Formula And Matrix Parity

Formula workflows should produce the same numerical estimates as equivalent
matrix/dataframe calls after column selection and reordering. Source tests cover
this parity for ARDL, QARDL, NARDL, and CS-ARDL.

For matrix calls, variable-name metadata uses default names:

```gauss
depvar = "y";
xvars = "x1" $| "x2";
```

For formula calls, the output records names from the formula:

```gauss
arOut = ardl(df, 1, 1, "income ~ rates + inflation", 0);
print arOut.depvar;  // "income"
print arOut.xvars;   // "rates", "inflation"
```

## CS-ARDL Panel Metadata

For formula CS-ARDL calls, `unitvar` and `timevar` record the resolved panel
variables. They are either supplied through `group_var` and `time_var` or
inferred from dataframe metadata:

- `unitvar`: first string or category variable
- `timevar`: first date variable, falling back to the first numeric variable

Matrix CS-ARDL calls store default names:

```gauss
unitvar = "unit_id";
timevar = "time_index";
```

CS-ARDL formula calls sort by the resolved unit/time variables before
estimation. The returned `estimation_start` and `estimation_end` fields are
within-unit time indices, not total row indices.

CS-ARDL matrix input must already be a balanced panel stacked by unit. Formula
input is sorted before estimation, but it must identify a balanced panel after
sorting. Unbalanced panels and missing panel cells are unsupported in the
current implementation.

## Current Limitations

- Deterministic terms are currently recorded as `"constant"` because the public
  estimators use intercept specifications.
- Full covariance matrices for all QARDL-ECM coefficients are not yet exposed;
  QARDL-ECM currently exposes `alpha_cov` and `rho_cov`.
- Missing-data row dropping is intentionally unsupported. Clean and align data
  before estimation; see `docs/guides/DATA_HANDLING.md`.
- Additional control structures may still be needed for long positional APIs;
  this schema baseline does not change existing public signatures.
- CS-ARDL panel residual diagnostics are not part of `ardlResidualDiagOut`;
  unit-aware panel residual tests remain a panel-diagnostics milestone.
- `csardlDiagOut.slope_hetero_*` fields store a mean-group-centered
  Wald-style long-run slope heterogeneity diagnostic.
- `csardlDiagOut.py_*` fields store Pesaran-Yamagata Delta diagnostics for
  direct CS-ARDL dynamic slopes, excluding intercept and cross-sectional
  average controls.
- `csardlDiagOut.py_lr_*` fields store the corresponding long-run
  Pesaran-Yamagata Delta diagnostics for CS-ARDL long-run coefficients.
- `csardlDiagOut.cd_*` fields store Pesaran CD diagnostics and residual-pair
  metadata. The default all-pairs CD uses `cd_order = -1`; fixed-order
  `CD(p)` uses a positive `cd_order`.
- `ardlResidualDiagOut` stability fields are residual-bridge CUSUM/CUSUMSQ
  checks. Full recursive-residual stability tests require design-matrix
  metadata that is not yet standardized across all outputs.
