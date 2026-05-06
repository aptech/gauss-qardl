# GAUSS QARDL Library

## Description

The GAUSS QARDL library implements Quantile Autoregressive Distributed Lag
models for quantile cointegration, asymmetric long-run relationships, and
heterogeneous short-run dynamics. The package includes levels-form QARDL,
two-step QARDL-ECM estimation, ARDL bounds testing, lag selection, Wald tests,
bootstrap confidence intervals, rolling estimation, quantile impulse responses,
plotting helpers, and CSV export tools.

The minimum supported GAUSS version is GAUSS 26.

## Installation

Install the package in GAUSS using **Tools > Install Application** and select
the release zip file. Load it in a GAUSS program with:

```gauss
library qardl;
```

## Commands

### Integrated Workflow

[qardlFull](command-reference/qardlFull.md)

Runs lag selection, ARDL bounds testing, levels-form QARDL, and two-step
QARDL-ECM estimation in one workflow.

[applyQARDLFormula](command-reference/applyQARDLFormula.md)

Converts a named GAUSS dataframe and formula string into the numeric matrix
ordering expected by QARDL estimators.

### Estimation

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

Estimates the two-step QARDL error-correction model.

[qardlECMRobust](command-reference/qardlECMRobust.md)

Estimates QARDL-ECM with heteroskedasticity-robust covariance for alpha and
rho.

[qardlECMHAC](command-reference/qardlECMHAC.md)

Estimates QARDL-ECM with Newey-West/Bartlett HAC covariance for alpha and rho.

[qardlECMX](command-reference/qardlECMX.md)

Estimates QARDL-ECM with per-regressor distributed-lag orders.

### Lag Selection

[pqorder](command-reference/pqorder.md)

Selects scalar p and q lag orders by information criterion.

[pqorderRange](command-reference/pqorderRange.md)

Selects scalar p and q lag orders over a restricted search grid.

[pqorderGrid](command-reference/pqorderGrid.md)

Returns the full scalar p/q information-criterion search table.

[pqorderRangeGrid](command-reference/pqorderRangeGrid.md)

Returns a restricted scalar p/q information-criterion search table.

[pqorderX](command-reference/pqorderX.md)

Selects p and a per-regressor q vector by information criterion.

[pqorderXGrid](command-reference/pqorderXGrid.md)

Returns the full per-regressor q-vector information-criterion search table.

[icmean](command-reference/icmean.md)

Computes an information criterion for a specified ARDL lag order.

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

[rollingQardl](command-reference/rollingQardl.md)

Runs rolling-window levels-form QARDL estimation.

[rollingQardlECM](command-reference/rollingQardlECM.md)

Runs rolling-window two-step QARDL-ECM estimation.

[qirf](command-reference/qirf.md)

Computes quantile impulse response functions.

### Output, Plotting, And Export

[printQARDL](command-reference/printQARDL.md)

Prints formatted levels-form QARDL results.

[printQARDLECM](command-reference/printQARDLECM.md)

Prints formatted two-step QARDL-ECM results.

[plotQARDL](command-reference/plotQARDL.md)

Plots QARDL parameter paths across quantiles.

[plotQARDLbands](command-reference/plotQARDLbands.md)

Plots QARDL parameter paths with confidence bands.

[plotQIRF](command-reference/plotQIRF.md)

Plots quantile impulse response functions.

[saveQARDLResults](command-reference/saveQARDLResults.md)

Exports levels-form QARDL results to CSV files.

[saveQARDLECMResults](command-reference/saveQARDLECMResults.md)

Exports QARDL-ECM results to CSV files.

## Further Reading

- [QARDL Usage Guide](USAGE_GUIDE.md)
- [Published QARDL Replication Notes](PUBLISHED_REPLICATIONS.md)
- [QARDL 3.0.1 Roadmap](ROADMAP_3_0_1.md)
- [LLM Reference](../llms.txt)
- [Release Checklist](../RELEASE_CHECKLIST.md)

## Reference

The QARDL library is based on original GAUSS code by Jin Seo Cho and has been
updated for GAUSS 26 with modern structures, expanded inference tools, and
release test coverage.
