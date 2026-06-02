# nardlOrderGrid

## Purpose

Returns the full NARDL information-criterion lag-search table.

## Format

```gauss
grid = nardlOrderGrid(data);
grid = nardlOrderGrid(data, pend, qend, criterion);
grid = nardlOrderGrid(data, pend, qend, criterion, d, thresh1, thresh2);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Matrix ordered `[y, x1, x2, ...]`.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, or `"hqc"`.
- `d`, `thresh1`, `thresh2` - Optional NARDL partial-sum reset threshold
  controls. Default `"inf"` gives ordinary cumulative positive and negative
  partial sums.

## Returns

`grid`, a matrix with columns `[p, q, ic]`.

## Remarks

The row with the smallest third column is the lag order returned by
`nardlOrder`. Non-default thresholds are applied before each candidate
information criterion is evaluated.

## Examples

```gauss
grid = nardlOrderGrid(data, 4, 4, "aic");
grid_thresh = nardlOrderGrid(data, 4, 4, "bic", 0);
```

## Source

`nardl.src`

## See Also

[ardlSelect](ardlSelect.md), [nardlOrder](nardlOrder.md),
[nardlICMean](nardlICMean.md)
