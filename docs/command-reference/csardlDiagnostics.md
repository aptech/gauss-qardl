# csardlDiagnostics

## Purpose

Computes optional mean-group and poolability diagnostics for CS-ARDL models.

## Format

```gauss
diagOut = csardlDiagnostics(data, ppp, qqq);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula, print_results);
```

## Parameters

`data` is a balanced panel stacked by unit in `[unit_id, y, x1, ...]` order,
or a GAUSS dataframe used with the formula interface.

`ppp` is the scalar AR lag order.

`qqq` is the scalar distributed-lag order.

`cs_lags` is the scalar cross-sectional-average lag order.

`formula` is an optional string of the form `"unit + y ~ x1 + x2"`.

`print_results` controls whether `printCSARDLDiagnostics` is called.

## Returns

`diagOut`, a `csardlDiagOut` structure containing unit-specific long-run
coefficients, unit-specific full coefficient vectors, mean-group long-run
coefficients and standard errors, pooled long-run coefficients, and a
Wald-style poolability statistic.

## Remarks

The diagnostic estimator fits the same cross-sectionally augmented ARDL design
separately for each unit. The poolability statistic compares unit-specific
long-run coefficients with the pooled CS-ARDL long-run coefficients using the
unit-specific delta-method covariance matrices.

This is a diagnostic convenience layer for the first CS-ARDL implementation.
TODO: validate the diagnostic distribution and finite-sample behavior against
published dynamic CCE/CS-ARDL designs.

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [nardl](nardl.md)
