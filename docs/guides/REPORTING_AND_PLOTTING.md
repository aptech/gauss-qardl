# Reporting And Plotting Support

This note records the current reporting and plot behavior for the ARDL-family
workflows.

## Table Export

Generic coefficient-table export is available through:

```gauss
saveARDLTable(modelOut, fpath, table_format, precision, stars, ci_level);
saveARDLMarkdown(modelOut, fpath, precision, stars, ci_level);
saveARDLLaTeX(modelOut, fpath, precision, stars, ci_level);
```

Supported formats are Markdown, LaTeX `tabular`, and CSV. Supported model
outputs include ARDL, QARDL, QARDL-ECM, NARDL, NARDL-ECM, CS-ARDL,
CS-ARDL-ECM, and the matching full-workflow structures.

The exporter supports:

- numeric precision control
- optional significance-code column
- optional confidence-interval columns

Rows without stored standard errors are exported with blank uncertainty cells.
This is intentional for reporting consistency; it does not imply those
intervals are statistically available.

The older `saveQARDLResults` and `saveQARDLECMResults` CSV helpers remain the
best option when a user wants QARDL-specific machine-readable parameter-group
files.

## Plot Band Support

| Plot helper | Confidence bands | Notes |
| --- | --- | --- |
| `plotQARDL` | Optional | Delegates to `plotQARDLbands` when `show_bands = 1`. |
| `plotQARDLbands` | Yes | Uses covariance matrices stored in `qardlOut`. |
| `plotRollingQARDL` | Optional | Uses stored rolling standard errors. |
| `plotRollingQARDLECM` | Optional | Uses stored rolling standard errors. |
| `plotQIRF` | Optional | Uses `qirfOut.irf_lb` and `qirfOut.irf_ub` when available. |

When QIRF confidence-band fields are not populated, `plotQIRF(qOut, 1)`
prints a message and plots response paths only.

## Automated Plot Smoke Tests

`tests/run_plot_smoke_tests.ps1` is wired into the source test runner and
skips cleanly by default. Set:

```powershell
$env:QARDL_RUN_PLOT_TESTS = "1"
```

before running `tests/run_source_tests.ps1` to exercise the GAUSS plot calls in
an environment with graphics support.

## Save-To-File Plotting

The current plot helpers display plots through GAUSS plotting tools. A
package-level save-to-file plotting API is not yet standardized. Users who
need file output should use GAUSS graph export facilities around the generated
plots until a package-level wrapper is added.
