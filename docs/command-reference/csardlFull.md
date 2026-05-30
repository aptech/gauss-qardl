# csardlFull

## Purpose

Runs the integrated CS-ARDL workflow: lag selection, levels estimation, and
ECM estimation.

## Format

```gauss
cfOut = csardlFull(data);
cfOut = csardlFull(data, pend, qend, cs_lags, formula, verbose, criterion,
                   group_var, time_var, ecm_type, gets_pval);
```

## Parameters

- `data` (*matrix or dataframe*) - Balanced panel data.
- `pend` (*scalar*) - Maximum AR lag searched. Default is `8`.
- `qend` (*scalar*) - Maximum distributed-lag order searched. Default is `8`.
- `cs_lags` (*scalar*) - Cross-sectional-average lag order. Default is `0`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `verbose` (*scalar*) - If `1`, print selected lags and estimator output.
- `criterion` (*string*) - `"bic"`, `"aic"`, `"hq"`, `"hqc"`, or `"gets"`.
- `group_var`, `time_var` (*string*) - Optional panel identifier names.
- `ecm_type` (*string*) - ECM type passed to `csardlECM`; default is
  `"two-step"`.
- `gets_pval` (*scalar*) - Wald p-value threshold used when
  `criterion = "gets"`. Default is `0.1`.

## Returns

`cfOut` is a `csardlFullOut` structure with selected lag orders `pst` and
`qst`, search bounds, panel metadata, levels output in `.csa`, and ECM output
in `.ecm`.

## Remarks

`cs_lags` is fixed across the `p`/`q` search grid. GETS starts from `pend` and
`qend`, then reduces highest-order lag blocks while preserving contiguous
`p/q` orders.

## Examples

```gauss
library qardl;

cfOut = csardlFull(df_panel, 4, 4, 1, "y ~ x1 + x2", 0, "bic",
                   "country", "year", "uecm");
cfGets = csardlFull(df_panel, 4, 4, 1, "y ~ x1 + x2", 0, "gets",
                    "country", "year", "uecm", 0.1);
```

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [csardlECM](csardlECM.md),
[csardlOrder](csardlOrder.md)
