# GAUSS QARDL Library

## Description

The GAUSS QARDL library implements Quantile Autoregressive Distributed Lag
models for quantile cointegration, asymmetric long-run relationships, and
heterogeneous short-run dynamics. The package includes levels-form QARDL,
two-step and unrestricted QARDL-ECM estimation, OLS ARDL, NARDL, CS-ARDL, ARDL bounds testing,
lag selection, Wald tests, bootstrap confidence intervals, rolling estimation,
quantile impulse responses, prediction/forecast hooks, plotting helpers, and
table export tools.

The minimum supported GAUSS version is GAUSS 26.

## Installation

Install the package in GAUSS using **Tools > Install Application** and select
the release zip file. Load it in a GAUSS program with:

```gauss
library qardl;
```

## Commands

### Integrated Workflow

[ardlFull](command-reference/ardlFull.md)

Runs lag selection, ARDL bounds testing, and levels-form ARDL estimation in
one workflow.

[qardlFull](command-reference/qardlFull.md)

Runs lag selection, ARDL bounds testing, levels-form QARDL, and QARDL-ECM
estimation in one workflow.

[nardlFull](command-reference/nardlFull.md)

Runs lag selection, NARDL levels estimation, and NARDL-ECM estimation in one
workflow.

[csardlFull](command-reference/csardlFull.md)

Runs lag selection, CS-ARDL levels estimation, and CS-ARDL-ECM estimation in
one workflow.

[applyQARDLFormula](command-reference/applyQARDLFormula.md)

Converts a named GAUSS dataframe and formula string into the numeric matrix
ordering expected by QARDL estimators.

[applyNARDLFormula](command-reference/applyNARDLFormula.md)

Converts a named GAUSS dataframe and formula string into the numeric matrix
ordering expected by NARDL estimators.

[applyCSARDLFormula](command-reference/applyCSARDLFormula.md)

Converts a named GAUSS panel dataframe and formula string into the balanced
panel matrix ordering expected by CS-ARDL estimators.

### Estimation

[ardl](command-reference/ardl.md)

Estimates the levels-form ARDL model by OLS.

[ardlECM](command-reference/ardlECM.md)

Estimates ARDL error-correction models by OLS.

[ardlAutoCase](command-reference/ardlAutoCase.md)

Runs hierarchical or sparse GETS selection and deterministic-case inference
for ARDL UECM/bounds workflows.

[qardl](command-reference/qardl.md)

Estimates the levels-form QARDL model.

[qardlRobust](command-reference/qardlRobust.md)

Estimates levels-form QARDL with heteroskedasticity-robust QR sandwich
covariance.

[qardlHAC](command-reference/qardlHAC.md)

Estimates levels-form QARDL with Newey-West/Bartlett HAC QR sandwich
covariance.

[qardlX](command-reference/qardlX.md)

Estimates levels-form QARDL with per-regressor distributed-lag orders.

[qardlECM](command-reference/qardlECM.md)

Estimates the QARDL error-correction model.

[qardlECMRobust](command-reference/qardlECMRobust.md)

Estimates QARDL-ECM with heteroskedasticity-robust covariance for alpha and
rho.

[qardlECMHAC](command-reference/qardlECMHAC.md)

Estimates QARDL-ECM with Newey-West/Bartlett HAC covariance for alpha and rho.

[qardlECMX](command-reference/qardlECMX.md)

Estimates QARDL-ECM with per-regressor distributed-lag orders.

[nardl](command-reference/nardl.md)

Estimates nonlinear ARDL models with positive and negative partial-sum
decompositions, including optional decomposed-variable and linear-control
specifications.

[nardlECM](command-reference/nardlECM.md)

Estimates NARDL error-correction models.

[nardlAutoCase](command-reference/nardlAutoCase.md)

Runs hierarchical or sparse GETS selection and deterministic-case inference
for NARDL UECM/bounds workflows.

[csardl](command-reference/csardl.md)

Estimates pooled cross-sectionally augmented ARDL panel models.

[csardlECM](command-reference/csardlECM.md)

Estimates CS-ARDL error-correction models.

### Lag Selection

[ardlSelect](command-reference/ardlSelect.md)

Selects ARDL-family lag orders through one standardized wrapper for ARDL,
QARDL, NARDL, and CS-ARDL.

[ardlSparseGETS](command-reference/ardlSparseGETS.md)

Runs standalone sparse GETS reduction on the Case V ARDL unrestricted ECM.

[nardlSparseGETS](command-reference/nardlSparseGETS.md)

Runs standalone sparse GETS reduction on the Case V NARDL unrestricted ECM.

[pqSelect](command-reference/pqSelect.md)

