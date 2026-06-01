# nardlICMean

## Purpose

Computes an information criterion for a specified NARDL lag order.

## Format

```gauss
ic = nardlICMean(data, ppp, qqq);
ic = nardlICMean(data, ppp, qqq, criterion);
ic = nardlICMean(data, ppp, qqq, criterion, d, thresh1, thresh2);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Matrix ordered `[y, x1, x2, ...]`.
- `ppp` (*scalar*) - AR lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, or `"hqc"`.
- `d`, `thresh1`, `thresh2` - Optional NARDL partial-sum reset threshold
  controls. Default `"inf"` gives ordinary cumulative positive and negative
  partial sums.

## Returns

`ic`, a scalar information-criterion value.

## Remarks

Lower values are preferred. This helper uses the compatibility NARDL
specification where every RHS regressor is decomposed.
Non-default thresholds are applied before the candidate design matrix is
estimated.

## Examples

```gauss
ic = nardlICMean(data, 2, 1, "hq");
ic_thresh = nardlICMean(data, 2, 1, "bic", 0);
```

## Source

`nardl.src`

## See Also

[nardlOrder](nardlOrder.md), [nardlOrderGrid](nardlOrderGrid.md)
