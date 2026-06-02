# ardlSelect

## Purpose

Selects lag orders for ARDL-family models using one standardized wrapper.

## Format

```gauss
sel = ardlSelect(data);
sel = ardlSelect(data, model, pend, qend, criterion);
sel = ardlSelect(data, "ardl", pend, qend, criterion, q_mode,
                 return_type, pstart, qstart, cs_lags, gets_pval);
sel = ardlSelect(data, "nardl", pend, qend, criterion);
sel = ardlSelect(panel, "csardl", pend, qend, criterion, cs_lags = 1);
```

## Parameters

- `data` (*matrix*) - Time-series matrix `[y, x1, ...]` for ARDL, QARDL, and
  NARDL selection, or balanced panel matrix `[unit_id, y, x1, ...]` for
  CS-ARDL selection.
- `model` (*string*) - `"ardl"` (default), `"qardl"`, `"nardl"`, or
  `"csardl"`.
- `pend` (*scalar*) - Maximum autoregressive lag order searched. Default is
  `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `criterion` (*string*) - `"bic"` (default), `"aic"`, `"hq"`, `"hqc"`, or
  `"gets"`.
- `q_mode` (*string*) - For ARDL/QARDL only, `"scalar"` for a common q order
  or `"vector"` for per-regressor q selection. Default is `"scalar"`.
- `return_type` (*string*) - `"best"` (default), `"grid"`, or `"both"`.
- `pstart` (*scalar*) - Minimum AR lag order searched for ARDL/QARDL
  selection. Default is `1`.
- `qstart` (*scalar*) - Minimum distributed-lag order searched for ARDL/QARDL
  selection. Default is `0`.
- `cs_lags` (*scalar*) - Cross-sectional-average lag order for CS-ARDL
  selection. Default is `0`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.
- `d`, `thresh1`, `thresh2` - Optional NARDL partial-sum reset threshold
  controls. Default `"inf"` gives ordinary cumulative positive and negative
  partial sums.

## Returns

`sel` is an `ardlSelectOut` structure with fields:

- `model_family` - `"ARDL"`, `"QARDL"`, `"NARDL"`, or `"CS-ARDL"`.
- `selection_criterion` - Criterion used for selection.
- `q_mode`, `return_type` - Selector options used.
- `pmax`, `qmax`, `pstart`, `qstart`, `cs_lags`, `gets_pval` - Search
  settings.
- `pst`, `qst` - Selected lag orders. For q-vector ARDL/QARDL selection,
  `qst` is `maxc(qvec)`.
- `qvec` - Per-regressor q vector. Scalar-q models store `qst` repeated for
  each regressor.
- `grid` - Information-criterion grid when requested and available.

## Remarks

`ardlSelect` is the recommended high-level selector when users want one API
across ARDL-family models. It delegates to model-specific selectors:

- ARDL/QARDL use `pqSelect`.
- NARDL uses `nardlOrder` and `nardlOrderGrid`.
- CS-ARDL uses `csardlOrder` and `csardlOrderGrid`.

The model-specific selectors remain available because their design matrices
are not redundant. NARDL selection evaluates positive/negative partial-sum
designs, while CS-ARDL selection evaluates pooled panel designs with
cross-sectional-average controls.

GETS selection returns the selected lag order but not an information-criterion
grid. Use `return_type = "best"` with `criterion = "gets"`.

## Examples

```gauss
library qardl;

// Standard ARDL/QARDL scalar lag selection.
sel = ardlSelect(data, "ardl", 8, 8, "bic");
arOut = ardl(data, sel.pst, sel.qst, "", 0);

// ARDL/QARDL per-regressor q-vector selection.
xsel = ardlSelect(data, "qardl", 4, 2, "bic", q_mode = "vector");
qaOut = qardlX(data, xsel.pst, xsel.qvec, tau);

// Request an IC grid as well as the selected lag order.
grid_sel = ardlSelect(data, "ardl", 4, 4, "aic", return_type = "grid");
print grid_sel.grid;

// NARDL selection.
nsel = ardlSelect(data, "nardl", 4, 4, "bic");
naOut = nardl(data, nsel.pst, nsel.qst, "", 0);

// CS-ARDL selection.
csel = ardlSelect(panel, "csardl", 4, 4, "bic", cs_lags = 1);
csaOut = csardl(panel, csel.pst, csel.qst, csel.cs_lags, "", 0);
```

## Source

`ardl_select.src`

## See Also

[pqSelect](pqSelect.md), [nardlOrder](nardlOrder.md),
[nardlOrderGrid](nardlOrderGrid.md), [csardlOrder](csardlOrder.md),
[csardlOrderGrid](csardlOrderGrid.md)
