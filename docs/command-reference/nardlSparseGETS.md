# nardlSparseGETS

## Purpose

Runs standalone sparse GETS reduction on the Case V NARDL unrestricted ECM.

## Format

```gauss
spOut = nardlSparseGETS(data, p, q_decomp);
spOut = nardlSparseGETS(data, p, q_decomp, formula, decomp_vars,
                        control_vars, q_control, gets_pval, d,
                        thresh1, thresh2, print_results);
```

## Parameters

- `data` (*matrix or dataframe*) - Matrix input is ordered `[y, x1, x2, ...]`.
- `p` (*scalar*) - AR lag order for the starting UECM.
- `q_decomp` (*scalar*) - Distributed-lag order for decomposed variables.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `decomp_vars`, `control_vars`, `q_control` - Same decomposition and
  linear-control controls as `nardl`.
- `gets_pval` (*scalar*) - P-value threshold for deleting eligible terms.
  Default is `0.10`.
- `d`, `thresh1`, `thresh2` - Partial-sum reset threshold controls shared
  with `nardl`.
- `print_results` (*scalar*) - If `1`, print the sparse GETS table. Default
  is `1`.

## Returns

`spOut` is an `ardlSparseGETSOut` structure with fields including:

- `term_labels` - Candidate NARDL UECM term labels in design-matrix order.
- `keep_cols` - Binary mask for retained terms.
- `dropped_cols` - Column indices dropped by sparse GETS.
- `decomp_vars`, `control_vars`, `decomp_thresholds` - Resolved NARDL
  decomposition metadata.
- `bt`, `coef_cov`, `fitted`, `resid`, `sigma2` - Sparse Case V UECM fit.
- `deterministic_pv`, `case_ids`, `primary_case` - Deterministic-term
  screening output.

## Remarks

Sparse GETS protects the lagged level relation and prunes eligible
deterministic and short-run difference terms. `nardlAutoCase(..., gets_mode =
"sparse")` continues to use the same sparse machinery inside the automatic
case workflow.

## Examples

```gauss
spOut = nardlSparseGETS(data, 2, 2, "", "x1", "x2", 1, 0.10);
print spOut.term_labels;
print spOut.keep_cols;
```

## Source

`nardl.src`

## See Also

[nardlAutoCase](nardlAutoCase.md), [nardlECM](nardlECM.md),
[ardlSparseGETS](ardlSparseGETS.md)
