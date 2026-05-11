# ardlFull

## Purpose

Runs the standard ARDL workflow: lag selection, ARDL bounds testing, and
levels-form ARDL estimation.

## Format

```gauss
afOut = ardlFull(data);
afOut = ardlFull(data, pend, qend);
afOut = ardlFull(data, pend, qend, formula, verbose, criterion);
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
  `"hq"`, or `"hqc"`. Default is `"bic"`.

## Returns

`afOut` is an `ardlFullOut` structure containing:

- `pst`, `qst` - Selected lag orders.
- `nobs` - Input sample size.
- `ardl_fstat`, `ardl_cv` - ARDL bounds-test statistic and critical values.
- `ar` - `ardlOut` structure returned by `ardl`.

## Remarks

`ardlFull` is the OLS ARDL companion to `qardlFull`. It is additive and does
not change QARDL behavior. Omitting `pend` and `qend` searches the default
`p = 1,...,8` and `q = 0,...,8` grid.

## Examples

```gauss
library qardl;

df = loadd("shiller_stocks_qt.csv",
           "date($date) + real_price + real_dividend + real_earnings");

afOut = ardlFull(df, formula = "real_dividend ~ real_earnings",
                 verbose = 0, criterion = "bic");
printARDL(afOut.ar);
```

## Source

`qardl.src`

## See Also

[ardl](ardl.md), [ardlbounds](ardlbounds.md), [pqorder](pqorder.md),
[qardlFull](qardlFull.md)
