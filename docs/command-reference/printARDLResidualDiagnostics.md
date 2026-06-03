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

The printed table includes Ljung-Box, BG LM, Breusch-Pagan-style, ARCH LM,
Jarque-Bera, RESET, residual CUSUM, and residual CUSUMSQ statistics with
p-values and significance codes. CUSUM and CUSUMSQ p-values use the
residual-bridge approximation described in `ardlResidualDiagnostics`.

After the significance note, the printed output includes a tabular 5%
interpretation summarizing how many residual series reject each diagnostic
null.

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
