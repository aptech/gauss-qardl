# pqorderRange

## Purpose

Selects scalar QARDL lag orders over restricted `p/q` bounds by information
criterion or GETS backward reduction.

## Format

```gauss
{ pst, qst } = pqorderRange(data, pstart, pend, qstart, qend, criterion);
{ pst, qst } = pqorderRange(data, pstart, pend, qstart, qend, "gets",
                            gets_pval);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pstart`, `pend` (*scalars*) - Minimum and maximum autoregressive lag orders.
- `qstart`, `qend` (*scalars*) - Minimum and maximum distributed-lag orders.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, `"hqc"`, or `"gets"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.

## Returns

- `pst` (*scalar*) - Selected autoregressive lag order.
- `qst` (*scalar*) - Selected distributed-lag order.

## Remarks

Set the start and end values equal to fix a lag order while searching the other
dimension. With `criterion = "gets"`, the search starts at `pend`/`qend` and
does not reduce below `pstart`/`qstart`.

## Examples

```gauss
{ pst, qst } = pqorderRange(data, 2, 8, 0, 4, "bic");
{ pg, qg } = pqorderRange(data, 2, 8, 0, 4, "gets", 0.1);
```

## Source

`icmean.src`

## See Also

[pqorder](pqorder.md), [pqorderGrid](pqorderGrid.md)
