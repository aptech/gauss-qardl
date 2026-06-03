# ardlSparseGETS

## Purpose

Runs standalone sparse GETS reduction on the Case V ARDL unrestricted ECM.

## Format

```gauss
spOut = ardlSparseGETS(data, p, q);
spOut = ardlSparseGETS(data, p, q, formula, gets_pval, print_results);
```

## Parameters

- `data` (*matrix or dataframe*) - Matrix input is ordered `[y, x1, x2, ...]`.
- `p` (*scalar*) - AR lag order for the starting UECM.
- `q` (*scalar*) - Distributed-lag order for the starting UECM.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `gets_pval` (*scalar*) - P-value threshold for deleting eligible terms.
  Default is `0.05`.
- `print_results` (*scalar*) - If `1`, print the sparse GETS table. Default
  is `1`.

## Returns

`spOut` is an `ardlSparseGETSOut` structure with fields including:

- `term_labels` - Candidate UECM term labels in design-matrix order.
- `keep_cols` - Binary mask for retained terms.
- `dropped_cols` - Column indices dropped by sparse GETS.
- `bt`, `coef_cov`, `fitted`, `resid`, `sigma2` - Sparse Case V UECM fit.
- `deterministic_pv`, `case_ids`, `primary_case` - Deterministic-term
  screening output.

## Remarks

Sparse GETS protects the lagged level relation and prunes eligible
deterministic and short-run difference terms. `ardlAutoCase(..., gets_mode =
"sparse")` continues to use the same sparse machinery inside the automatic
case workflow.

## Examples

```gauss
spOut = ardlSparseGETS(data, 2, 2, "", 0.10);
print spOut.term_labels;
print spOut.keep_cols;
```

## Source

`qardl.src`

## See Also

[ardlAutoCase](ardlAutoCase.md), [ardlECM](ardlECM.md),
[nardlSparseGETS](nardlSparseGETS.md)
