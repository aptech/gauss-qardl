# csardlDiagnostics

## Purpose

Computes optional mean-group, poolability, and cross-sectional dependence
diagnostics for CS-ARDL models.

## Format

```gauss
diagOut = csardlDiagnostics(data, ppp, qqq);
diagOut = csardlDiagnostics(data, ppp, qqq, cs_lags, formula, print_results);
```

## Parameters

`data` is a balanced panel stacked by unit in `[unit_id, y, x1, ...]` order,
or a GAUSS dataframe used with the formula interface. Unbalanced panels are
not supported in the current implementation.

`ppp` is the scalar AR lag order.

`qqq` is the scalar distributed-lag order.

`cs_lags` is the scalar cross-sectional-average lag order.

`formula` is an optional string. For dataframe input, prefer `"y ~ x1 + x2"`;
CS-ARDL infers the panel unit and time variables using GAUSS panel-data
conventions. Formula strings do not include explicit unit/time terms.

`print_results` controls whether `printCSARDLDiagnostics` is called.

## Returns

`diagOut`, a `csardlDiagOut` structure containing unit-specific long-run
coefficients, unit-specific full coefficient vectors, mean-group long-run
coefficients and standard errors, pooled long-run coefficients, a Wald-style
poolability statistic, and a Pesaran CD residual cross-sectional dependence
diagnostic.

## Remarks

The diagnostic estimator fits the same cross-sectionally augmented ARDL design
separately for each unit. The poolability statistic compares unit-specific
long-run coefficients with the pooled CS-ARDL long-run coefficients using the
unit-specific delta-method covariance matrices.

The Pesaran CD diagnostic is computed from the balanced matrix of unit-level
residuals returned by the same unit-specific diagnostic regressions. The
reported fields are `cd_stat`, `cd_pv`, `cd_pairs`, and `cd_avg_corr`.

This is a diagnostic convenience layer for the first CS-ARDL implementation.
Deterministic validation recomputes mean-group coefficients, mean-group
standard errors, the poolability Wald statistic, and the Pesaran CD statistic
from unit-specific fits. TODO: validate finite-sample behavior against
published dynamic CCE/CS-ARDL designs.

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [nardl](nardl.md)
