# wtestsym

## Purpose

Tests cross-quantile symmetry of QARDL parameters.

## Format

```gauss
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestsym(qaOut, tau, data);
```

## Parameters

- `qaOut` (*qardlOut structure*) - Levels-form QARDL output.
- `tau` (*Sx1 vector*) - Quantiles used in estimation.
- `data` - Data matrix used for estimation.

## Returns

Wald statistics and p-values for beta, gamma/theta, and phi symmetry.

## Remarks

Quantile pairs should be symmetric around 0.5, such as 0.25 and 0.75.

## Examples

```gauss
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestsym(qaOut, tau, data);
```

## Source

`wtestsym.src`

## See Also

[wtestconst](wtestconst.md)
