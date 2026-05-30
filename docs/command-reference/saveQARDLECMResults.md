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

Use for reproducible tables and downstream reporting. For two-step ECM output,
the long-run CSV stores one row per regressor. For unrestricted ECM output, it
stores one row per quantile and regressor because the long-run coefficients are
quantile-specific.

## Examples

```gauss
saveQARDLECMResults(qECMOut, tau, "results");
```

## Source

`qardl.src`

## See Also

[saveQARDLResults](saveQARDLResults.md), [qardlECM](qardlECM.md)
