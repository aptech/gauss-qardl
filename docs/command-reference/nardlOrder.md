# nardlOrder

## Purpose

Selects NARDL `p` and `q` lag orders by information criterion or GETS
backward reduction.

## Format

```gauss
{ pst, qst } = nardlOrder(data);
{ pst, qst } = nardlOrder(data, pend, qend, criterion);
{ pst, qst } = nardlOrder(data, pend, qend, "gets", gets_pval);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Matrix ordered `[y, x1, x2, ...]`.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, `"hqc"`, or
  `"gets"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.

## Returns

`pst` and `qst`, the selected AR and distributed-lag orders.

## Remarks

`nardlOrder` uses the compatibility NARDL specification that decomposes every
RHS regressor. Use `nardlFull` for formula support and explicit
decomposed-variable/control-variable specifications.
GETS reduces highest-order AR and decomposed-variable distributed-lag blocks
while preserving contiguous `p/q` orders.

## Examples

```gauss
{ pst, qst } = nardlOrder(data, 4, 4, "bic");
{ pg, qg } = nardlOrder(data, 4, 4, "gets", 0.1);
naOut = nardl(data, pst, qst, "", 0);
```

## Source

`nardl.src`

## See Also

[nardlOrderGrid](nardlOrderGrid.md), [nardlICMean](nardlICMean.md),
[nardlFull](nardlFull.md)
