# saveARDLTable

## Purpose

Saves a publication-style coefficient table for an ARDL-family output
structure.

## Format

```gauss
saveARDLTable(modelOut, fpath);
saveARDLTable(modelOut, fpath, table_format, precision, stars, ci_level);
```

## Parameters

`modelOut` is an ARDL-family levels, ECM, or full-workflow output structure.
Supported structures include `ardlOut`, `qardlOut`, `qardlECMOut`,
`nardlOut`, `nardlECMOut`, `csardlOut`, `csardlECMOut`, and the matching
full-workflow structures.

`fpath` is the output file path.

`table_format` is `"markdown"`, `"latex"`, or `"csv"`. Short aliases `"md"`
and `"tex"` are also accepted.

`precision` controls decimal places for numeric table entries. The default is
`6`.

`stars` is `1` to include a significance-code column and `0` to omit it.

`ci_level` controls confidence-interval columns. The default is `0.95`. Use
`0` to omit confidence-interval columns.

## Returns

No return value. A table file is written to `fpath`.

## Remarks

`saveARDLTable` dispatches by structure type and uses the covariance matrices
stored in the output structure. Rows without stored standard errors, such as
some intercept and long-run ECM rows, are written with blank standard-error,
test-statistic, p-value, and confidence-interval cells.

The generic table exporter is intended for reporting. Existing QARDL-specific
CSV exporters remain available for machine-readable parameter-group files.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);
saveARDLTable(arOut, "ardl_table.md", "markdown", 4, 1, 0.95);

qfOut = qardlFull(data, tau = { 0.25, 0.5, 0.75 }, verbose = 0);
saveARDLTable(qfOut, "qardl_table.tex", "latex", 4, 1, 0.90);
```

## Source

`ardl_dispatch.src`

## See Also

[saveARDLMarkdown](saveARDLMarkdown.md), [saveARDLLaTeX](saveARDLLaTeX.md),
[saveQARDLResults](saveQARDLResults.md), [saveQARDLECMResults](saveQARDLECMResults.md)
