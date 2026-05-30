# printCSARDL

## Purpose

Prints a formatted CS-ARDL levels-estimator table.

## Format

```gauss
printCSARDL(csaOut);
```

## Parameters

- `csaOut` (*csardlOut structure*) - Output from `csardl` or
  `csardlFull.csa`.

## Returns

No return value. Results are printed to the GAUSS output window.

## Remarks

The table includes pooled long-run coefficients, AR coefficients, intercept,
and implied speed of adjustment.

## Examples

```gauss
csaOut = csardl(panel, 2, 1, 1, "", 0);
printCSARDL(csaOut);
```

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [printCSARDLECM](printCSARDLECM.md)
