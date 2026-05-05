# pqorderRangeGrid

## Purpose

Returns the full scalar p/q information-criterion table over a restricted lag
search grid.

## Format

```gauss
ic_grid = pqorderRangeGrid(data, pstart, pend, qstart, qend, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pstart`, `pend` (*scalars*) - Minimum and maximum autoregressive lag orders.
- `qstart`, `qend` (*scalars*) - Minimum and maximum distributed-lag orders.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, or `"hqc"`.

## Returns

`ic_grid` is a matrix with columns:

1. `p`
2. `q`
3. information-criterion value

## Remarks

Use this procedure to inspect a restricted lag-search surface. Set start and
end values equal to include fixed lag orders in the table.

## Examples

```gauss
ic_grid = pqorderRangeGrid(data, 2, 8, 0, 4, "bic");
```

## Source

`icmean.src`

## See Also

[pqorderRange](pqorderRange.md), [pqorderGrid](pqorderGrid.md)
