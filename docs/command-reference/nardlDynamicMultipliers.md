# nardlDynamicMultipliers

## Purpose

Computes dynamic multipliers for an estimated NARDL levels model. The returned
matrices trace the adjustment path after a one-unit change in each positive and
negative partial-sum regressor.

## Format

```gauss
dmOut = nardlDynamicMultipliers(naOut);
dmOut = nardlDynamicMultipliers(naOut, horizon);
```

## Parameters

- `naOut` (*nardlOut*) - Output returned by `nardl`.
- `horizon` (*scalar*) - Optional non-negative horizon. Default = `20`.

## Returns

`dmOut`, an `nardlDynMultOut` structure with:

- `h` - horizons `0...horizon`.
- `pos` - positive partial-sum dynamic multipliers.
- `neg` - negative partial-sum dynamic multipliers.
- `asymmetry` - `pos - neg`.

Rows correspond to horizons and columns correspond to original regressors.

## Remarks

The calculation uses the stored NARDL levels coefficients, autoregressive
parameters, and distributed-lag coefficients. It does not re-estimate the model.

Current validation covers deterministic synthetic fixtures. Published dynamic
multiplier validation remains pending until the exact Shin-Yu-Greenwood-Nimmo
datasets and specifications are available.

## Examples

```gauss
library qardl;

naOut = nardl(data, 2, 2, "", 0);
dmOut = nardlDynamicMultipliers(naOut, 12);

print dmOut.pos;
print dmOut.neg;
```

## Source

`nardl.src`

## See Also

[nardl](nardl.md), [forecastARDL](forecastARDL.md)

