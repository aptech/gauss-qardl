# applyNARDLFormula

## Purpose

Applies a formula to a GAUSS dataframe for NARDL workflows.

## Format

```gauss
data_mat = applyNARDLFormula(data, formula);
```

## Parameters

- `data` (*dataframe or matrix*) - Input data.
- `formula` (*string*) - Formula such as `"y ~ x1 + x2"`.

## Returns

`data_mat`, a numeric matrix ordered `[y, x1, x2, ...]`.

## Remarks

`applyNARDLFormula` uses the same formula parser as `applyQARDLFormula`.
Estimator calls apply formulas internally, so direct use is mainly helpful
when preparing a matrix once for repeated calls.

## Examples

```gauss
data_mat = applyNARDLFormula(df, "y ~ x1 + x2");
naOut = nardl(data_mat, 2, 1, "", 0);
```

## Source

`nardl.src`

## See Also

[nardl](nardl.md), [applyQARDLFormula](applyQARDLFormula.md)
