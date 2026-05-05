# pqorderGrid

## Purpose

Returns the full scalar p/q lag-search information-criterion table.

## Format

```gauss
ic_grid = pqorderGrid(data);
ic_grid = pqorderGrid(data, pend, qend, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pend` (*scalar*) - Maximum autoregressive lag order. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order. Default is `8`.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, or `"hqc"`. Default is
  `"bic"`.

## Returns

`ic_grid` is a matrix with columns:

1. `p`
2. `q`
3. information-criterion value

## Remarks

Use this procedure to audit the lag-selection surface before choosing a final
model.

## Examples

```gauss
ic_grid = pqorderGrid(data, 8, 8, "hq");
```

## Source

`icmean.src`

## See Also

[pqorder](pqorder.md), [pqorderRange](pqorderRange.md)
