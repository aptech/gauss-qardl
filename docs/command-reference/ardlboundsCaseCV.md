# ardlboundsCaseCV

## Purpose

Returns ARDL bounds critical values for a selected deterministic case.

## Format

```gauss
cv = ardlboundsCaseCV(k0, case_id);
cv = ardlboundsCaseCV(k0, case_id, Tsim, reps, seed);
```

## Parameters

- `k0` (*scalar*) - Number of regressors.
- `case_id` (*scalar*) - Deterministic case, from `1` through `5`.
- `Tsim` (*scalar*) - Simulation sample length if simulation is requested.
  Default is `1000`.
- `reps` (*scalar*) - Number of simulation replications. If `0`, uses bundled
  asymptotic values where available. Default is `0`.
- `seed` (*scalar*) - Random seed for simulation. Default is `0`.

## Returns

`cv` is a `3x2` matrix. Rows are 10%, 5%, and 1%; columns are I(0) lower and
I(1) upper.

## Remarks

For bundled table lookup, use `reps = 0`. For finite-sample simulation, pass a
positive replication count or call `ardlboundsCaseSimCV`.

## Examples

```gauss
cv = ardlboundsCaseCV(2, 3);
cv_sim = ardlboundsCaseCV(2, 3, 200, 10000, 12345);
```

## Source

`ardlbounds.src`

## See Also

[ardlboundsCase](ardlboundsCase.md), [ardlboundsCaseSimCV](ardlboundsCaseSimCV.md)
