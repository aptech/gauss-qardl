# csardlFull

## Purpose

Runs the integrated CS-ARDL workflow: lag selection, levels estimation, and
ECM estimation.

## Format

```gauss
cfOut = csardlFull(data);
cfOut = csardlFull(data, pend, qend, cs_lags, formula, verbose, criterion,
                   group_var, time_var, ecm_type, gets_pval,
                   print_diagnostics);
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
- `print_diagnostics` (*scalar*) - If `1`, print selected-specification panel
  diagnostics. If `0`, store diagnostics without printing. If `-1`, follow
  `verbose`. Default is `-1`.

## Returns

`cfOut` is a `csardlFullOut` structure with selected lag orders `pst` and
`qst`, search bounds, panel metadata, levels output in `.csa`, and ECM output
in `.ecm`. Panel diagnostics for the selected lag orders are stored in
`.panel_diag`.

## Remarks

`cs_lags` is fixed across the `p`/`q` search grid. GETS starts from `pend` and
`qend`, then reduces highest-order lag blocks while preserving contiguous
`p/q` orders.
`csardlFull` automatically runs `csardlDiagnostics` for the selected
specification and stores the result in `cfOut.panel_diag`. By default these
diagnostics print when `verbose = 1`; set `print_diagnostics = 0` to suppress
diagnostic printing while still storing the object.

## Examples

```gauss
library qardl;

cfOut = csardlFull(df_panel, 4, 4, 1, "y ~ x1 + x2", 0, "bic",
                   "country", "year", "uecm");
cfGets = csardlFull(df_panel, 4, 4, 1, "y ~ x1 + x2", 0, "gets",
                    "country", "year", "uecm", 0.1);
cfDiagOnly = csardlFull(df_panel, 4, 4, 1, "y ~ x1 + x2", 0, "bic",
                        "country", "year", "uecm", 0.1, 1);
printCSARDLDiagnostics(cfOut.panel_diag);
```

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [csardlECM](csardlECM.md),
[csardlDiagnostics](csardlDiagnostics.md), [csardlOrder](csardlOrder.md)
