# nardlFull

## Purpose

Runs the integrated NARDL workflow: lag selection, levels estimation, and ECM
estimation.

## Format

```gauss
nfOut = nardlFull(data);
nfOut = nardlFull(data, pend, qend, formula, verbose, criterion,
                  decomp_vars, control_vars, q_control, ecm_type, gets_pval,
                  case_id, d, thresh1, thresh2);
```

## Parameters

- `data` (*matrix or dataframe*) - Matrix input is ordered
  `[y, x1, x2, ...]`.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum decomposed-variable distributed lag searched.
  Default is `8`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `verbose` (*scalar*) - If `1`, print selected lags and estimator output.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, `"hqc"`, or `"gets"`.
- `decomp_vars`, `control_vars`, `q_control` - Same model-specification
  controls as `nardl`.
- `ecm_type` (*string*) - ECM type passed to `nardlECM`; default is
  `"two-step"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.
- `case_id` (*scalar*) - Pesaran-Shin-Smith deterministic case passed to the
  NARDL ECM when `ecm_type = "uecm"`. Default is `3`. Cases other than `3`
  require `ecm_type = "uecm"`.
- `d`, `thresh1`, `thresh2` - Partial-sum reset threshold controls shared
  with `nardl`. The selected threshold vector is stored in
  `nfOut.decomp_thresholds` and nested estimator outputs.

## Returns

`nfOut` is a `nardlFullOut` structure with selected lag orders `pst` and
`qst`, search bounds, common metadata, a levels output in `.na`, and an ECM
output in `.ecm`.

## Remarks

`q_control` is fixed across the lag-search grid. `pend` and `qend` define the
maximum searched values for `p` and the decomposed-variable `q`. GETS starts
from those maxima and reduces highest-order lag blocks while preserving
contiguous `p/q` orders.
`case_id` controls deterministic terms in the ECM stored in `.ecm`; the
levels estimator stored in `.na` remains the standard constant-only NARDL
levels model.
When thresholds are supplied, lag selection, the levels estimator, and the ECM
all use the same partial-sum reset rule.

## Examples

```gauss
library qardl;

nfOut = nardlFull(df, 4, 4, "y ~ x1 + x2", 0, "bic",
                  "x1", "x2", 1, "uecm");
nfGets = nardlFull(df, 4, 4, "y ~ x1 + x2", 0, "gets",
                   "x1", "x2", 1, "uecm", 0.1);
nfCaseI = nardlFull(df, 4, 4, "y ~ x1 + x2", 0, "bic",
                    "x1", "x2", 1, "uecm", 0.1, 1);
nfThresh = nardlFull(df, 4, 4, "y ~ x1 + x2", 0, "bic",
                     "x1", "x2", 1, "uecm", 0.1, 3, 0);
printNARDL(nfOut.na);
printNARDLECM(nfOut.ecm);
```

## Source

`nardl.src`

## See Also

[nardl](nardl.md), [nardlECM](nardlECM.md), [nardlAutoCase](nardlAutoCase.md),
[nardlOrder](nardlOrder.md)
