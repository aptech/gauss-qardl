# ardlAutoCase

## Purpose

Runs an ARDL auto-case workflow using GETS lag selection and
Pesaran-Shin-Smith deterministic-case inference.

## Format

```gauss
acOut = ardlAutoCase(data);
acOut = ardlAutoCase(data, pend, qend, formula, verbose, gets_pval);
acOut = ardlAutoCase(data, pend, qend, formula, verbose, gets_pval,
                     gets_mode);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `verbose` (*scalar*) - If `1`, print selected lags, deterministic-term
  p-values, admissible cases, and compact bounds rows.
- `gets_pval` (*scalar*) - Wald p-value threshold for hierarchical GETS lag
  reduction and deterministic-term case inference. Default is `0.05`.
- `gets_mode` (*string*) - GETS mode. `"hierarchical"` (default) reduces
  scalar `p/q` lag blocks. `"sparse"` starts from the Case V UECM at
  `pend/qend` and deletes individual non-level terms whose p-values exceed
  `gets_pval`, while retaining the lagged level relation for bounds
  consistency.

## Returns

`acOut` is an `ardlAutoCaseOut` structure containing:

- `pst`, `qst` - GETS-selected scalar lag orders. In sparse mode these are
  the maximum `pend/qend` orders used to build the starting UECM.
- `gets_mode` - `"hierarchical"` or `"sparse"`.
- `case_ids` - admissible PSS case set inferred from the Case V UECM.
- `primary_case` - the unrestricted member of the admissible case set used for
  the nested UECM fit.
- `deterministic_coef`, `deterministic_pv` - Case V intercept and trend
  coefficients and p-values.
- `bounds_table` - rows
  `[case_id, Fstat, tstat, q_restrict, cv10_I0, cv10_I1, cv5_I0, cv5_I1,
  cv1_I0, cv1_I1]`.
- `sparse_keep_cols`, `sparse_bt`, `sparse_coef_cov`, `sparse_fitted`,
  `sparse_resid`, `sparse_sigma2` - sparse Case V UECM selection results when
  `gets_mode = "sparse"`; empty otherwise.
- `.ar`, `.ecm` - nested levels ARDL and unrestricted ARDL-ECM outputs.

## Remarks

The auto-case rule mirrors the R `ardl.nardl` convention: a Case V UECM is
estimated, then the constant and trend p-values imply Case I, Cases II/III, or
Cases IV/V. PSS has no trend-only case; if the trend survives while the
intercept does not, GAUSS promotes the admissible set to Cases IV/V.

The default GETS workflow is hierarchical `p/q` lag-block reduction. Set
`gets_mode = "sparse"` for R-style term pruning in the Case V UECM. Sparse
mode stores the pruned Case V UECM fit separately and keeps `.ecm` as the
primary-case dense UECM object for compatibility with existing ARDL ECM output
fields.

## Examples

```gauss
library qardl;

acOut = ardlAutoCase(df, 4, 4, "y ~ x1 + x2", 0, 0.05);
sparseOut = ardlAutoCase(df, 4, 4, "y ~ x1 + x2", 0, 0.05, "sparse");
print acOut.case_ids;
print acOut.bounds_table;
printARDLECM(acOut.ecm);
```

## Source

`qardl.src`

## See Also

[ardlFull](ardlFull.md), [ardlECM](ardlECM.md), [ardlboundsCase](ardlboundsCase.md)
