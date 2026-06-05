# QARDL Command Reference

This command reference follows the standard GAUSS documentation pattern:
each user-facing procedure should have a page with `Purpose`, `Format`,
`Parameters`, `Returns`, `Remarks`, `Examples`, `Source`, and `See Also`
sections.

## User Guides

- [Bounds testing support matrix](guides/BOUNDS_TESTING_SUPPORT.md)
- [Inference and interval support matrix](guides/INFERENCE_INTERVALS.md)
- [Reporting and plotting support](guides/REPORTING_AND_PLOTTING.md)
- [Migration guide](MIGRATION_GUIDE.md)
- [Methodology notes](guides/METHODOLOGY_NOTES.md)
- [Feature support matrix](FEATURE_SUPPORT_MATRIX.md)
- [Diagnostics guide](guides/DIAGNOSTICS_GUIDE.md)
- [Forecasting guide](guides/FORECASTING_GUIDE.md)
- [Data handling and lag alignment](guides/DATA_HANDLING.md)

## Validation And Developer Notes

- [ARDL-family output schema](developer/OUTPUT_SCHEMA.md)
- [Prediction and forecast validation](validation/FORECASTING_VALIDATION.md)
- [ARDL/NARDL R-package validation](validation/R_PACKAGE_VALIDATION.md)
- [R `ardl.nardl` functionality inventory](developer/R_PACKAGE_FUNCTIONALITY_INVENTORY.md)
- [Performance and numerical reliability](validation/PERFORMANCE_NUMERICAL_RELIABILITY.md)
- [Validation tolerances](validation/VALIDATION_TOLERANCES.md)

## Core Workflow

- [ardlFull](command-reference/ardlFull.md)
- [ardlAutoCase](command-reference/ardlAutoCase.md)
- [qardlFull](command-reference/qardlFull.md)
- [nardlFull](command-reference/nardlFull.md)
- [nardlAutoCase](command-reference/nardlAutoCase.md)
- [csardlFull](command-reference/csardlFull.md)
- [applyQARDLFormula](command-reference/applyQARDLFormula.md)
- [applyNARDLFormula](command-reference/applyNARDLFormula.md)
- [applyCSARDLFormula](command-reference/applyCSARDLFormula.md)

## Estimation

- [ardl](command-reference/ardl.md)
- [ardlECM](command-reference/ardlECM.md)
- [qardl](command-reference/qardl.md)
- [qardlRobust](command-reference/qardlRobust.md)
- [qardlHAC](command-reference/qardlHAC.md)
- [qardlX](command-reference/qardlX.md)
- [qardlECM](command-reference/qardlECM.md)
- [qardlECMRobust](command-reference/qardlECMRobust.md)
- [qardlECMHAC](command-reference/qardlECMHAC.md)
- [qardlECMX](command-reference/qardlECMX.md)
- [nardl](command-reference/nardl.md)
- [nardlECM](command-reference/nardlECM.md)
- [csardl](command-reference/csardl.md)
- [csardlECM](command-reference/csardlECM.md)

## Lag Selection

- [ardlSelect](command-reference/ardlSelect.md)
- [ardlSparseGETS](command-reference/ardlSparseGETS.md)
- [nardlSparseGETS](command-reference/nardlSparseGETS.md)
- [pqSelect](command-reference/pqSelect.md)
- [nardlOrder](command-reference/nardlOrder.md)
- [nardlOrderGrid](command-reference/nardlOrderGrid.md)
- [csardlOrder](command-reference/csardlOrder.md)
- [csardlOrderGrid](command-reference/csardlOrderGrid.md)
- [icmean](command-reference/icmean.md)
- [nardlICMean](command-reference/nardlICMean.md)
- [csardlICMean](command-reference/csardlICMean.md)

## ARDL Bounds Testing

- [ardlbounds](command-reference/ardlbounds.md)
- [ardlboundsCase](command-reference/ardlboundsCase.md)
- [ardlboundsCaseSim](command-reference/ardlboundsCaseSim.md)
- [ardlboundsCaseCV](command-reference/ardlboundsCaseCV.md)
- [ardlboundsCaseSimCV](command-reference/ardlboundsCaseSimCV.md)
- [ardlbounds_print](command-reference/ardlbounds_print.md)
- [ardlboundsCase_print](command-reference/ardlboundsCase_print.md)

