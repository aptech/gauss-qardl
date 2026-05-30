# csardlOrder

## Purpose

Selects CS-ARDL `p` and `q` lag orders by information criterion or GETS
backward reduction.

## Format

```gauss
{ pst, qst } = csardlOrder(data);
{ pst, qst } = csardlOrder(data, pend, qend, cs_lags, criterion);
{ pst, qst } = csardlOrder(data, pend, qend, cs_lags, "gets", gets_pval);
```

## Parameters

- `data` (*matrix*) - Balanced panel matrix in `[unit_id, y, x1, ...]`
  order.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `cs_lags` (*scalar*) - Cross-sectional-average lag order. Default is `0`.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, `"hqc"`, or
  `"gets"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.

## Returns

`pst` and `qst`, the selected AR and distributed-lag orders.

## Remarks

For dataframe formulas, use `applyCSARDLFormula` first or call `csardlFull`,
which applies the formula and panel sorting internally.
GETS reduces highest-order AR and distributed-lag blocks while preserving
contiguous `p/q` orders.

## Examples

```gauss
{ pst, qst } = csardlOrder(panel, 4, 4, 1, "bic");
{ pg, qg } = csardlOrder(panel, 4, 4, 1, "gets", 0.1);
csaOut = csardl(panel, pst, qst, 1, "", 0);
```

## Source

`csardl.src`

## See Also

[csardlOrderGrid](csardlOrderGrid.md), [csardlICMean](csardlICMean.md),
[csardlFull](csardlFull.md)
