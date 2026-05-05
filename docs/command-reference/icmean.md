# icmean

## Purpose

Computes an information criterion for a specified QARDL lag order.

## Format

```gauss
ic = icmean(data, ppp, qqq);
ic = icmean(data, ppp, qqq, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, or `"hqc"`. Default is
  `"bic"`.

## Returns

`ic` (*scalar*) - Information-criterion value.

## Remarks

Most users should call `pqorder`, `pqorderRange`, or `qardlFull` instead of
calling `icmean` directly.

## Examples

```gauss
bic_val = icmean(data, 2, 1, "bic");
```

## Source

`icmean.src`

## See Also

[pqorder](pqorder.md), [pqorderGrid](pqorderGrid.md)
