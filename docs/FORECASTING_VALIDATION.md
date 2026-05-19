# Prediction And Forecast Validation

This note documents the current `predictARDL` and `forecastARDL` contract and
the deterministic fixtures that validate it.

## Supported Calls

```gauss
fit = predictARDL(modelOut, data);
fcst = forecastARDL(modelOut, data, h);
fcst = forecastARDL(modelOut, data, h, formula);
fcst = forecastARDL(modelOut, data, h, formula, future_x);
```

`modelOut` may be an `ardlOut`, `qardlOut`, `nardlOut`, or `csardlOut`
structure. For full-workflow outputs, pass the nested estimator structure,
such as `afOut.ar`, `qfOut.qa`, `nfOut.na`, or `cfOut.csa`.

## Forecast Assumptions

When `future_x` is omitted, ARDL, QARDL, and NARDL forecasts hold future
regressor levels fixed at their last observed values. Future contemporaneous
differences are therefore zero, while lagged differenced-regressor terms from
the historical sample still enter the first forecast periods when `q > 1`.

When supplied, `future_x` must be an `h x k` matrix, or have at least `h` rows
and `k` columns, where `k` is the number of regressors. Only the first `h`
rows are used.

Model-specific behavior:

- ARDL: recursive levels forecasts use future regressor levels, differenced
  regressor terms implied by the combined historical/future regressor path,
  and recursively generated lagged dependent values.
- QARDL: the same recursion is applied separately for each quantile; the
  result is `h x S`.
- NARDL: the future regressor path is decomposed into positive and negative
  partial sums before recursive forecasting.
- CS-ARDL: the current panel forecast hook repeats the last fitted value and
  does not support `future_x` panel paths yet.

## Active Validation

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1
```

Active fixtures include:

- `tests/validation_cases/synthetic/prediction_forecast_validation.e`
- `tests/fixtures/expected/synthetic/predictions/`
- `tests/fixtures/expected/synthetic/forecasts/`

The validation case checks:

- in-sample fitted values for ARDL, QARDL, NARDL, and CS-ARDL
- unified `predictARDL` and `forecastARDL` dispatch
- backward-compatible `predictQARDL` and `forecastQARDL` wrappers
- model-specific NARDL and CS-ARDL prediction/forecast wrappers
- hold-last forecasts when `future_x` is omitted
- explicit future-regressor-path forecasts for ARDL, QARDL, and NARDL

## Forecast Intervals

`forecastARDL` currently returns point forecasts only. Forecast intervals are
not statistically implemented for ARDL, QARDL, NARDL, or CS-ARDL outputs.
QIRF and bootstrap coefficient interval workflows are separate and should not
be interpreted as forecast intervals.

## Remaining Gaps

- Add expected-error tests for malformed `future_x` paths once the GAUSS test
  harness has a standard expected-error capture pattern.
- Add external or published forecast benchmarks for each model family.
- Add statistically supported forecast intervals only after the method and
  bootstrap policy are documented.
- Replace the CS-ARDL placeholder forecast with a panel-aware recursive
  forecast design once future panel paths are specified.
