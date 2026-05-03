# Changelog

## 3.0.0 - 2026-05-03

### Added
- GAUSS 26 source smoke tests for public APIs and workflow APIs.
- Installed-package release gate for `library qardl`.
- Package manifest verifier for `package.json`/`src` consistency.
- `qardlFull(..., verbose = 1)` option; pass `0` to compute silently.
- Metadata fields on `qardlOut`, `qardlECMOut`, and `qardlFullOut`.
- `GOLD_STANDARD_TODO.md` release-readiness inventory and improvement backlog.

### Fixed
- GAUSS 26 zero-column matrix failures in `ardlbounds`.
- GAUSS 26 compile/runtime failures in `qirf`, `wtestsym`, and `wtestconst`.
- Moving-block bootstrap index construction.
- `rollingQardl` when only one p value is tested.
- Formula lookup in `applyQARDLFormula`.
- GAUSS-compatible number formatting in `ardlbounds_print`.
- Package manifest ordering and duplicate source entries.

### Changed
- Minimum supported GAUSS version is GAUSS 26.
- Source tests explicitly include local `qardl.sdf` so stale installed structs
  cannot mask source-tree changes.

