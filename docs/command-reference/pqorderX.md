# pqorderX

## Purpose

Selects an autoregressive lag order and a per-regressor distributed-lag vector.

## Format

```gauss
{ pst, qvec } = pqorderX(data);
{ pst, qvec } = pqorderX(data, pend, qend, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pend` (*scalar*) - Maximum autoregressive lag order. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order for each regressor.
  Default is `8`.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, or `"hqc"`. Default is
  `"bic"`.

## Returns

- `pst` (*scalar*) - Selected autoregressive lag order.
- `qvec` (*kx1 vector*) - Selected distributed-lag order for each regressor.

## Remarks

The grid size grows quickly as the number of regressors increases because it
searches combinations of per-regressor lag orders.

## Examples

```gauss
{ pst, qvec } = pqorderX(data, 4, 3, "bic");
qaOut = qardlX(data, pst, qvec);
```

## Source

`icmean.src`

## See Also

[qardlX](qardlX.md), [qardlECMX](qardlECMX.md), [pqorderXGrid](pqorderXGrid.md)
