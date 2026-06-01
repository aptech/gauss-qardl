# nardlAutoCase

## Purpose

Runs a NARDL auto-case workflow using hierarchical GETS lag selection,
NARDL partial-sum decomposition, and Pesaran-Shin-Smith deterministic-case
inference.

## Format

```gauss
nacOut = nardlAutoCase(data);
nacOut = nardlAutoCase(data, pend, qend, formula, verbose,
                       decomp_vars, control_vars, q_control,
                       gets_pval, d, thresh1, thresh2);
```

## Parameters

- `data` (*Tx(1+k) matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum decomposed-variable distributed lag searched.
  Default is `8`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `verbose` (*scalar*) - If `1`, print selected lags, deterministic-term
  p-values, admissible cases, and compact bounds rows.
- `decomp_vars`, `control_vars`, `q_control` - Same decomposition and
  linear-control controls as `nardl`.
- `gets_pval` (*scalar*) - Wald p-value threshold for hierarchical GETS lag
  reduction and deterministic-term case inference. Default is `0.1`.
- `d`, `thresh1`, `thresh2` - Partial-sum reset threshold controls shared
  with `nardl`.

## Returns

`nacOut` is a `nardlAutoCaseOut` structure containing:

- `pst`, `qst`, `q_control` - selected and fixed lag orders.
- `case_ids` - admissible PSS case set inferred from the Case V NARDL UECM.
- `primary_case` - the unrestricted member of the admissible case set used for
  the nested NARDL UECM fit.
- `deterministic_coef`, `deterministic_pv` - Case V intercept and trend
  coefficients and p-values.
- `bounds_table` - rows
  `[case_id, Fstat, tstat, q_restrict, cv10_I0, cv10_I1, cv5_I0, cv5_I1,
  cv1_I0, cv1_I1]`, using `k = 2*ndecomp + ncontrol`.
- `decomp_thresholds` - resolved reset thresholds for decomposed variables.
- `.na`, `.ecm` - nested levels NARDL and unrestricted NARDL-ECM outputs.

## Remarks

The auto-case rule mirrors the R `ardl.nardl` convention: a Case V UECM is
estimated, then the constant and trend p-values imply Case I, Cases II/III, or
Cases IV/V. PSS has no trend-only case; if the trend survives while the
intercept does not, GAUSS promotes the admissible set to Cases IV/V.

GETS in this GAUSS workflow is hierarchical p/q lag-block reduction, not sparse
term deletion.

## Examples

```gauss
library qardl;

nacOut = nardlAutoCase(df, 4, 4, "y ~ x1 + x2", 0,
                       "x1", "x2", 1, 0.1, 0);
print nacOut.case_ids;
print nacOut.bounds_table;
printNARDLECM(nacOut.ecm);
```

## Source

`nardl.src`

## See Also

[nardlFull](nardlFull.md), [nardlECM](nardlECM.md), [nardl](nardl.md)
