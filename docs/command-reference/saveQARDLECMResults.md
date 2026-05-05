# saveQARDLECMResults

## Purpose

Exports QARDL-ECM results to CSV files.

## Format

```gauss
saveQARDLECMResults(qECMOut);
saveQARDLECMResults(qECMOut, tau, outdir);
```

## Parameters

- `qECMOut` (*qardlECMOut structure*) - QARDL-ECM output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `outdir` (*string*) - Output directory. Default is `"."`.

## Returns

Nothing. Writes CSV files to `outdir`.

## Remarks

Use for reproducible tables and downstream reporting.

## Examples

```gauss
saveQARDLECMResults(qECMOut, tau, "results");
```

## Source

`qardl.src`

## See Also

[saveQARDLResults](saveQARDLResults.md), [qardlECM](qardlECM.md)
