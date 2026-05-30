# csardlECM

## Purpose

Estimates CS-ARDL error-correction models.

## Format

```gauss
cECMOut = csardlECM(data, ppp, qqq);
cECMOut = csardlECM(data, ppp, qqq, cs_lags, formula, print_results,
                    group_var, time_var, ecm_type);
```

## Parameters

- `data` (*matrix or dataframe*) - Balanced panel data. Matrix input is
  `[unit_id, y, x1, x2, ...]`.
- `ppp` (*scalar*) - AR lag order.
- `qqq` (*scalar*) - Distributed-lag order.
- `cs_lags` (*scalar*) - Cross-sectional-average lag order. Default is `0`.
- `formula` (*string*) - Optional formula such as `"y ~ x1 + x2"`.
- `print_results` (*scalar*) - If `1`, print a formatted ECM table.
- `group_var`, `time_var` (*string*) - Optional panel identifier names.
- `ecm_type` (*string*) - `"two-step"` (default) or `"uecm"`.

## Returns

`cECMOut` is a `csardlECMOut` structure containing pooled ECM `alpha` and
`rho`, long-run coefficients in `beta_lr`, ECM coefficients in `bt`, fitted
values, residuals, covariance metadata, and panel metadata.

## Remarks

The default `"two-step"` estimator constructs one error-correction term from
the pooled levels CS-ARDL long-run relation. With `ecm_type = "uecm"`, lagged
dependent and lagged level regressors enter the ECM directly.

## Examples

```gauss
library qardl;

cECMOut = csardlECM(panel, 2, 1, 1, "", 0);
cUECMOut = csardlECM(panel, 2, 1, 1, "", 0, "", "", "uecm");
```

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [csardlFull](csardlFull.md),
[printCSARDLECM](printCSARDLECM.md)
