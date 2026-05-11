# Benchmarking Notes

This note tracks lightweight benchmark entry points for the source tree.
Benchmarks are separate from the release-gate smoke tests so they can grow
without slowing every edit-check cycle.

## New Model Families

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
replications. TODO: add paper-specific benchmark scripts when exact datasets,
transformations, sample windows, and lag specifications are available for
redistribution or documented user-side reproduction.
