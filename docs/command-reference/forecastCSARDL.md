# forecastCSARDL

## Purpose

Returns point forecasts from a CS-ARDL levels model.

## Format

```gauss
fcst = forecastCSARDL(csaOut, data);
fcst = forecastCSARDL(csaOut, data, h, formula, future_x, group_var, time_var);
```

## Parameters

- `csaOut` (*csardlOut structure*) - Output from `csardl` or
  `csardlFull.csa`.
- `data` (*matrix or dataframe*) - Panel data.
- `h` (*scalar*) - Forecast horizon. Default is `1`.
- `formula` (*string*) - Optional formula.
- `future_x` - Reserved for future panel forecast paths. Currently not
  supported.
- `group_var`, `time_var` (*string*) - Optional panel identifier names.

## Returns

`fcst`, an `h x 1` vector.

## Remarks

The current CS-ARDL forecast hook holds future regressors and
cross-sectional averages fixed and repeats the final fitted value. Passing a
nonmissing `future_x` currently raises an error.

## Examples

```gauss
csaOut = csardl(panel, 2, 1, 1, "", 0);
fcst = forecastCSARDL(csaOut, panel, 4);
```

## Source

`csardl.src`

## See Also

[predictCSARDL](predictCSARDL.md), [forecastARDL](forecastARDL.md),
[csardl](csardl.md)
