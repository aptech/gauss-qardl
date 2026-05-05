# qardlAR2Sim

## Purpose

Simulates data for QARDL examples and smoke tests.

## Format

```gauss
data = qardlAR2Sim(nnn, alpha, phi, rho, the0, the1);
```

## Parameters

- `nnn` - Number of observations.
- `alpha` - Intercept parameter.
- `phi`, `rho`, `the0`, `the1` - Data-generating process parameters.

## Returns

`data` is a numeric matrix with a dependent variable and regressors.

## Remarks

This helper is intended for examples, tests, and demonstrations rather than as
a general simulation framework.

## Examples

```gauss
data = qardlAR2Sim(1000, 1, 0.25, 0.5, 2, 3);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [qardlFull](qardlFull.md)
