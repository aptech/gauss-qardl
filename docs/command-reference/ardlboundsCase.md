# ardlboundsCase

## Purpose

Computes ARDL bounds tests for Pesaran-Shin-Smith deterministic Cases I-V.

## Format

```gauss
{ Fstat, tstat, cv, k, case_id } = ardlboundsCase(data, ppp, qqq, case_id);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `case_id` (*scalar*) - Deterministic case:
  - `1`: no intercept, no trend.
  - `2`: restricted intercept, no trend.
  - `3`: unrestricted intercept, no trend.
  - `4`: unrestricted intercept, restricted trend.
  - `5`: unrestricted intercept, unrestricted trend.

## Returns

- `Fstat` (*scalar*) - Bounds-test F-statistic.
- `tstat` (*scalar*) - t-statistic for the lagged dependent level.
- `cv` (*3x2 matrix*) - F critical-value bounds at 10%, 5%, and 1%.
- `k` (*scalar*) - Number of regressors.
- `case_id` (*scalar*) - Deterministic case used.

## Remarks

Bundled asymptotic PSS F critical values cover Cases I-V and `k = 0` through
`k = 10`. Use simulation critical-value APIs for finite samples or larger `k`.

## Examples

```gauss
{ Fstat, tstat, cv, k, case_id } = ardlboundsCase(data, 2, 1, 3);
call ardlboundsCase_print(Fstat, tstat, cv, k, case_id);
```

## Source

`ardlbounds.src`

## See Also

[ardlbounds](ardlbounds.md), [ardlboundsCaseCV](ardlboundsCaseCV.md),
[ardlboundsCaseSimCV](ardlboundsCaseSimCV.md)
