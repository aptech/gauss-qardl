# printARDLResidualDiagnostics

## Purpose

Prints residual diagnostics returned by `ardlResidualDiagnostics`.

## Format

```gauss
printARDLResidualDiagnostics(dOut);
```

## Parameters

- `dOut` (*ardlResidualDiagOut structure*) - Output from
  `ardlResidualDiagnostics`.

## Returns

Nothing. Results are printed to the GAUSS output window.

## Remarks

The printed table includes the Ljung-Box, Breusch-Pagan-style, and
Jarque-Bera statistics with chi-squared p-values and significance codes.

## Examples

```gauss
library qardl;

dOut = ardlResidualDiagnostics(arOut, 4);
printARDLResidualDiagnostics(dOut);
```

## Source

`diagnostics.src`

## See Also

[ardlResidualDiagnostics](ardlResidualDiagnostics.md)
