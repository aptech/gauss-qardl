# csardlOrderGrid

## Purpose

Returns the full CS-ARDL information-criterion lag-search table.

## Format

```gauss
grid = csardlOrderGrid(data);
grid = csardlOrderGrid(data, pend, qend, cs_lags, criterion);
```

## Parameters

- `data` (*matrix*) - Balanced panel matrix in `[unit_id, y, x1, ...]`
  order.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `cs_lags` (*scalar*) - Cross-sectional-average lag order. Default is `0`.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, or `"hqc"`.

## Returns

`grid`, a matrix with columns `[p, q, ic]`.

## Remarks

The row with the smallest third column is the lag order returned by
`csardlOrder`.

## Examples

```gauss
grid = csardlOrderGrid(panel, 4, 4, 1, "hq");
```

## Source

`csardl.src`

## See Also

[csardlOrder](csardlOrder.md), [csardlICMean](csardlICMean.md)
