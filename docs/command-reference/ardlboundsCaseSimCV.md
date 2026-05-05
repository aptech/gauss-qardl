# ardlboundsCaseSimCV

## Purpose

Simulates finite-sample ARDL bounds critical values for deterministic Cases I-V.

## Format

```gauss
cv = ardlboundsCaseSimCV(k0, case_id);
cv = ardlboundsCaseSimCV(k0, case_id, Tsim, reps, seed);
```

## Parameters

- `k0` (*scalar*) - Number of regressors.
- `case_id` (*scalar*) - Deterministic case, from `1` through `5`.
- `Tsim` (*scalar*) - Simulation sample length. Default is `1000`.
- `reps` (*scalar*) - Number of simulation replications. Default is `40000`.
- `seed` (*scalar*) - Random seed. Default is `0`.

## Returns

`cv` is a `3x2` matrix. Rows are 10%, 5%, and 1%; columns are I(0) lower and
I(1) upper.

## Remarks

Simulation can be time-consuming. Use bundled values through
`ardlboundsCaseCV(..., reps = 0)` when asymptotic table lookup is sufficient.

## Examples

```gauss
cv = ardlboundsCaseSimCV(2, 3, 200, 10000, 12345);
```

## Source

`ardlbounds.src`

## See Also

[ardlboundsCaseCV](ardlboundsCaseCV.md), [ardlboundsCase](ardlboundsCase.md)
