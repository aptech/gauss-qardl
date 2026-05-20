# ardlResidualDiagnostics

## Purpose

Computes core residual diagnostics for ARDL-family time-series outputs.

## Format

```gauss
dOut = ardlResidualDiagnostics(modelOut);
dOut = ardlResidualDiagnostics(modelOut, max_lags);
```

## Parameters

- `modelOut` (*structure*) - Output from `ardl`, `qardl`, `qardlECM`,
  `nardl`, or `nardlECM`.
- `max_lags` (*scalar*) - Ljung-Box lag count. If `0` or omitted, the default
  is `min(12, trunc(sqrt(nobs)))`.

## Returns

An `ardlResidualDiagOut` structure with Ljung-Box serial-correlation,
Breusch-Pagan-style heteroskedasticity, Jarque-Bera normality, and residual
CUSUM/CUSUMSQ stability diagnostics.

## Remarks

The heteroskedasticity diagnostic regresses squared residuals on an intercept
and fitted values. QARDL outputs return one diagnostic row per quantile.

The stability diagnostics are residual-bridge CUSUM and CUSUMSQ checks based
on centered residuals. They do not replace full recursive-residual stability
tests, which require regression design information not yet stored in every
public output structure.

CS-ARDL panel residual diagnostics are not handled here because stacked-panel
serial-correlation tests require unit-aware diagnostics. Use
`csardlDiagnostics` for the current CS-ARDL mean-group and poolability layer.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);
dOut = ardlResidualDiagnostics(arOut, 4);
printARDLResidualDiagnostics(dOut);
```

## Source

`diagnostics.src`

## See Also

[printARDLResidualDiagnostics](printARDLResidualDiagnostics.md),
[ardl](ardl.md), [qardl](qardl.md), [nardl](nardl.md),
[csardlDiagnostics](csardlDiagnostics.md)
