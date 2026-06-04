# ardlFull

## Purpose

Runs the standard ARDL workflow: lag selection, ARDL bounds testing, and
levels-form ARDL estimation.

## Format

```gauss
afOut = ardlFull(data);
afOut = ardlFull(data, pend, qend);
afOut = ardlFull(data, pend, qend, formula, verbose, criterion);
afOut = ardlFull(data, pend, qend, formula, verbose, "gets", gets_pval);
afOut = ardlFull(data, pend, qend, formula, verbose, criterion, gets_pval,
                 case_id, print_diagnostics);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`.
- `pend` (*scalar*) - Maximum AR lag order searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `formula` (*string*) - Optional formula string. Default is `""`.
- `verbose` (*scalar*) - If `1`, print lag selection, bounds-test, and
  estimator output. Default is `1`.
- `criterion` (*string*) - Lag-selection criterion: `"bic"`, `"aic"`,
  `"hq"`, `"hqc"`, or `"gets"`. Default is `"bic"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.
- `case_id` (*scalar*) - Pesaran-Shin-Smith deterministic case used for the
  bounds test. Default is `3`.
- `print_diagnostics` (*scalar*) - If `1`, print residual diagnostics after
  the selected model output. If `0`, store diagnostics without printing. If
  `-1`, follow `verbose`. Default is `-1`.

## Returns

`afOut` is an `ardlFullOut` structure containing:

- `pst`, `qst` - Selected lag orders.
- `nobs` - Input sample size.
- `ardl_fstat`, `ardl_cv` - ARDL bounds-test statistic and critical values.
- `ar` - `ardlOut` structure returned by `ardl`.
- `levels_diag` - `ardlResidualDiagOut` diagnostics for `afOut.ar`.

## Remarks

`ardlFull` is the OLS ARDL companion to `qardlFull`. It is additive and does
not change QARDL behavior. Omitting `pend` and `qend` searches the default
`p = 1,...,8` and `q = 0,...,8` grid.
When `criterion = "gets"`, `ardlFull` starts from the requested maximum lags
and reduces the highest-order lag blocks by Wald p-value while preserving a
contiguous lag structure.
`case_id` is passed to `ardlboundsCase` for the bounds-test step. Levels-form
`ardl` estimation remains the package's standard constant-only levels model.
Residual diagnostics are computed automatically for the selected levels model
and stored in `afOut.levels_diag`. By default they print when `verbose = 1`;
set `print_diagnostics = 0` to suppress diagnostic printing while still
storing the object.

Use `ardlECM` with selected `pst` and `qst` when you want the matching ARDL
error-correction model after running the full lag-selection and bounds-test
workflow.

## Examples

```gauss
library qardl;

df = loadd("shiller_stocks_qt.csv",
           "date($date) + real_price + real_dividend + real_earnings");

afOut = ardlFull(df, formula = "real_dividend ~ real_earnings",
                 verbose = 0, criterion = "bic");
afGets = ardlFull(df, formula = "real_dividend ~ real_earnings",
                  verbose = 0, criterion = "gets", gets_pval = 0.1);
afCaseIV = ardlFull(df, 4, 4, "real_dividend ~ real_earnings", 0,
                    "bic", 0.1, 4);
afDiagOnly = ardlFull(df, 4, 4, "real_dividend ~ real_earnings", 0,
                      "bic", 0.1, 3, 1);
printARDL(afOut.ar);
printARDLResidualDiagnostics(afOut.levels_diag);
```

## Source

`qardl.src`

## See Also

[ardl](ardl.md), [ardlECM](ardlECM.md), [ardlAutoCase](ardlAutoCase.md),
[ardlbounds](ardlbounds.md), [ardlResidualDiagnostics](ardlResidualDiagnostics.md),
[pqSelect](pqSelect.md), [qardlFull](qardlFull.md)