Selects ARDL/QARDL lag orders or returns lag-search grids for scalar and
per-regressor q specifications.

[icmean](command-reference/icmean.md)

Computes an information criterion for a specified ARDL lag order.

[nardlOrder](command-reference/nardlOrder.md)

Selects NARDL p and q lag orders by information criterion.

[nardlOrderGrid](command-reference/nardlOrderGrid.md)

Returns the full NARDL information-criterion lag-search table.

[nardlICMean](command-reference/nardlICMean.md)

Computes an information criterion for a specified NARDL lag order.

[csardlOrder](command-reference/csardlOrder.md)

Selects CS-ARDL p and q lag orders by information criterion.

[csardlOrderGrid](command-reference/csardlOrderGrid.md)

Returns the full CS-ARDL information-criterion lag-search table.

[csardlICMean](command-reference/csardlICMean.md)

Computes an information criterion for a specified CS-ARDL lag order.

### ARDL Bounds Testing

[ardlbounds](command-reference/ardlbounds.md)

Computes the compatibility Case III Pesaran-Shin-Smith ARDL bounds test.

[ardlboundsCase](command-reference/ardlboundsCase.md)

Computes ARDL bounds tests for deterministic Cases I-V.

[ardlboundsCaseSim](command-reference/ardlboundsCaseSim.md)

Computes ARDL bounds tests with simulated finite-sample critical values.

[ardlboundsCaseCV](command-reference/ardlboundsCaseCV.md)

Returns bundled or simulated ARDL bounds critical values.

[ardlbounds_print](command-reference/ardlbounds_print.md)

Prints compatibility Case III ARDL bounds-test output.

[ardlboundsCase_print](command-reference/ardlboundsCase_print.md)

Prints deterministic Case I-V ARDL bounds-test output.

[ardlboundsCaseSimCV](command-reference/ardlboundsCaseSimCV.md)

Simulates finite-sample ARDL bounds critical values.

### Inference

[qardl_pval](command-reference/qardl_pval.md)

Computes asymptotic normal p-values for levels-form estimates.

[qardl_pval_ecm](command-reference/qardl_pval_ecm.md)

Computes asymptotic normal p-values for QARDL-ECM estimates.

[wtestlrb](command-reference/wtestlrb.md)

Runs custom Wald tests for long-run beta restrictions.

[wtestsrp](command-reference/wtestsrp.md)

Runs custom Wald tests for short-run phi restrictions.

[wtestsrg](command-reference/wtestsrg.md)

Runs custom Wald tests for x-level gamma/theta restrictions.

[wtestconst](command-reference/wtestconst.md)

Tests cross-quantile parameter constancy.

[wtestsym](command-reference/wtestsym.md)

Tests cross-quantile symmetry.

### Bootstrap, Rolling, And Dynamics

[blockBootstrapQARDL](command-reference/blockBootstrapQARDL.md)

Computes block-bootstrap confidence intervals for levels-form QARDL estimates.

[blockBootstrapQARDLECM](command-reference/blockBootstrapQARDLECM.md)

Computes block-bootstrap confidence intervals for QARDL-ECM alpha and rho.

[blockBootstrapQIRF](command-reference/blockBootstrapQIRF.md)

Computes QIRF point estimates with bootstrap confidence bands.

[rollingQardl](command-reference/rollingQardl.md)

Runs rolling-window levels-form QARDL estimation.

[rollingQardlECM](command-reference/rollingQardlECM.md)

Runs rolling-window QARDL-ECM estimation.

[qirf](command-reference/qirf.md)

Computes quantile impulse response functions.

[nardlDynamicMultipliers](command-reference/nardlDynamicMultipliers.md)

Computes positive and negative NARDL dynamic multiplier paths.

### Output, Plotting, And Export

[ardlReport](command-reference/ardlReport.md)

Prints and/or exports ARDL-family reports through one unified wrapper.

[printARDLSparseGETS](command-reference/printARDLSparseGETS.md)

Prints sparse GETS retained and dropped term output.

[printARDL](command-reference/printARDL.md)

Prints formatted levels-form ARDL results.

[printARDLECM](command-reference/printARDLECM.md)

Prints formatted ARDL-ECM results.

[printQARDL](command-reference/printQARDL.md)

Prints formatted levels-form QARDL results.

[printQARDLECM](command-reference/printQARDLECM.md)

Prints formatted QARDL-ECM results.

[printNARDL](command-reference/printNARDL.md)

Prints formatted NARDL levels results.

[printNARDLECM](command-reference/printNARDLECM.md)

Prints formatted NARDL-ECM results.

[printCSARDL](command-reference/printCSARDL.md)

Prints formatted CS-ARDL levels results.

