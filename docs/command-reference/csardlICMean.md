# csardlICMean

## Purpose

Computes an information criterion for a specified CS-ARDL lag order.

## Format

```gauss
ic = csardlICMean(data, ppp, qqq);
ic = csardlICMean(data, ppp, qqq, cs_lags, criterion);
```

## Parameters

- `data` (*matrix*) - Balanced panel matrix in `[unit_id, y, x1, ...]`
  order.
- `ppp` (*scalar*) - AR lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `cs_lags` (*scalar*) - Cross-sectional-average lag order. Default is `0`.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, or `"hqc"`.

## Returns

`ic`, a scalar information-criterion value.

## Remarks

Lower values are preferred. The criterion is computed from the pooled
CS-ARDL levels equation.

## Examples

```gauss
ic = csardlICMean(panel, 2, 1, 1, "aic");
```

## Source

`csardl.src`

## See Also

[csardlOrder](csardlOrder.md), [csardlOrderGrid](csardlOrderGrid.md)
