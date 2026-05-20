# saveARDLLaTeX

## Purpose

Saves an ARDL-family coefficient table in LaTeX `tabular` format.

## Format

```gauss
saveARDLLaTeX(modelOut, fpath);
saveARDLLaTeX(modelOut, fpath, precision, stars, ci_level);
```

## Parameters

`modelOut` is an ARDL-family levels, ECM, or full-workflow output structure.

`fpath` is the output file path.

`precision` controls decimal places. The default is `6`.

`stars` is `1` to include significance codes and `0` to omit the column.

`ci_level` controls confidence-interval columns. Use `0` to omit them.

## Returns

No return value. A LaTeX `tabular` table is written to `fpath`.

## Remarks

This is a convenience wrapper around:

```gauss
saveARDLTable(modelOut, fpath, "latex", precision, stars, ci_level);
```

The exporter writes a plain `tabular` environment so users can decide whether
to wrap it in a table float, add captions, or use packages such as `booktabs`.

## Examples

```gauss
library qardl;

cfOut = csardlFull(panel_df, cs_lags = 1, formula = "y ~ x1 + x2", verbose = 0);
saveARDLLaTeX(cfOut, "csardl_table.tex", 4, 1, 0.95);
```

## Source

`ardl_dispatch.src`

## See Also

[saveARDLTable](saveARDLTable.md), [saveARDLMarkdown](saveARDLMarkdown.md)