[printCSARDLECM](command-reference/printCSARDLECM.md)

Prints formatted CS-ARDL-ECM results.

[predictARDL](command-reference/predictARDL.md)

Returns in-sample fitted values from estimated ARDL-family models.

[forecastARDL](command-reference/forecastARDL.md)

Computes recursive ARDL-family forecasts.

[predictQARDL](command-reference/predictQARDL.md)

Returns in-sample fitted values from an estimated QARDL model.

[forecastQARDL](command-reference/forecastQARDL.md)

Computes recursive QARDL forecasts by quantile.

[predictNARDL](command-reference/predictNARDL.md)

Returns in-sample fitted values from an estimated NARDL model.

[forecastNARDL](command-reference/forecastNARDL.md)

Computes recursive NARDL point forecasts.

[predictCSARDL](command-reference/predictCSARDL.md)

Returns in-sample fitted values from an estimated CS-ARDL model.

[forecastCSARDL](command-reference/forecastCSARDL.md)

Returns CS-ARDL point forecasts.

[ardlLongRun](command-reference/ardlLongRun.md)

Extracts stored long-run coefficients and covariance matrices from ARDL-family
outputs.

[ardlResidualDiagnostics](command-reference/ardlResidualDiagnostics.md)

Computes time-series residual diagnostics for ARDL-family outputs.

[csardlDiagnostics](command-reference/csardlDiagnostics.md)

Computes optional CS-ARDL mean-group, poolability, Pesaran-Yamagata slope
homogeneity, and Pesaran CD/CD(p) cross-sectional dependence diagnostics.

[printCSARDLDiagnostics](command-reference/printCSARDLDiagnostics.md)

Prints CS-ARDL panel diagnostics.

[plotQARDL](command-reference/plotQARDL.md)

Plots QARDL parameter paths across quantiles.

[plotQARDLbands](command-reference/plotQARDLbands.md)

Plots QARDL parameter paths with confidence bands.

[plotQIRF](command-reference/plotQIRF.md)

Plots quantile impulse response functions.

[plotRollingQARDL](command-reference/plotRollingQARDL.md)

Plots rolling QARDL coefficient paths.

[plotRollingQARDLECM](command-reference/plotRollingQARDLECM.md)

Plots rolling QARDL-ECM coefficient paths.

[saveARDLTable](command-reference/saveARDLTable.md)

Exports ARDL-family coefficient tables to CSV, Markdown, or LaTeX.

[saveARDLMarkdown](command-reference/saveARDLMarkdown.md)

Exports ARDL-family coefficient tables to Markdown.

[saveARDLLaTeX](command-reference/saveARDLLaTeX.md)

Exports ARDL-family coefficient tables to LaTeX.

[saveQARDLResults](command-reference/saveQARDLResults.md)

Exports levels-form QARDL matrix results to CSV files.

[saveQARDLECMResults](command-reference/saveQARDLECMResults.md)

Exports QARDL-ECM matrix results to CSV files.

## Further Reading

- [QARDL Usage Guide](USAGE_GUIDE.md)
- [Migration Guide](MIGRATION_GUIDE.md)
- [Methodology Notes](guides/METHODOLOGY_NOTES.md)
- [Feature Support Matrix](FEATURE_SUPPORT_MATRIX.md)
- [Diagnostics Guide](guides/DIAGNOSTICS_GUIDE.md)
- [Forecasting Guide](guides/FORECASTING_GUIDE.md)
- [Data Handling And Lag Alignment](guides/DATA_HANDLING.md)
- [Inference Interval Support](guides/INFERENCE_INTERVALS.md)
- [Reporting And Plotting Support](guides/REPORTING_AND_PLOTTING.md)
- [ARDL/NARDL R-Package Validation](validation/R_PACKAGE_VALIDATION.md)
- [Performance And Numerical Reliability](validation/PERFORMANCE_NUMERICAL_RELIABILITY.md)
- [Validation Tolerances](validation/VALIDATION_TOLERANCES.md)
- [Published QARDL Replication Notes](validation/PUBLISHED_REPLICATIONS.md)
- [QARDL 3.1.1 Release Notes](release/QARDL_3_1_1_RELEASE_NOTES.md)
- [QARDL 3.1.0 Release Article](release/QARDL_3_1_0_RELEASE_ARTICLE.md)
- [Historical QARDL 3.0.0 Release Article](archive/QARDL_RELEASE_ARTICLE.md)
- [Citation Guide](../CITATION.md)
- [LLM Reference](../llms.txt)

## Reference

The QARDL library is based on original GAUSS code by Jin Seo Cho and has been
updated for GAUSS 26 with modern structures, expanded inference tools, and
release test coverage.
