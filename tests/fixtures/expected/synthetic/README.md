# Synthetic Expected Outputs

These files are deterministic source-tree validation baselines. They are not
published-result replications.

The synthetic fixture categories are:

- `coefficients/`
- `decompositions/`
- `diagnostics/`
- `forecasts/`
- `intervals/`
- `multipliers/`

The active validation runner is:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1
```

TODO: Add interval expected-output files after forecast or bootstrap interval
policies are finalized for each model family.
