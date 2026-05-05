# applyQARDLFormula

## Purpose

Selects and reorders columns from a named GAUSS dataframe using a formula
string.

## Format

```gauss
data_qardl = applyQARDLFormula(data, formula);
```

## Parameters

- `data` (*dataframe*) - GAUSS dataframe with named columns.
- `formula` (*string*) - Formula of the form `"y ~ x1 + x2 + ..."`.

## Returns

`data_qardl` is a numeric matrix with the dependent variable in column 1 and
the selected regressors in the remaining columns.

## Remarks

Variable names are matched case-insensitively. The result can be passed to any
QARDL procedure that expects a numeric data matrix.

## Examples

```gauss
df = loadd("macro.csv");
data = applyQARDLFormula(df, "consumption ~ income + wealth");
qaOut = qardl(data, 2, 1);
```

## Source

`qardl.src`

## See Also

[qardlFull](qardlFull.md), [qardl](qardl.md)
