# printQARDLECM

## Purpose

Prints formatted two-step QARDL-ECM results.

## Format

```gauss
printQARDLECM(qECMOut);
printQARDLECM(qECMOut, tau);
```

## Parameters

- `qECMOut` (*qardlECMOut structure*) - QARDL-ECM output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.

## Returns

Nothing. Results are printed to the GAUSS output window.

## Remarks

Use this as a presentation helper after ECM estimation.

## Examples

```gauss
printQARDLECM(qECMOut, tau);
```

## Source

`qardl.src`

## See Also

[qardlECM](qardlECM.md), [printQARDL](printQARDL.md)
