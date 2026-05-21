# Inference And Interval Support

This matrix records the current uncertainty and interval policy for the
ARDL-family workflows. It separates implemented features from documented
gaps so examples, plots, and validation tests do not imply unsupported
inference.

## Covariance Metadata

All major estimator outputs record `covariance_type`, and the standard print
helpers display that label. Current labels include `ols`, `iid`, `robust`,
and `hac` depending on the workflow.

| Family | Classical covariance | Robust covariance | HAC covariance | Notes |
| --- | --- | --- | --- | --- |
| ARDL | Yes | TODO | TODO | Levels-form OLS covariance is stored and printed. |
| QARDL | Yes | Yes | Yes | Robust and HAC paths are implemented for levels and ECM workflows. |
| NARDL | Yes | TODO | TODO | Robust/HAC extension needs method and validation notes first. |
| CS-ARDL | Yes | TODO | TODO | Panel robust/HAC options need a separate design decision. |

## Long-Run Coefficients

Use `ardlLongRun(modelOut)` to extract stored long-run coefficients and
long-run covariance matrices from ARDL, QARDL, NARDL, CS-ARDL, or matching
full-workflow outputs. The helper dispatches by structure type and does not
recompute estimates.

ECM outputs do not yet expose a uniform full long-run covariance surface
across every model family, so `ardlLongRun` is intentionally scoped to levels
and full-workflow outputs.

## Bootstrap And Confidence Bands

| Feature | Status | Validation |
| --- | --- | --- |
| QARDL bootstrap coefficient intervals | Implemented | Synthetic fixtures and author-demo validation notes. |
| QIRF bootstrap bands | Implemented | Stored numerical fixtures and plot smoke coverage. |
| Plot confidence-band controls | Implemented where interval data exist | Plot helpers fall back gracefully when bands are missing. |
| Forecast intervals | Deferred | `forecastARDL` returns point forecasts only; no standard interval fields are exposed until a validated method is selected. |
| Prediction intervals | Deferred | `predictARDL` returns fitted values only; no standard interval fields are exposed until a validated method is selected. |
| Simultaneous bands | Deferred | Current QIRF and coefficient intervals are pointwise. |

## Wald And Diagnostic P-Values

Current Wald, long-run asymmetry, residual diagnostic, and CS-ARDL panel
diagnostic p-values are asymptotic. Small-sample and bootstrap p-values are
intentionally deferred unless a specific published practice is selected and
validated.

## Prediction And Forecast Interval Fields

No prediction or forecast interval fields are currently attached to
`predictARDL` or `forecastARDL` outputs because those functions return matrices
of fitted values or point forecasts. Interval result structures should be added
only when model-family-specific uncertainty calculations are implemented and
validated.

## Remaining Design Decisions

- Decide whether robust/HAC covariance options should be extended to ARDL,
  NARDL, and CS-ARDL.
- Add statistically supported prediction and forecast interval structures
  before exposing interval plots for forecasts.
- Decide whether QARDL coefficient paths and QIRFs need simultaneous bands in
  addition to the current pointwise bands.
- Extend forecast interval support after statistically validated bootstrap or
  analytic intervals are available for each model family.
