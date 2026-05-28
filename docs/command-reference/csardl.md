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
csaOut = csardl(data, ppp, qqq, cs_lags, formula, print_results,
                group_var, time_var);
cfOut = csardlFull(data);
cfOut = csardlFull(data, pend, qend, cs_lags, formula, verbose, criterion,
                   group_var, time_var);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula, print_results,
                            group_var, time_var);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula, print_results,
                            group_var, time_var, cd_order);
```

## Remarks

Matrix input is a balanced panel stacked by unit in `[unit_id, y, x1, ...]`
order. The time index is implicit within each equal-length unit block.
Unbalanced panels are not supported in the current implementation.

For dataframe input, the preferred formula is `"y ~ x1 + x2"`. CS-ARDL
infers the panel unit variable as the first string/category column and the
time variable as the first date column, falling back to the first numeric
column if no date column exists. The dataframe is sorted by the inferred unit
and time variables before the estimator matrix is built.

To override inference, pass the panel identifier names through the optional
`group_var` and `time_var` string inputs. Their defaults are empty strings
(`""`), which preserves GAUSS-style inference:

```gauss
cfOut = csardlFull(df_panel, cs_lags = 1, formula = "y ~ x1 + x2",
                   verbose = 0, criterion = "bic",
                   group_var = "country", time_var = "year");
```

If numeric time fallback is used, put the time column before `y` and the
regressors so the GAUSS panel-data convention does not infer a model variable
as the time index.

Formula strings do not include explicit unit/time terms. To select panel
identifiers, either pass `group_var` and `time_var`, or arrange and type the
dataframe so the desired unit column is the first string/category variable and
the desired time column is the first date variable, or first numeric variable
if no date column exists.

Missing values are not dropped automatically. Clean and align the panel before
estimation.

The levels estimator reports pooled long-run coefficients and delta-method
long-run covariance. The ECM estimator uses the levels long-run coefficients
to build a pooled error-correction term and includes cross-sectional-average
changes.

`csardlFull`, `csardlOrder`, and `csardlOrderGrid` support
information-criterion lag selection. If `pend` and `qend` are omitted, the
default maximum search bounds are `8` and `8`; `cs_lags` defaults to `0`.

`csardlDiagnostics` estimates the same cross-sectionally augmented equation
unit-by-unit, reports mean-group long-run coefficients, and computes a
Wald-style poolability diagnostic against the pooled long-run coefficients
plus Pesaran-Yamagata slope homogeneity and Pesaran CD residual
cross-sectional dependence diagnostics. The default CD calculation uses all
unit pairs; pass a positive `cd_order` for fixed-order `CD(p)`.

The current benchmark coverage uses deterministic synthetic datasets,
including balanced-panel cross-sectional-average, lag-alignment, sorting, and
diagnostic fixtures. Additional exact published dynamic CCE/CS-ARDL
replication cases remain a validation target. See `docs/validation/CSARDL_VALIDATION.md`.

## Source

`csardl.src`

## See Also

[qardl](qardl.md), [nardl](nardl.md)
