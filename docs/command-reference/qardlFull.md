# qardlFull

## Purpose

Runs the standard applied QARDL workflow: lag-order selection, ARDL bounds
testing, levels-form QARDL estimation, and two-step QARDL-ECM estimation.

## Format

```gauss
qfOut = qardlFull(data, pend, qend);
qfOut = qardlFull(data, pend, qend, tau, formula, verbose, criterion,
                  cov_type, hac_lags);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Dependent variable in column 1 and
  regressors in the remaining columns. If `formula` is supplied, `data` may be
  a named dataframe.
- `pend` (*scalar*) - Maximum autoregressive lag order to search.
- `qend` (*scalar*) - Maximum distributed-lag order to search.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`. Default is
  `""`.
- `verbose` (*scalar*) - If `1`, prints workflow output. If `0`, returns
  results silently. Default is `1`.
- `criterion` (*string*) - Lag-selection criterion: `"bic"`, `"aic"`, `"hq"`,
  or `"hqc"`. Default is `"bic"`.
- `cov_type` (*string*) - Covariance estimator: `"iid"`, `"robust"`, or
  `"hac"`. Default is `"iid"`.
- `hac_lags` (*scalar*) - HAC truncation lag. Use `0` for the automatic
  Newey-West bandwidth. Default is `0`.

## Returns

`qfOut` is a `qardlFullOut` structure with fields:

- `pst`, `qst` - Selected lag orders.
- `tau` - Quantiles used in estimation.
- `nobs` - Number of input observations.
- `ardl_fstat`, `ardl_cv` - ARDL bounds-test statistic and critical values.
- `qa` - A `qardlOut` structure from `qardl`.
- `ecm` - A `qardlECMOut` structure from `qardlECM`.

## Remarks

`qardlFull` is the recommended starting point for applied work. It preserves
the lower-level APIs for users who need fixed lag orders or custom workflows.

## Examples

```gauss
library qardl;

data = loadd("macro.csv");
tau = { 0.10, 0.25, 0.50, 0.75, 0.90 };

qfOut = qardlFull(data, 8, 8, tau, "", 0, "bic", "hac", 0);
printQARDL(qfOut.qa, tau);
printQARDLECM(qfOut.ecm, tau);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [qardlECM](qardlECM.md), [pqorder](pqorder.md),
[ardlboundsCase](ardlboundsCase.md)
