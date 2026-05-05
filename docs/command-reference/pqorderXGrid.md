# pqorderXGrid

## Purpose

Returns the full per-regressor q-vector lag-search information-criterion table.

## Format

```gauss
ic_grid = pqorderXGrid(data);
ic_grid = pqorderXGrid(data, pend, qend, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pend` (*scalar*) - Maximum autoregressive lag order. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order for each regressor.
  Default is `8`.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, or `"hqc"`. Default is
  `"bic"`.

## Returns

`ic_grid` is a matrix with columns:

1. `p`
2. `q_1` through `q_k`
3. information-criterion value

## Remarks

Use this table to inspect heterogeneous lag-order candidates before estimating
with `qardlX` or `qardlECMX`.

## Examples

```gauss
ic_grid = pqorderXGrid(data, 4, 3, "bic");
```

## Source

`icmean.src`

## See Also

[pqorderX](pqorderX.md), [qardlX](qardlX.md)
