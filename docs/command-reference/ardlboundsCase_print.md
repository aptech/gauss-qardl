# ardlboundsCase_print

## Purpose

Prints formatted ARDL bounds-test output for deterministic Cases I-V.

## Format

```gauss
ardlboundsCase_print(Fstat, tstat, cv, k, case_id);
```

## Parameters

- `Fstat` (*scalar*) - Bounds-test F-statistic.
- `tstat` (*scalar*) - Bounds t-statistic.
- `cv` (*3x2 matrix*) - Critical-value bounds.
- `k` (*scalar*) - Number of regressors.
- `case_id` (*scalar*) - Deterministic case.

## Returns

Nothing. Results are printed to the GAUSS output window.

## Remarks

Use after `ardlboundsCase` or `ardlboundsCaseSim`.

## Examples

```gauss
{ Fstat, tstat, cv, k, case_id } = ardlboundsCase(data, 2, 1, 3);
call ardlboundsCase_print(Fstat, tstat, cv, k, case_id);
```

## Source

`ardlbounds.src`

## See Also

[ardlboundsCase](ardlboundsCase.md), [ardlboundsCaseSim](ardlboundsCaseSim.md)
