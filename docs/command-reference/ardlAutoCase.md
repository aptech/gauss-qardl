# ardlAutoCase

## Purpose

Runs an ARDL auto-case workflow using hierarchical GETS lag selection and
Pesaran-Shin-Smith deterministic-case inference.

## Format

```gauss
acOut = ardlAutoCase(data);
acOut = ardlAutoCase(data, pend, qend, formula, verbose, gets_pval);
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

## Returns

`acOut` is an `ardlAutoCaseOut` structure containing:

- `pst`, `qst` - GETS-selected scalar lag orders.
- `case_ids` - admissible PSS case set inferred from the Case V UECM.
- `primary_case` - the unrestricted member of the admissible case set used for
  the nested UECM fit.
- `deterministic_coef`, `deterministic_pv` - Case V intercept and trend
  coefficients and p-values.
- `bounds_table` - rows
  `[case_id, Fstat, tstat, q_restrict, cv10_I0, cv10_I1, cv5_I0, cv5_I1,
  cv1_I0, cv1_I1]`.
- `.ar`, `.ecm` - nested levels ARDL and unrestricted ARDL-ECM outputs.

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

acOut = ardlAutoCase(df, 4, 4, "y ~ x1 + x2", 0, 0.05);
print acOut.case_ids;
print acOut.bounds_table;
printARDLECM(acOut.ecm);
```

## Source

`qardl.src`

## See Also

[ardlFull](ardlFull.md), [ardlECM](ardlECM.md), [ardlboundsCase](ardlboundsCase.md)
