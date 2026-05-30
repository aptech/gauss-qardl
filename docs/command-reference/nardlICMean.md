# nardlICMean

## Purpose

Computes an information criterion for a specified NARDL lag order.

## Format

```gauss
ic = nardlICMean(data, ppp, qqq);
ic = nardlICMean(data, ppp, qqq, criterion);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Matrix ordered `[y, x1, x2, ...]`.
- `ppp` (*scalar*) - AR lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, or `"hqc"`.

## Returns

`ic`, a scalar information-criterion value.

## Remarks

Lower values are preferred. This helper uses the compatibility NARDL
specification where every RHS regressor is decomposed.

## Examples

```gauss
ic = nardlICMean(data, 2, 1, "hq");
```

## Source

`nardl.src`

## See Also

[nardlOrder](nardlOrder.md), [nardlOrderGrid](nardlOrderGrid.md)
