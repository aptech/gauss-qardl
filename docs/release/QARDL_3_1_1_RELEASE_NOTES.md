# QARDL 3.1.1 Release Notes

Release date: 2026-06-04

QARDL 3.1.1 is a maintenance and workflow-polish release for the expanded
ARDL-family package introduced in 3.1.0. It focuses on R-package parity,
automatic diagnostics, clearer user-facing APIs, and cleaner examples and
documentation.

## Highlights

- Added `ardlECM` and unrestricted ECM options across ECM-specific workflows.
- Added R-style NARDL specification controls to existing `nardl`,
  `nardlECM`, and `nardlFull` workflows.
- Added hierarchical GETS selection across supported ARDL-family selectors and
  full workflows.
- Added standalone sparse GETS workflows: `ardlSparseGETS`,
  `nardlSparseGETS`, and `printARDLSparseGETS`.
- Added unified selection/reporting wrappers: `pqSelect`, `ardlSelect`, and
  `ardlReport`.
- Added stored diagnostics to `*Full` outputs and optional
  `print_diagnostics` controls.
- Expanded validation and documentation for comparison against the CRAN
  `ardl.nardl` package.
- Cleaned examples so they no longer declare structures explicitly or include
  development TODO notes.

## Diagnostics In Full Workflows

Integrated workflows now store diagnostics for the selected specification:

- `ardlFull.levels_diag`
- `qardlFull.levels_diag`
- `qardlFull.ecm_diag`
- `nardlFull.levels_diag`
- `nardlFull.ecm_diag`
- `csardlFull.panel_diag`

The new `print_diagnostics` argument controls diagnostic printing:

- `-1` follows `verbose` (default)
- `0` stores diagnostics without printing
- `1` prints diagnostics even when `verbose = 0`

## R-Package Parity Work

The 3.1.1 cycle expands parity with the CRAN `ardl.nardl` package:

- fixed-order ARDL/NARDL levels and ECM validation;
- unrestricted ECM comparison notes;
- R-style NARDL decomposed-variable/control specification;
- GETS lag-selection support;
- sparse GETS final-selection diagnostics where R is available;
- developer inventory of remaining parity gaps.

## Documentation

Updated documentation includes:

- command-reference coverage for new public functions;
- updated `OUTPUT_SCHEMA.md`;
- updated migration guide and feature support matrix;
- updated R-package functionality inventory;
- revised examples using direct structure-reference assignment.

## Compatibility

This release preserves the 3.1.0 ARDL/QARDL/NARDL/CS-ARDL package surface.
New arguments are optional and added at the end of existing procedure
signatures wherever possible.

