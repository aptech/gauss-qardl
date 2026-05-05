# ardlbounds_print

## Purpose

Prints formatted compatibility Case III ARDL bounds-test output.

## Format

```gauss
ardlbounds_print(Fstat, cv, k);
```

## Parameters

- `Fstat` (*scalar*) - Bounds-test F-statistic.
- `cv` (*3x2 matrix*) - Critical-value bounds.
- `k` (*scalar*) - Number of regressors.

## Returns

Nothing. Results are printed to the GAUSS output window.

## Remarks

Use after `ardlbounds`.

## Examples

```gauss
{ Fstat, cv } = ardlbounds(data, 2, 1);
call ardlbounds_print(Fstat, cv, cols(data)-1);
```

## Source

`ardlbounds.src`

## See Also

[ardlbounds](ardlbounds.md)
