# printQARDL

## Purpose

Prints formatted levels-form QARDL results with a GAUSS-style diagnostic
header and coefficient table.

## Format

```gauss
printQARDL(qaOut);
printQARDL(qaOut, tau);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Levels-form QARDL output.
- `tau` - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.

## Returns

Nothing. Results are printed to the GAUSS output window.

## Remarks

Direct calls to `qardl`, `qardlRobust`, `qardlHAC`, and `qardlX` print this
table by default. Pass `print_results = 0` to those estimators when you want to
return results silently.

## Examples

```gauss
printQARDL(qaOut, tau);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [printQARDLECM](printQARDLECM.md)
