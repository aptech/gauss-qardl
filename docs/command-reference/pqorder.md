# pqorder

## Purpose

Selects scalar QARDL lag orders `p` and `q` by information criterion.

## Format

```gauss
{ pst, qst } = pqorder(data);
{ pst, qst } = pqorder(data, pend, qend, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pend` (*scalar*) - Maximum autoregressive lag order. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order. Default is `8`.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, or `"hqc"`. Default is
  `"bic"`.

## Returns

- `pst` (*scalar*) - Selected autoregressive lag order.
- `qst` (*scalar*) - Selected distributed-lag order.

## Remarks

The scalar search applies the same distributed-lag order to every regressor.
Use `pqorderX` for per-regressor q-vector selection.

## Examples

```gauss
{ pst, qst } = pqorder(data, 8, 8, "bic");
qaOut = qardl(data, pst, qst);
```

## Source

`icmean.src`

## See Also

[pqorderRange](pqorderRange.md), [pqorderGrid](pqorderGrid.md),
[pqorderX](pqorderX.md), [qardlFull](qardlFull.md)
