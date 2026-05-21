# Forecasting Guide

The package exposes a unified forecasting API for ARDL-family output
structures.

## Public Calls

Use these functions for new code:

```gauss
yhat = predictARDL(modelOut, data);
yf = forecastARDL(modelOut, steps, future_x);
```

`modelOut` may be an ARDL, QARDL, NARDL, or CS-ARDL output structure. The
function dispatches internally based on the structure type.

The older QARDL names remain available:

```gauss
yhat_q = predictQARDL(qardlOut, data);
yf_q = forecastQARDL(qardlOut, steps, future_x);
```

These wrappers are preserved for backward compatibility.

## Future Regressor Paths

`future_x` supplies future paths for exogenous regressors. Use it when forecasts
must follow a known scenario:

```gauss
future_x = { 1.20 0.80,
             1.25 0.82,
             1.30 0.85 };

yf = forecastARDL(modelOut, 3, future_x);
```

When `future_x` is omitted, supported forecast paths use documented hold-last
behavior for exogenous regressors. Replications and scenario forecasts should
prefer explicit future paths.

## Model-Specific Notes

| Family | Forecast behavior |
| --- | --- |
| ARDL | Recursive point forecasts using stored lag and coefficient metadata. |
| QARDL | Recursive point forecasts by quantile; legacy wrappers remain. |
| NARDL | Future paths are decomposed into positive and negative changes where supported. |
| CS-ARDL | Balanced-panel forecast hooks are available; external panel forecast validation remains pending. |

## Forecast Intervals

Forecast intervals are not yet standardized across ARDL, QARDL, NARDL, and
CS-ARDL. Current forecast APIs return point forecasts. Use
`docs/INFERENCE_INTERVALS.md` for the current uncertainty-support matrix.

## Rolling-Origin Forecasts

See `examples/rolling_forecast_example.e` for a concise rolling-origin
workflow. Rolling-origin examples are useful for checking forecast plumbing and
future-regressor assumptions, but they are not a substitute for a full
out-of-sample validation design.

## Validation

Deterministic forecast fixtures are tracked in
`docs/FORECASTING_VALIDATION.md`. Published external forecast validation is
still a roadmap item for CS-ARDL and broader empirical examples.
