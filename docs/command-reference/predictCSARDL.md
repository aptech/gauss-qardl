# predictCSARDL

## Purpose

Returns in-sample fitted values from a CS-ARDL levels model.

## Format

```gauss
fit = predictCSARDL(csaOut, data);
fit = predictCSARDL(csaOut, data, formula, group_var, time_var);
```

## Parameters

- `csaOut` (*csardlOut structure*) - Output from `csardl` or
  `csardlFull.csa`.
- `data` (*matrix or dataframe*) - Panel data.
- `formula` (*string*) - Optional formula.
- `group_var`, `time_var` (*string*) - Optional panel identifier names.

## Returns

`fit`, an `nobs x 1` vector of fitted values.

## Remarks

`predictARDL` dispatches to this path when passed a `csardlOut` structure.

## Examples

```gauss
csaOut = csardl(panel, 2, 1, 1, "", 0);
fit = predictCSARDL(csaOut, panel);
```

## Source

`csardl.src`

## See Also

[csardl](csardl.md), [forecastCSARDL](forecastCSARDL.md),
[predictARDL](predictARDL.md)
