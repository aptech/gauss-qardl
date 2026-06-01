# ardlResidualDiagnostics

## Purpose

Computes core residual diagnostics for ARDL-family time-series outputs.

## Format

```gauss
dOut = ardlResidualDiagnostics(modelOut);
dOut = ardlResidualDiagnostics(modelOut, max_lags);
```

## Parameters

- `modelOut` (*structure*) - Output from `ardl`, `ardlECM`, `qardl`,
  `qardlECM`, `nardl`, or `nardlECM`.
- `max_lags` (*scalar*) - Ljung-Box lag count. If `0` or omitted, the default
  is `min(12, trunc(sqrt(nobs)))`.

## Returns

An `ardlResidualDiagOut` structure with Ljung-Box and Breusch-Godfrey-style
serial-correlation diagnostics, Breusch-Pagan-style and ARCH LM
heteroskedasticity diagnostics, Jarque-Bera normality, Ramsey RESET-style
functional-form diagnostics, and residual CUSUM/CUSUMSQ stability diagnostics.

## Remarks

`serial_*` fields are kept for backwards compatibility and mirror the
`ljung_box_*` fields. The BG LM, ARCH LM, and RESET diagnostics use stored
residuals and fitted values because full design matrices are not retained by
all model outputs. QARDL outputs return one diagnostic row per quantile.

The Breusch-Pagan-style diagnostic regresses squared residuals on an intercept
and fitted values. ARCH LM regresses squared residuals on lagged squared
residuals. RESET uses fitted-value powers as auxiliary regressors.

The stability diagnostics are residual-bridge CUSUM and CUSUMSQ checks based
on centered residuals. They do not replace full recursive-residual stability
tests, which require regression design information not yet stored in every
public output structure.

CS-ARDL panel residual diagnostics are not handled here because stacked-panel
serial-correlation tests require unit-aware diagnostics. Use
`csardlDiagnostics` for the current CS-ARDL mean-group, poolability,
Pesaran-Yamagata, and Pesaran CD panel diagnostic layer.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);
dOut = ardlResidualDiagnostics(arOut, 4);
printARDLResidualDiagnostics(dOut);

arECMOut = ardlECM(data, 2, 1, "", 0, "uecm");
dECMOut = ardlResidualDiagnostics(arECMOut, 4);
```

## Source

`diagnostics.src`

## See Also

[printARDLResidualDiagnostics](printARDLResidualDiagnostics.md),
[ardl](ardl.md), [ardlECM](ardlECM.md), [qardl](qardl.md),
[nardl](nardl.md), [csardlDiagnostics](csardlDiagnostics.md)
