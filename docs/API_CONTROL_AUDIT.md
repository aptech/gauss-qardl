# API Control-Structure Audit

Status date: 2026-05-12

This audit covers the Milestone 1 decision point for long positional APIs. The
current baseline keeps public signatures stable and does not add new control
structures yet.

## Decision

Do not introduce new control-structure APIs in the schema-baseline pass.

Reason:

- ARDL, QARDL, NARDL, and CS-ARDL already have working public signatures.
- The schema baseline is additive and should not change call patterns.
- Control structures should be introduced only when they simplify a concrete
  public workflow and can be documented, tested, and kept compatible with
  existing positional calls.

## Future Control-Structure Candidates

These procedures have enough optional arguments to justify a future control
structure:

- `qardlFull`: lag-search bounds, quantiles, formula, verbosity, criterion,
  covariance type, and HAC lags.
- `qardl`: quantiles, covariance type, HAC lags, and print behavior.
- `qardlECM`: quantiles, covariance type, HAC lags, and print behavior.
- `qardlX` and `qardlECMX`: heterogeneous lag vectors plus covariance options.
- `blockBootstrapQARDL`, `blockBootstrapQARDLECM`, and `blockBootstrapQIRF`:
  bootstrap replication count, block length, alpha, seed, and method.
- Plot helpers with confidence-band options.

Lower-priority candidates:

- `ardlFull`, `nardlFull`, and `csardlFull`, because their current optional
  arguments are shorter and mirror existing library style.
- `csardlDiagnostics`, if panel diagnostic options expand.

## Recommended Pattern

When a control structure is added, use the existing package style:

- Keep the current positional procedure working.
- Add a `getDefault...Control` helper only for the new control-structure path.
- Store the resolved control choices in output metadata where relevant.
- Add source and installed-package tests for both positional and control paths.
- Document every control member in the command reference.

## Current Milestone 1 Outcome

- No new public control structures were added.
- No existing public signatures were changed.
- Output metadata now records the resolved formula, variable names, covariance
  type, deterministic case, lag metadata, and selection criterion.
- `getDefault...Control` helpers remain deferred until a concrete control
  structure is added.

