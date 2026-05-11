# nardl

## Purpose

Estimates nonlinear ARDL models using positive and negative partial-sum
decompositions of each regressor. The source includes `nardl`, `nardlECM`,
`nardlFull`, `nardlOrder`, `nardlOrderGrid`, `nardlICMean`, `printNARDL`,
`printNARDLECM`, `predictNARDL`, `forecastNARDL`, and `applyNARDLFormula`.

## Format

```gauss
naOut = nardl(data, ppp, qqq);
nfOut = nardlFull(data, pend, qend, formula);
```

## Remarks

The levels estimator reports long-run positive and negative coefficients,
delta-method long-run covariance, a UECM bounds F-statistic, and long-run and
short-run asymmetry Wald tests.

Published-result validation cases are still TODO until reference datasets and
specifications are added. The current benchmark coverage uses deterministic
synthetic datasets.

## Source

`nardl.src`

## See Also

[qardl](qardl.md), [csardl](csardl.md)
