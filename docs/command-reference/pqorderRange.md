# pqorderRange

## Purpose

Selects scalar QARDL lag orders over a restricted p/q search grid.

## Format

```gauss
{ pst, qst } = pqorderRange(data, pstart, pend, qstart, qend, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pstart`, `pend` (*scalars*) - Minimum and maximum autoregressive lag orders.
- `qstart`, `qend` (*scalars*) - Minimum and maximum distributed-lag orders.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, or `"hqc"`.

## Returns

- `pst` (*scalar*) - Selected autoregressive lag order.
- `qst` (*scalar*) - Selected distributed-lag order.

## Remarks

Set the start and end values equal to fix a lag order while searching the other
dimension.

## Examples

```gauss
{ pst, qst } = pqorderRange(data, 2, 8, 0, 4, "bic");
```

## Source

`icmean.src`

## See Also

[pqorder](pqorder.md), [pqorderGrid](pqorderGrid.md)
