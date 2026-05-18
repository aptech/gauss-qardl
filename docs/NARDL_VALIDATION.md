# NARDL Validation

This note tracks validation for nonlinear ARDL workflows.

## Active Deterministic Targets

`synthetic-nardl-decomposition` validates positive and negative partial-sum
construction using a small known-answer dataset.

Stored outputs:

- `tests/fixtures/expected/synthetic/decompositions/nardl_partial_sums_pos.csv`
- `tests/fixtures/expected/synthetic/decompositions/nardl_partial_sums_neg.csv`
- `tests/fixtures/expected/synthetic/decompositions/nardl_diff_pos.csv`
- `tests/fixtures/expected/synthetic/decompositions/nardl_diff_neg.csv`

`synthetic-nardl-seeded` validates seeded NARDL coefficient, forecast, bounds,
and asymmetry outputs.

Stored outputs:

- `tests/fixtures/expected/synthetic/coefficients/nardl_seeded_bigbt.csv`
- `tests/fixtures/expected/synthetic/coefficients/nardl_seeded_theta_pos.csv`
- `tests/fixtures/expected/synthetic/coefficients/nardl_seeded_theta_neg.csv`
- `tests/fixtures/expected/synthetic/coefficients/nardl_seeded_phi.csv`
- `tests/fixtures/expected/synthetic/diagnostics/nardl_asymmetry.csv`
- `tests/fixtures/expected/synthetic/diagnostics/nardl_short_run_asymmetry.csv`
- `tests/fixtures/expected/synthetic/diagnostics/nardl_bounds_fstat.csv`

`synthetic-nardl-dynamics` validates `nardlDynamicMultipliers` at horizon 6.

Stored outputs:

- `tests/fixtures/expected/synthetic/multipliers/nardl_dynamic_pos_h6.csv`
- `tests/fixtures/expected/synthetic/multipliers/nardl_dynamic_neg_h6.csv`
- `tests/fixtures/expected/synthetic/multipliers/nardl_dynamic_asym_h6.csv`

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_validation_benchmarks.ps1
```

## Pending Published Validation

The Shin, Yu, and Greenwood-Nimmo (2014) style published validation target
remains pending until exact datasets, transformations, sample windows, lag
orders, deterministic terms, and dynamic multiplier settings are available.

Before marking the published NARDL replication complete, add:

1. raw data source and redistribution status;
2. positive and negative partial-sum construction notes;
3. lag order or selection rule;
4. long-run asymmetric coefficient targets;
5. dynamic multiplier targets;
6. bounds-test targets and deterministic case;
7. tolerances tied to published rounding or independent reproduction precision.

## Interpretation Notes

NARDL decomposes each regressor into cumulative positive and negative changes.
The positive and negative long-run coefficients are reported separately as
`beta_pos` and `beta_neg`; long-run asymmetry tests compare these paths for each
original regressor.

`nardlDynamicMultipliers` reports the horizon-by-horizon adjustment implied by
the estimated levels equation. `pos` and `neg` are responses to one-unit changes
in the positive and negative partial-sum variables, and `asymmetry` is their
difference.

