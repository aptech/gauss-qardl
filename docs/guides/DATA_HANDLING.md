# Data Handling And Lag Alignment

This note documents the current package policy for missing values, lag
alignment, formula input, and effective estimation samples.

## Missing Values

ARDL-family estimators do not silently drop missing rows. Public estimators
validate inputs and fail with a clear message when estimation data contain
missing values.

Users should clean, align, and transform data before estimation. This policy
avoids ambiguous lag construction when a missing value appears inside a lagged
dependent-variable or distributed-lag block.

CS-ARDL panel workflows also require complete balanced panels. Missing panel
cells and unbalanced panels are unsupported in the current implementation.

## Lag Alignment

Estimator outputs record:

- `sample_start`
- `sample_end`
- `estimation_start`
- `estimation_end`
- `nobs`

For time-series models, `estimation_start` and `estimation_end` are row indices
in the input sample after lag alignment. For CS-ARDL outputs, these fields are
within-unit time indices after sorting and lag alignment.

The effective estimation sample begins after the maximum lag needed by the
model. ECM workflows generally begin one row later than the corresponding
levels workflow because they include first differences and a lagged
error-correction term.

## Formula And Matrix Parity

Formula workflows should match equivalent matrix/dataframe calls after variable
selection and reordering. Source schema tests cover this parity for ARDL,
QARDL, NARDL, and CS-ARDL.

The lightweight formula parser supports simple column names separated by `+`.
Names may also be wrapped in backticks or single quotes, for example:

```gauss
arOut = ardl(df, 1, 1, "`y` ~ `x1` + `x2`");
```

For CS-ARDL dataframe formulas, the unit and time variables follow GAUSS
panel-data conventions:

- first string or category variable: unit
- first date variable, or first numeric fallback: time

Formula CS-ARDL input is sorted by unit and time before estimation.

## Future Regressor Paths

`forecastARDL` supports explicit `future_x` paths for ARDL, QARDL, and NARDL.
The supplied path must have at least `h` rows and one column per regressor, and
it cannot contain missing values.

When `future_x` is omitted, supported forecast paths hold future regressor
levels fixed at their last observed values.

CS-ARDL explicit `future_x` panel paths are not yet supported; CS-ARDL forecasts
use the documented hold-last policy.

## Numerical Metadata

Main estimator outputs store:

- `design_rank`
- `design_cols`
- `design_condition`

These fields describe the estimation design matrix used by the model. Rank
deficient estimation designs fail rather than being silently estimated.
