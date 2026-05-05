# printQARDL

## Purpose

Prints formatted levels-form QARDL results.

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

Use this as a presentation helper after estimation.

## Examples

```gauss
printQARDL(qaOut, tau);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [printQARDLECM](printQARDLECM.md)
