# nardlOrderGrid

## Purpose

Returns the full NARDL information-criterion lag-search table.

## Format

```gauss
grid = nardlOrderGrid(data);
grid = nardlOrderGrid(data, pend, qend, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Matrix ordered `[y, x1, x2, ...]`.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, or `"hqc"`.

## Returns

`grid`, a matrix with columns `[p, q, ic]`.

## Remarks

The row with the smallest third column is the lag order returned by
`nardlOrder`.

## Examples

```gauss
grid = nardlOrderGrid(data, 4, 4, "aic");
```

## Source

`nardl.src`

## See Also

[nardlOrder](nardlOrder.md), [nardlICMean](nardlICMean.md)
