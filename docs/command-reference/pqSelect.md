# pqSelect

## Purpose

Selects ARDL/QARDL lag orders or returns lag-search grids.

## Format

```gauss
best = pqSelect(data);
best = pqSelect(data, pend, qend);
best = pqSelect(data, pend, qend, pstart, qstart, criterion);
grid = pqSelect(data, return_type = "grid");
xbest = pqSelect(data, q_mode = "vector");
xgrid = pqSelect(data, q_mode = "vector", return_type = "grid");
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `pend` (*scalar*) - Maximum autoregressive lag order searched. Default is
  `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `pstart` (*scalar*) - Minimum autoregressive lag order searched. Default is
  `1`.
- `qstart` (*scalar*) - Minimum distributed-lag order searched. Default is
  `0`.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, `"hqc"`, or `"gets"`.
  Default is `"bic"`.
- `q_mode` (*string*) - `"scalar"` for a common q order across regressors, or
  `"vector"` for a separate q order for each regressor. Default is
  `"scalar"`.
- `return_type` (*string*) - `"best"` for the selected lag order or `"grid"` for
  the full information-criterion search table. Default is `"best"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.

## Returns

`pqSelect` returns one matrix whose columns depend on `q_mode` and
`return_type`:

- `q_mode = "scalar"` and `return_type = "best"` returns `[p, q]`.
- `q_mode = "scalar"` and `return_type = "grid"` returns `[p, q, IC]`.
- `q_mode = "vector"` and `return_type = "best"` returns `[p, q1, ..., qk]`.
- `q_mode = "vector"` and `return_type = "grid"` returns
  `[p, q1, ..., qk, IC]`.

## Remarks

`pqSelect` is the recommended lag-selection entry point for ARDL and QARDL
workflows. It covers scalar q selection, restricted lag ranges, full
information-criterion grids, and per-regressor q-vector selection.

GETS selection is available for scalar q best-order selection only. Grid
output and q-vector searches use information criteria because GETS does not
produce an information-criterion search table.

The legacy `pqorder`, `pqorderRange`, `pqorderGrid`, `pqorderRangeGrid`,
`pqorderX`, and `pqorderXGrid` procedures remain callable for backward
compatibility, but `pqSelect` is the documented user-facing API.

## Examples

```gauss
library qardl;

data = loadd("qardl_data.dat");

// Scalar q selection.
best = pqSelect(data, 8, 8, criterion = "bic");
pst = best[1, 1];
qst = best[1, 2];

// Restricted lag range.
range_best = pqSelect(data, 8, 4, pstart = 2, qstart = 1,
                      criterion = "aic");

// Full scalar p/q search grid.
ic_grid = pqSelect(data, 8, 8, return_type = "grid");

// GETS selection from the maximum scalar lag order.
gets_best = pqSelect(data, 8, 8, criterion = "gets", gets_pval = 0.1);

// Per-regressor q-vector selection.
xbest = pqSelect(data, 4, 2, q_mode = "vector");
pst_x = xbest[1, 1];
qvec_x = xbest[1, 2:cols(xbest)]';
```

## Source

`icmean.src`

## See Also

[ardlSelect](ardlSelect.md), [icmean](icmean.md), [qardlFull](qardlFull.md),
[ardlFull](ardlFull.md), [qardlX](qardlX.md), [qardlECMX](qardlECMX.md)
