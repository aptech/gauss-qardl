# Diagnostics Guide

Diagnostics are exposed as explicit helper workflows so users can decide which
checks belong in a given empirical design. Estimator output tables report core
model results; diagnostic helpers report additional checks.

## Time-Series Residual Diagnostics

Use `ardlResidualDiagnostics` with supported ARDL-family time-series outputs:

```gauss
diagOut = ardlResidualDiagnostics(modelOut);
call printARDLResidualDiagnostics(diagOut);
```

Current checks include:

| Diagnostic | Purpose | Status |
| --- | --- | --- |
| Ljung-Box | residual serial correlation | Implemented |
| Breusch-Pagan-style auxiliary regression | heteroskedasticity | Implemented |
| Jarque-Bera | residual normality | Implemented |
| Residual CUSUM and CUSUMSQ | residual stability screening | Implemented |
| Recursive-residual CUSUM/CUSUMSQ | structural stability | TODO |

The residual CUSUM paths are screening diagnostics. Full recursive-residual
stability tests remain deferred until model outputs retain standardized
design-matrix metadata for all supported families.

## CS-ARDL Panel Diagnostics

Use `csardlDiagnostics` with CS-ARDL outputs:

```gauss
diagOut = csardlDiagnostics(csOut);
call printCSARDLDiagnostics(diagOut);
```

Current checks include:

| Diagnostic | Purpose | Status |
| --- | --- | --- |
| Mean-group summary | compares pooled and unit-level long-run coefficients | Implemented |
| Poolability Wald | tests pooled versus unit-level long-run restrictions | Implemented |
| Slope heterogeneity | summarizes unit-level long-run coefficient dispersion | Implemented |
| Pesaran CD | residual cross-sectional dependence | Implemented |

CS-ARDL diagnostics currently require balanced panels. Unbalanced panel inputs
are documented as unsupported and covered by expected-failure tests.

## Bounds Testing

Bounds testing is documented separately in `docs/BOUNDS_TESTING_SUPPORT.md`.
ARDL supports deterministic Cases I-V through the bounds-test APIs. QARDL full
workflows use the compatibility path where definitions overlap. NARDL reports a
bounds-style statistic without full PSS critical-value integration.

## Significance Codes

Printed coefficient and diagnostic tables use:

```text
*** p < 0.01, ** p < 0.05, * p < 0.10
```

Significance codes are display aids, not substitutes for model-specific
diagnostic interpretation.

## Validation Notes

Diagnostic fixture status is tracked in:

- `docs/QARDL_VALIDATION.md`
- `docs/NARDL_VALIDATION.md`
- `docs/CSARDL_VALIDATION.md`
- `docs/FORECASTING_VALIDATION.md`
- `docs/PUBLISHED_REPLICATIONS.md`
