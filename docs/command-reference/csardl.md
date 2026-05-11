# csardl

## Purpose

Estimates pooled cross-sectional ARDL models with cross-sectional-average
controls. The source includes `csardl`, `csardlECM`, `csardlFull`,
`csardlOrder`, `csardlOrderGrid`, `csardlICMean`, `printCSARDL`,
`printCSARDLECM`, `csardlDiagnostics`, `printCSARDLDiagnostics`,
`predictCSARDL`, `forecastCSARDL`, and `applyCSARDLFormula`.

## Format

```gauss
csaOut = csardl(data, ppp, qqq);
cfOut = csardlFull(data, pend, qend, cs_lags, formula);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula);
```

## Remarks

Matrix input is a balanced panel stacked by unit in `[unit_id, y, x1, ...]`
order.

For dataframe input, the preferred formula is `"y ~ x1 + x2"`. CS-ARDL
infers the panel unit variable as the first string/category column and the
time variable as the first date column, falling back to the first numeric
column if no date column exists. The dataframe is sorted by the inferred unit
and time variables before the estimator matrix is built.

If numeric time fallback is used, put the time column before `y` and the
regressors so the GAUSS panel-data convention does not infer a model variable
as the time index.

The levels estimator reports pooled long-run coefficients and delta-method
long-run covariance. The ECM estimator uses the levels long-run coefficients
to build a pooled error-correction term and includes cross-sectional-average
changes.

`csardlDiagnostics` estimates the same cross-sectionally augmented equation
unit-by-unit, reports mean-group long-run coefficients, and computes a
Wald-style poolability diagnostic against the pooled long-run coefficients.

Published-result validation cases are still TODO. The current benchmark
coverage uses deterministic synthetic datasets until exact published datasets
and specifications are available.

## Source

`csardl.src`

## See Also

[qardl](qardl.md), [nardl](nardl.md)
