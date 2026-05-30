# pqorder

## Purpose

Selects scalar QARDL lag orders `p` and `q` by information criterion or GETS
backward reduction.

## Format

```gauss
{ pst, qst } = pqorder(data);
{ pst, qst } = pqorder(data, pend, qend, criterion);
{ pst, qst } = pqorder(data, pend, qend, "gets", gets_pval);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pend` (*scalar*) - Maximum autoregressive lag order. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order. Default is `8`.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, `"hqc"`, or `"gets"`.
  Default is `"bic"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.

## Returns

- `pst` (*scalar*) - Selected autoregressive lag order.
- `qst` (*scalar*) - Selected distributed-lag order.

## Remarks

The scalar search applies the same distributed-lag order to every regressor.
GETS starts from `pend`/`qend` and removes highest-order lag blocks while their
Wald p-values exceed `gets_pval`, preserving a contiguous `p/q` lag structure.
Use `pqorderX` for per-regressor q-vector selection.

## Examples

```gauss
{ pst, qst } = pqorder(data, 8, 8, "bic");
{ pg, qg } = pqorder(data, 8, 8, "gets", 0.1);
qaOut = qardl(data, pst, qst);
```

## Source

`icmean.src`

## See Also

[pqorderRange](pqorderRange.md), [pqorderGrid](pqorderGrid.md),
[pqorderX](pqorderX.md), [qardlFull](qardlFull.md)
