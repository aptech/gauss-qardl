# saveARDLMarkdown

## Purpose

Saves an ARDL-family coefficient table in Markdown format.

## Format

```gauss
saveARDLMarkdown(modelOut, fpath);
saveARDLMarkdown(modelOut, fpath, precision, stars, ci_level);
```

## Parameters

`modelOut` is an ARDL-family levels, ECM, or full-workflow output structure.

`fpath` is the output file path.

`precision` controls decimal places. The default is `6`.

`stars` is `1` to include significance codes and `0` to omit the column.

`ci_level` controls confidence-interval columns. Use `0` to omit them.

## Returns

No return value. A Markdown table is written to `fpath`.

## Remarks

This is a convenience wrapper around:

```gauss
saveARDLTable(modelOut, fpath, "markdown", precision, stars, ci_level);
```

## Examples

```gauss
library qardl;

nfOut = nardlFull(data, verbose = 0);
saveARDLMarkdown(nfOut, "nardl_table.md", 4, 1, 0.95);
```

## Source

`ardl_dispatch.src`

## See Also

[saveARDLTable](saveARDLTable.md), [saveARDLLaTeX](saveARDLLaTeX.md)
