# ardlboundsCaseSim

## Purpose

Computes ARDL bounds tests for deterministic Cases I-V using simulated
finite-sample critical values.

## Format

```gauss
{ Fstat, tstat, cv, k, case_id } =
    ardlboundsCaseSim(data, ppp, qqq, case_id);
{ Fstat, tstat, cv, k, case_id } =
    ardlboundsCaseSim(data, ppp, qqq, case_id, reps, seed);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `case_id` (*scalar*) - Deterministic case, from `1` through `5`.
- `reps` (*scalar*) - Number of simulation replications. Default is `40000`.
- `seed` (*scalar*) - Random seed. Default is `0`.

## Returns

- `Fstat` - Bounds-test F-statistic.
- `tstat` - t-statistic for the lagged dependent level.
- `cv` - Simulated critical-value bounds.
- `k` - Number of regressors.
- `case_id` - Deterministic case used.

## Remarks

Simulation can be time-consuming. Use `ardlboundsCase` for bundled asymptotic
critical values.

## Examples

```gauss
{ Fstat, tstat, cv, k, case_id } =
    ardlboundsCaseSim(data, 2, 1, 3, 10000, 12345);
```

## Source

`ardlbounds.src`

## See Also

[ardlboundsCase](ardlboundsCase.md), [ardlboundsCaseSimCV](ardlboundsCaseSimCV.md)
