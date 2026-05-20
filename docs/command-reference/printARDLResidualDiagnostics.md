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

The printed table includes Ljung-Box, Breusch-Pagan-style, Jarque-Bera,
residual CUSUM, and residual CUSUMSQ statistics with p-values and
significance codes. CUSUM and CUSUMSQ p-values use the residual-bridge
approximation described in `ardlResidualDiagnostics`.

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
