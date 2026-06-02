# printARDLECM

## Purpose

Prints a formatted ARDL-ECM results table.

## Format

```gauss
printARDLECM(arECMOut);
```

## Parameters

- `arECMOut` (*ardlECMOut structure*) - Output from `ardlECM`.

## Returns

No return value. Results are printed to the GAUSS output window.

## Remarks

Direct calls to `ardlECM` print this table by default. Pass
`print_results = 0` to suppress printing and call `printARDLECM` later.

The table labels whether the ECM was estimated with the default two-step
method or the unrestricted ECM.

The printed output also includes a 5% interpretation statement for the
error-correction coefficient. The statement checks whether `rho` is negative
and statistically significant, which is the usual indication of adjustment
back toward the long-run equilibrium.

## Examples

```gauss
library qardl;

arECMOut = ardlECM(data, 2, 1, "", 0, "uecm");
printARDLECM(arECMOut);
```

## Source

`qardl.src`

## See Also

[ardlECM](ardlECM.md), [printARDL](printARDL.md)