## Inference

- [qardl_pval](command-reference/qardl_pval.md)
- [qardl_pval_ecm](command-reference/qardl_pval_ecm.md)
- [qardlWald](command-reference/qardlWald.md)
- [qardlRestriction](command-reference/qardlRestriction.md)
- [wtestlrb](command-reference/wtestlrb.md)
- [wtestsrp](command-reference/wtestsrp.md)
- [wtestsrg](command-reference/wtestsrg.md)
- [wtestconst](command-reference/wtestconst.md)
- [wtestsym](command-reference/wtestsym.md)
- [ardlResidualDiagnostics](command-reference/ardlResidualDiagnostics.md)
- [printARDLResidualDiagnostics](command-reference/printARDLResidualDiagnostics.md)
- [csardlDiagnostics](command-reference/csardlDiagnostics.md)
- [printCSARDLDiagnostics](command-reference/printCSARDLDiagnostics.md)

## Bootstrap, Rolling, And Dynamics

- [blockBootstrapQARDL](command-reference/blockBootstrapQARDL.md)
- [blockBootstrapQARDLMethod](command-reference/blockBootstrapQARDLMethod.md)
- [blockBootstrapQARDLDiag](command-reference/blockBootstrapQARDLDiag.md)
- [blockBootstrapQARDLECM](command-reference/blockBootstrapQARDLECM.md)
- [blockBootstrapQARDLECMMethod](command-reference/blockBootstrapQARDLECMMethod.md)
- [blockBootstrapQARDLECMDiag](command-reference/blockBootstrapQARDLECMDiag.md)
- [blockBootstrapQIRF](command-reference/blockBootstrapQIRF.md)
- [rollingQardl](command-reference/rollingQardl.md)
- [rollingQardlECM](command-reference/rollingQardlECM.md)
- [qirf](command-reference/qirf.md)
- [nardlDynamicMultipliers](command-reference/nardlDynamicMultipliers.md)

## Output, Plotting, And Export

- [ardlReport](command-reference/ardlReport.md)
- [printARDLSparseGETS](command-reference/printARDLSparseGETS.md)
- [printARDL](command-reference/printARDL.md)
- [printARDLECM](command-reference/printARDLECM.md)
- [ardlLongRun](command-reference/ardlLongRun.md)
- [predictARDL](command-reference/predictARDL.md)
- [forecastARDL](command-reference/forecastARDL.md)
- [printQARDL](command-reference/printQARDL.md)
- [printQARDLECM](command-reference/printQARDLECM.md)
- [predictQARDL](command-reference/predictQARDL.md)
- [forecastQARDL](command-reference/forecastQARDL.md)
- [printNARDL](command-reference/printNARDL.md)
- [printNARDLECM](command-reference/printNARDLECM.md)
- [predictNARDL](command-reference/predictNARDL.md)
- [forecastNARDL](command-reference/forecastNARDL.md)
- [printCSARDL](command-reference/printCSARDL.md)
- [printCSARDLECM](command-reference/printCSARDLECM.md)
- [predictCSARDL](command-reference/predictCSARDL.md)
- [forecastCSARDL](command-reference/forecastCSARDL.md)
- [plotQARDL](command-reference/plotQARDL.md)
- [plotQARDLbands](command-reference/plotQARDLbands.md)
- [plotRollingQARDL](command-reference/plotRollingQARDL.md)
- [plotRollingQARDLECM](command-reference/plotRollingQARDLECM.md)
- [plotQIRF](command-reference/plotQIRF.md)
- [saveARDLTable](command-reference/saveARDLTable.md)
- [saveARDLMarkdown](command-reference/saveARDLMarkdown.md)
- [saveARDLLaTeX](command-reference/saveARDLLaTeX.md)
- [saveQARDLResults](command-reference/saveQARDLResults.md)
- [saveQARDLECMResults](command-reference/saveQARDLECMResults.md)

## Simulation Helper

- [qardlAR2Sim](command-reference/qardlAR2Sim.md)
