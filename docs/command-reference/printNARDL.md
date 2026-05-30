# printNARDL

## Purpose

Prints a formatted NARDL levels-estimator table.

## Format

```gauss
printNARDL(naOut);
```

## Parameters

- `naOut` (*nardlOut structure*) - Output from `nardl` or `nardlFull.na`.

## Returns

No return value. Results are printed to the GAUSS output window.

## Remarks

The table includes long-run positive and negative effects, optional control
effects, AR coefficients, the bounds-style F-statistic, and long-run
asymmetry diagnostics.

## Examples

```gauss
naOut = nardl(data, 2, 1, "", 0);
printNARDL(naOut);
```

## Source

`nardl.src`

## See Also

[nardl](nardl.md), [printNARDLECM](printNARDLECM.md)
