# printCSARDLECM

## Purpose

Prints a formatted CS-ARDL-ECM results table.

## Format

```gauss
printCSARDLECM(cECMOut);
```

## Parameters

- `cECMOut` (*csardlECMOut structure*) - Output from `csardlECM` or
  `csardlFull.ecm`.

## Returns

No return value. Results are printed to the GAUSS output window.

## Remarks

The table labels the ECM as two-step or unrestricted based on
`cECMOut.ecm_type`.

The printed output also includes a 5% interpretation statement for the
error-correction coefficient.

## Examples

```gauss
cECMOut = csardlECM(panel, 2, 1, 1, "", 0);
printCSARDLECM(cECMOut);
```

## Source

`csardl.src`

## See Also

[csardlECM](csardlECM.md), [printCSARDL](printCSARDL.md)
