# qardlFull

## Purpose

Runs the standard applied QARDL workflow: lag-order selection, ARDL bounds
testing, levels-form QARDL estimation, and QARDL-ECM estimation.

## Format

```gauss
qfOut = qardlFull(data);
qfOut = qardlFull(data, pend, qend);
qfOut = qardlFull(data, pend, qend, tau, formula, verbose, criterion,
                  cov_type, hac_lags, ecm_type, gets_pval);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Dependent variable in column 1 and
  regressors in the remaining columns. If `formula` is supplied, `data` may be
  a named dataframe.
- `pend` (*scalar*) - Maximum autoregressive lag order to search. Default is
  `8`.
- `qend` (*scalar*) - Maximum distributed-lag order to search. Default is `8`.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`. Default is
  `""`.
- `verbose` (*scalar*) - If `1`, prints workflow output. If `0`, returns
  results silently. Default is `1`.
- `criterion` (*string*) - Lag-selection criterion: `"bic"`, `"aic"`, `"hq"`,
  `"hqc"`, or `"gets"`. Default is `"bic"`.
- `cov_type` (*string*) - Covariance estimator: `"iid"`, `"robust"`, or
  `"hac"`. Default is `"iid"`.
- `hac_lags` (*scalar*) - HAC truncation lag. Use `0` for the automatic
  Newey-West bandwidth. Default is `0`.
- `ecm_type` (*string*) - `"two-step"` (default) or `"uecm"` for the ECM
  stored in `qfOut.ecm`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.

## Returns

`qfOut` is a `qardlFullOut` structure with fields:

- `pst`, `qst` - Selected lag orders.
- `tau` - Quantiles used in estimation.
- `nobs` - Number of input observations.
- `ardl_fstat`, `ardl_cv` - ARDL bounds-test statistic and critical values.
- `qa` - A `qardlOut` structure from `qardl`.
- `ecm` - A `qardlECMOut` structure from `qardlECM`.
- `levels_diag` - `ardlResidualDiagOut` diagnostics for `qfOut.qa`.
- `ecm_diag` - `ardlResidualDiagOut` diagnostics for `qfOut.ecm`.

## Remarks

`qardlFull` is the recommended starting point for applied work. It preserves
the lower-level APIs for users who need fixed lag orders or custom workflows.
Omitting `pend` and `qend` searches the default `p = 1,...,8` and
`q = 0,...,8` grid.
With `criterion = "gets"`, lag selection starts from `pend`/`qend` and
removes highest-order lag blocks by Wald p-value while preserving contiguous
scalar `p/q` orders.
Residual diagnostics are computed automatically for both selected estimators
and stored in `qfOut.levels_diag` and `qfOut.ecm_diag`.

## Examples

```gauss
library qardl;

data = loadd("macro.csv");
tau = { 0.10, 0.25, 0.50, 0.75, 0.90 };

qfOut = qardlFull(data, tau = tau, verbose = 0, criterion = "bic",
                  cov_type = "hac", hac_lags = 0);
qfGets = qardlFull(data, tau = tau, verbose = 0, criterion = "gets",
                   gets_pval = 0.1);
printQARDL(qfOut.qa, tau);
printQARDLECM(qfOut.ecm, tau);
printARDLResidualDiagnostics(qfOut.levels_diag);
printARDLResidualDiagnostics(qfOut.ecm_diag);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [qardlECM](qardlECM.md),
[ardlResidualDiagnostics](ardlResidualDiagnostics.md), [pqSelect](pqSelect.md),
[ardlboundsCase](ardlboundsCase.md)
