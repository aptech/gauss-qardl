# Benchmarking Notes

This note tracks lightweight benchmark and validation entry points for the
source tree. Benchmarks remain separate from the release-gate smoke tests so
they can grow without slowing every edit-check cycle.

## Synthetic Implementation Benchmarks

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_new_model_benchmarks.ps1
```

The benchmark script runs `tests/benchmark_nardl_csardl.e`, which:

- Generates seeded synthetic NARDL and CS-ARDL datasets.
- Estimates levels and ECM NARDL models.
- Estimates pooled CS-ARDL and optional mean-group/poolability diagnostics.
- Prints long-run coefficient summaries and the CS-ARDL poolability statistic.

These are deterministic implementation benchmarks, not published-result
replications.

## Expected-Output Validation

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1
```

This runner reads `tests/fixtures/fixture_manifest.csv`, reports the active
synthetic and pending published fixture counts, and runs every GAUSS validation
case under `tests/validation_cases/synthetic/`.

Validation cases compare computed outputs with numeric CSV baselines under:

- `tests/fixtures/expected/synthetic/coefficients/`
- `tests/fixtures/expected/synthetic/decompositions/`
- `tests/fixtures/expected/synthetic/diagnostics/`
- `tests/fixtures/expected/synthetic/forecasts/`
- `tests/fixtures/expected/synthetic/intervals/`
- `tests/fixtures/expected/synthetic/multipliers/`

The GAUSS assertions are quiet on success and report only shape mismatches,
maximum absolute differences, and tolerances on failure.

## Published-Result Benchmarks

Published-result and published-reference cases are intentionally separate from
synthetic validation. The current published-reference cases check selected
Pesaran-Shin-Smith ARDL bounds critical values and the Cho-Kim-Shin QARDL
author-demo outputs documented in `docs/QARDL_VALIDATION.md`. When exact
empirical datasets and specifications are available, add additional GAUSS cases
under `tests/validation_cases/published/` and run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1 -IncludePublished
```

Published expected outputs should be stored under
`tests/fixtures/expected/published/` and registered in
`tests/fixtures/fixture_manifest.csv`.

TODO: add paper-specific benchmark scripts when exact datasets,
transformations, sample windows, and lag specifications are available for
redistribution or documented user-side reproduction.

## Tolerance Rules

- Synthetic deterministic coefficient, diagnostic, and forecast baselines use
  `1e-8` unless a fixture-specific tolerance is registered.
- Published-result tolerances should be tied to table rounding or independent
  reproduction precision, not arbitrary implementation drift.
- Stochastic/bootstrap fixtures must use fixed seeds.
- Interval fixtures should state whether they validate pointwise intervals,
  simultaneous bands, or shape-only availability.
