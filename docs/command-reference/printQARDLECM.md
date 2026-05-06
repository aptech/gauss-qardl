# printQARDLECM

## Purpose

Prints formatted two-step QARDL-ECM results with a GAUSS-style diagnostic
header and coefficient table.

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

Direct calls to `qardlECM`, `qardlECMRobust`, `qardlECMHAC`, and `qardlECMX`
print this table by default. Pass `print_results = 0` to those estimators when
you want to return results silently.

## Examples

```gauss
printQARDLECM(qECMOut, tau);
```

## Source

`qardl.src`

## See Also

[qardlECM](qardlECM.md), [printQARDL](printQARDL.md)
