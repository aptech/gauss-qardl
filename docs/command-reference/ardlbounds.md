# ardlbounds

## Purpose

Computes the compatibility Pesaran-Shin-Smith ARDL bounds F-test for Case III:
unrestricted intercept and no deterministic trend.

## Format

```gauss
{ Fstat, cv } = ardlbounds(data, ppp, qqq);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.

## Returns

- `Fstat` (*scalar*) - Bounds-test F-statistic.
- `cv` (*3x2 matrix*) - Critical-value bounds at 10%, 5%, and 1%. Columns are
  I(0) lower and I(1) upper.

## Remarks

This procedure preserves the original Case III API. Use `ardlboundsCase` for
deterministic Cases I-V and the bounds t-statistic.

## Examples

```gauss
{ Fstat, cv } = ardlbounds(data, 2, 1);
call ardlbounds_print(Fstat, cv, cols(data)-1);
```

## Source

`ardlbounds.src`

## See Also

[ardlboundsCase](ardlboundsCase.md), [ardlboundsCaseCV](ardlboundsCaseCV.md)
