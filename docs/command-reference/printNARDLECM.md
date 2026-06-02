# printNARDLECM

## Purpose

Prints a formatted NARDL-ECM results table.

## Format

```gauss
printNARDLECM(nECMOut);
```

## Parameters

- `nECMOut` (*nardlECMOut structure*) - Output from `nardlECM` or
  `nardlFull.ecm`.

## Returns

No return value. Results are printed to the GAUSS output window.

## Remarks

The table labels the ECM as two-step or unrestricted based on
`nECMOut.ecm_type`.

The printed output also includes 5% interpretation statements for the
error-correction coefficient and long-run asymmetry tests.

## Examples

```gauss
nECMOut = nardlECM(data, 2, 1, "", 0, "", "", -1, 0, "uecm");
printNARDLECM(nECMOut);
```

## Source

`nardl.src`

## See Also

[nardlECM](nardlECM.md), [printNARDL](printNARDL.md)
