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
- `selection_criterion`: lag-selection criterion used by full workflows.
  Direct fixed-lag estimators store `"none"`.
- `sample_start`, `sample_end`: input row-index range used by the call.
- `estimation_start`, `estimation_end`: effective estimation range after lag
  alignment. For CS-ARDL outputs, these are within-unit time indices.

Lag metadata is stored in the existing scalar fields `p` and `q`, plus `qvec`
where a per-regressor distributed-lag vector is available. Full workflows also
store `pmax` and `qmax` for the search bounds.

## Model Output Map

| Structure | Family | Key metadata additions | Notes |
| --- | --- | --- | --- |
| `ardlOut` | ARDL | common metadata, `qvec`, row-index sample metadata | Levels-form OLS output. |
| `ardlFullOut` | ARDL | common workflow metadata, `pmax`, `qmax` | Bundles selected ARDL output in `.ar`. |
| `qardlOut` | QARDL | common metadata, `qvec`, `fitted`, `resid` | `fitted` and `resid` are `nobs x rows(tau)`. |
| `qardlECMOut` | QARDL-ECM | common metadata, `qvec`, `bt`, `fitted`, `resid` | Full covariance is currently exposed through `alpha_cov` and `rho_cov`. |
| `qardlFullOut` | QARDL | common workflow metadata, `pmax`, `qmax` | Propagates formula/name metadata to `.qa` and `.ecm`. |
| `nardlOut` | NARDL | common metadata, `qvec`, row-index sample metadata | Includes positive/negative long-run decomposition fields. |
| `nardlECMOut` | NARDL-ECM | common metadata, `qvec`, row-index sample metadata | Includes inherited asymmetric long-run tests. |
| `nardlFullOut` | NARDL | common workflow metadata, `pmax`, `qmax` | Propagates formula/name metadata to `.na` and `.ecm`. |
| `nardlDynMultOut` | NARDL-Dynamic-Multipliers | model family, formula, names, horizon | Contains `pos`, `neg`, and `asymmetry` multiplier matrices. |
| `csardlOut` | CS-ARDL | common metadata, `unitvar`, `timevar`, `qvec` | `estimation_start/end` are within-unit time indices. |
| `csardlECMOut` | CS-ARDL-ECM | common metadata, `unitvar`, `timevar`, `qvec` | Uses pooled long-run coefficients from CS-ARDL levels estimation. |
| `csardlDiagOut` | CS-ARDL diagnostics | common metadata, `unitvar`, `timevar`, `qvec` | Covers mean-group and poolability diagnostics. |
| `csardlFullOut` | CS-ARDL | common workflow metadata, `unitvar`, `timevar`, `pmax`, `qmax` | Propagates formula/name metadata to `.csa` and `.ecm`. |

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

For formula CS-ARDL calls, `unitvar` and `timevar` record the inferred panel
variables:

- `unitvar`: first string or category variable
- `timevar`: first date variable, falling back to the first numeric variable

Matrix CS-ARDL calls store default names:

```gauss
unitvar = "unit_id";
timevar = "time_index";
```

CS-ARDL formula calls sort by the inferred unit/time variables before
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
- Missing-data row dropping remains unsupported for CS-ARDL and needs a
  broader package-level policy for other model families.
- Additional control structures may still be needed for long positional APIs;
  this schema baseline does not change existing public signatures.
