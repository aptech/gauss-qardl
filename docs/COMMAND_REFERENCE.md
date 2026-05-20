# QARDL Command Reference

This command reference follows the standard GAUSS documentation pattern:
each public procedure should have a page with `Purpose`, `Format`,
`Parameters`, `Returns`, `Remarks`, `Examples`, `Source`, and `See Also`
sections.

## Shared API Notes

- [API control-structure audit](API_CONTROL_AUDIT.md)
- [ARDL-family output schema](OUTPUT_SCHEMA.md)
- [Bounds testing support matrix](BOUNDS_TESTING_SUPPORT.md)
- [Prediction and forecast validation](FORECASTING_VALIDATION.md)

## Core Workflow

- [ardlFull](command-reference/ardlFull.md)
- [qardlFull](command-reference/qardlFull.md)
- [applyQARDLFormula](command-reference/applyQARDLFormula.md)

## Estimation

- [ardl](command-reference/ardl.md)
- [qardl](command-reference/qardl.md)
- [qardlRobust](command-reference/qardlRobust.md)
- [qardlHAC](command-reference/qardlHAC.md)
- [qardlX](command-reference/qardlX.md)
- [qardlECM](command-reference/qardlECM.md)
- [qardlECMRobust](command-reference/qardlECMRobust.md)
- [qardlECMHAC](command-reference/qardlECMHAC.md)
- [qardlECMX](command-reference/qardlECMX.md)
- [nardl](command-reference/nardl.md)
- [csardl](command-reference/csardl.md)

## Lag Selection

- [pqorder](command-reference/pqorder.md)
- [pqorderRange](command-reference/pqorderRange.md)
- [pqorderGrid](command-reference/pqorderGrid.md)
- [pqorderRangeGrid](command-reference/pqorderRangeGrid.md)
- [pqorderX](command-reference/pqorderX.md)
- [pqorderXGrid](command-reference/pqorderXGrid.md)
- nardlOrder / nardlOrderGrid
- csardlOrder / csardlOrderGrid
- [icmean](command-reference/icmean.md)

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
- [wtestlrb](command-reference/wtestlrb.md)
- [wtestsrp](command-reference/wtestsrp.md)
- [wtestsrg](command-reference/wtestsrg.md)
- [wtestconst](command-reference/wtestconst.md)
- [wtestsym](command-reference/wtestsym.md)
- [ardlResidualDiagnostics](command-reference/ardlResidualDiagnostics.md)
- [printARDLResidualDiagnostics](command-reference/printARDLResidualDiagnostics.md)
- [csardlDiagnostics](command-reference/csardlDiagnostics.md)

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

- [printARDL](command-reference/printARDL.md)
- [predictARDL](command-reference/predictARDL.md)
- [forecastARDL](command-reference/forecastARDL.md)
- [printQARDL](command-reference/printQARDL.md)
- [printQARDLECM](command-reference/printQARDLECM.md)
- [predictQARDL](command-reference/predictQARDL.md)
- [forecastQARDL](command-reference/forecastQARDL.md)
- [plotQARDL](command-reference/plotQARDL.md)
- [plotQARDLbands](command-reference/plotQARDLbands.md)
- [plotRollingQARDL](command-reference/plotRollingQARDL.md)
- [plotRollingQARDLECM](command-reference/plotRollingQARDLECM.md)
- [plotQIRF](command-reference/plotQIRF.md)
- [saveQARDLResults](command-reference/saveQARDLResults.md)
- [saveQARDLECMResults](command-reference/saveQARDLECMResults.md)

## Simulation Helper

- [qardlAR2Sim](command-reference/qardlAR2Sim.md)
