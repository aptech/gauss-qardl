# saveQARDLResults

## Purpose

Exports levels-form QARDL results to CSV files.

## Format

```gauss
saveQARDLResults(qaOut);
saveQARDLResults(qaOut, tau, outdir);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Levels-form QARDL output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `outdir` (*string*) - Output directory. Default is `"."`.

## Returns

Nothing. Writes CSV files to `outdir`.

## Remarks

Use for reproducible tables and downstream reporting.

## Examples

```gauss
saveQARDLResults(qaOut, tau, "results");
```

## Source

`qardl.src`

## See Also

[saveQARDLECMResults](saveQARDLECMResults.md), [qardl](qardl.md)
