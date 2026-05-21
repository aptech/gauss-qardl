# Migration Guide

This guide is for users moving from the earlier QARDL-focused package to the
expanded ARDL-family library.

## Package Loading

Examples should load the installed package:

```gauss
library qardl;
```

Do not include source files from `src/` in user-facing examples. Source includes
are reserved for source-tree development tests.

## Model Families

The package now includes four public model families:

| Family | Primary workflow | Notes |
| --- | --- | --- |
| ARDL | `ardl`, `ardlFull` | OLS levels-form ARDL and bounds workflow. |
| QARDL | `qardl`, `qardlFull` | Original quantile ARDL workflows remain available. |
| NARDL | `nardl`, `nardlFull` | Positive and negative partial-sum decomposition. |
| CS-ARDL | `csardl`, `csardlFull` | Balanced-panel cross-sectionally augmented ARDL. |

Existing QARDL calls are preserved wherever possible. New ARDL, NARDL, and
CS-ARDL workflows follow the same naming and output conventions where the
model definitions allow it.

## Prediction And Forecasting

Use the unified functions for new code:

```gauss
yhat = predictARDL(modelOut, data);
yf = forecastARDL(modelOut, steps, future_x);
```

`predictARDL` and `forecastARDL` infer the model family from the output
structure. The older `predictQARDL` and `forecastQARDL` names are still
available as backward-compatible aliases for QARDL workflows.

## Formula Workflows

Formula-string workflows are available across the public ARDL-family
estimators. For CS-ARDL dataframe formulas, panel identifiers follow GAUSS
panel-data conventions:

- the first string or category variable is inferred as the unit variable
- the first date variable, or numeric fallback, is inferred as the time variable

CS-ARDL sorts by the inferred or explicit panel identifiers before estimation.
Balanced panels are supported; unbalanced panels are documented as unsupported.

## Lag Selection Defaults

Full workflows and order-selection helpers that perform automatic lag selection
allow omitted maximum lag bounds. The current default maximum search bounds are:

```gauss
p = 8;
q = 8;
```

Explicit `p` and `q` arguments continue to work and should be used when a
replication requires fixed candidate limits.

## Printed Output

Direct estimator calls print formatted tables by default. Pass the final
`print_results = 0` argument in simulations, tests, rolling windows, or other
silent workflows.

Printed coefficient and diagnostic tables now include significance codes:

```text
*** p < 0.01, ** p < 0.05, * p < 0.10
```

## Output Structures

Model outputs now include standardized metadata where available, including
model family, formula, dependent variable, regressor names, lag specification,
sample range, deterministic case, covariance type, selection criterion,
residuals, fitted values, rank diagnostics, and conditioning diagnostics.

See `docs/OUTPUT_SCHEMA.md` for the current field map.

## Reporting

New generic table export helpers support ARDL-family outputs:

```gauss
call saveARDLTable(modelOut, "results.csv", "csv");
call saveARDLMarkdown(modelOut, "results.md");
call saveARDLLaTeX(modelOut, "results.tex");
```

Legacy QARDL CSV export helpers remain available.

## Validation Status

The expanded model families include deterministic synthetic fixtures and
source-tree validation gates. Exact published empirical replications are still
tracked separately in `docs/PUBLISHED_REPLICATIONS.md` and the model-specific
validation notes.
