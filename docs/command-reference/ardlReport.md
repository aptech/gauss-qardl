# ardlReport

## Purpose

Prints and/or exports ARDL-family model reports through one unified wrapper.

## Format

```gauss
ardlReport(modelOut);
ardlReport(modelOut, fpath);
ardlReport(modelOut, fpath, table_format, precision, stars, ci_level,
           print_results);
```

## Parameters

- `modelOut` (*struct*) - ARDL-family output structure.
- `fpath` (*string*) - Optional output file path. If `""`, no file is written.
  Default is `""`.
- `table_format` (*string*) - `"markdown"`, `"latex"`, or `"csv"` for file
  output. Short aliases `"md"` and `"tex"` are accepted by the underlying
  table exporter. Default is `"markdown"`.
- `precision` (*scalar*) - Decimal places for exported numeric entries.
  Default is `6`.
- `stars` (*scalar*) - `1` to include exported significance codes, `0` to
  omit them. Default is `1`.
- `ci_level` (*scalar*) - Confidence level for exported confidence-interval
  columns. Use `0` to omit confidence intervals. Default is `0.95`.
- `print_results` (*scalar*) - `1` to print the matching GAUSS-style table to
  the console, `0` for save-only reporting. Default is `1`.

## Returns

No return value. The function prints to the console, writes a table file, or
both depending on `print_results` and `fpath`.

## Remarks

`ardlReport` dispatches to the existing print helpers for console output and
to `saveARDLTable` for file output. It supports levels, ECM, and full-workflow
outputs for ARDL, QARDL, NARDL, and CS-ARDL. Full-workflow outputs print their
nested levels and ECM estimates.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);

// Print only.
call ardlReport(arOut);

// Print and save a Markdown coefficient table.
call ardlReport(arOut, "ardl_report.md", "markdown", 4, 1, 0.95);

// Save only.
call ardlReport(arOut, "ardl_report.csv", "csv", 6, 1, 0.95, 0);

qfOut = qardlFull(data, verbose = 0);
call ardlReport(qfOut, "qardl_report.tex", "latex", 4, 1, 0.90);
```

## Source

`ardl_dispatch.src`

## See Also

[saveARDLTable](saveARDLTable.md), [printARDL](printARDL.md),
[printQARDL](printQARDL.md), [printNARDL](printNARDL.md),
[printCSARDL](printCSARDL.md)
