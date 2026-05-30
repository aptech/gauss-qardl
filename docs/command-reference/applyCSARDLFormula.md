# applyCSARDLFormula

## Purpose

Applies a formula and panel identifiers to a GAUSS dataframe for CS-ARDL
workflows.

## Format

```gauss
panel_mat = applyCSARDLFormula(data, formula);
panel_mat = applyCSARDLFormula(data, formula, group_var, time_var);
```

## Parameters

- `data` (*dataframe or matrix*) - Input data.
- `formula` (*string*) - Formula such as `"y ~ x1 + x2"`.
- `group_var` (*string*) - Optional panel identifier column name.
- `time_var` (*string*) - Optional panel time column name.

## Returns

`panel_mat`, a balanced panel matrix ordered `[unit_id, y, x1, x2, ...]`.

## Remarks

If `group_var` or `time_var` are empty, CS-ARDL uses GAUSS-style inference:
the first string/category column is the unit identifier, and the first date
column is the time variable, falling back to the first numeric column if no
date column exists. The output is sorted by unit and time.

Estimator calls apply formulas internally, so direct use is mainly helpful
when preparing a matrix once for repeated calls.

## Examples

```gauss
panel_mat = applyCSARDLFormula(df_panel, "y ~ x1 + x2",
                               "country", "year");
csaOut = csardl(panel_mat, 2, 1, 1, "", 0);
```

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [csardlFull](csardlFull.md),
[applyQARDLFormula](applyQARDLFormula.md)
