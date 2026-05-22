# nardl

## Purpose

Estimates nonlinear ARDL models using positive and negative partial-sum
decompositions of each regressor. The source includes `nardl`, `nardlECM`,
`nardlFull`, `nardlOrder`, `nardlOrderGrid`, `nardlICMean`, `printNARDL`,
`printNARDLECM`, `predictNARDL`, `forecastNARDL`, and `applyNARDLFormula`.

## Format

```gauss
naOut = nardl(data, ppp, qqq);
nfOut = nardlFull(data);
nfOut = nardlFull(data, pend, qend, formula);
```

## Remarks

The levels estimator reports long-run positive and negative coefficients,
delta-method long-run covariance, a UECM bounds F-statistic, and long-run and
short-run asymmetry Wald tests.

`nardlFull`, `nardlOrder`, and `nardlOrderGrid` support information-criterion
lag selection. If `pend` and `qend` are omitted, the default maximum search
bounds are `8` and `8`.

Use `nardlDynamicMultipliers` to compute positive and negative dynamic
multiplier paths from a stored `nardlOut`.

The current benchmark coverage uses deterministic synthetic decomposition,
coefficient, bounds, asymmetry, and dynamic-multiplier fixtures. Additional
published-result validation cases can be added as reference datasets and
specifications become available.

## Source

`nardl.src`

## See Also

[qardl](qardl.md), [csardl](csardl.md),
[nardlDynamicMultipliers](nardlDynamicMultipliers.md)
