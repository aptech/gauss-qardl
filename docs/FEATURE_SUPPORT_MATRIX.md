# Feature Support Matrix

This matrix summarizes the current public support surface. "Standalone" means
the feature is available through an explicit helper rather than automatically
embedded in every estimator call.

| Feature | ARDL | QARDL | NARDL | CS-ARDL |
| --- | --- | --- | --- | --- |
| Levels estimator | Yes | Yes | Yes | Yes |
| Full workflow | Yes | Yes | Yes | Yes |
| ECM workflow | No standalone ECM | Yes | Yes | Yes |
| Formula strings | Yes | Yes | Yes | Yes |
| Automatic lag selection | Yes | Yes | Yes | Yes |
| Default max `p`, `q` when omitted | 8, 8 | 8, 8 | 8, 8 | 8, 8 |
| Unified prediction | Yes | Yes | Yes | Yes |
| Unified point forecast | Yes | Yes | Yes | Yes |
| Forecast intervals | Deferred | Deferred | Deferred | Deferred |
| Bounds tests | Cases I-V | Compatibility path | Bounds-style statistic | Not PSS-integrated |
| Residual diagnostics | Standalone | Standalone | Standalone | Panel diagnostics separate |
| Robust/HAC covariance | OLS baseline | Yes | OLS baseline | OLS baseline |
| Bootstrap intervals | Deferred | Yes | Deferred | Deferred |
| QIRF | No | Yes | No | No |
| Dynamic multipliers | No | No | Yes | No |
| Cross-sectional dependence diagnostics | No | No | No | Yes |
| Mean-group and poolability diagnostics | No | No | No | Yes |
| Plot helpers | Limited | Yes | Yes where supported | Yes where supported |
| Confidence-band plots | When intervals exist | Yes | Graceful fallback | Graceful fallback |
| Generic table export | Yes | Yes | Yes | Yes |
| Published empirical validation | Partial | Author demo plus release fixtures | Release fixtures; more published cases welcome | Release fixtures; more published cases welcome |
| Synthetic deterministic validation | Yes | Yes | Yes | Yes |
| Unbalanced panels | Not applicable | Not applicable | Not applicable | Unsupported |

Related documentation:

- `docs/INFERENCE_INTERVALS.md`
- `docs/FORECASTING_VALIDATION.md`
- `docs/REPORTING_AND_PLOTTING.md`
- `docs/PUBLISHED_REPLICATIONS.md`
- `docs/OUTPUT_SCHEMA.md`
