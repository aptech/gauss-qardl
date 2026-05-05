# blockBootstrapQARDLECMMethod

## Purpose

Computes QARDL-ECM block-bootstrap confidence intervals using a specified
resampling method.

## Format

```gauss
{ rho_ci, alpha_ci } =
    blockBootstrapQARDLECMMethod(data, ppp, qqq, tau, B, blk_len, alpha, method);
```

## Parameters

- `method` (*string*) - `"moving"`, `"circular"`, or `"stationary"`.
- Other parameters match `blockBootstrapQARDLECM`.

## Returns

Bootstrap confidence interval matrices for rho and alpha.

## Remarks

Use `"moving"` for the compatibility moving-block bootstrap.

## Examples

```gauss
{ rho_ci, alpha_ci } =
    blockBootstrapQARDLECMMethod(data, 2, 1, tau, 499, 0, 0.05, "stationary");
```

## Source

`qardl.src`

## See Also

[blockBootstrapQARDLECM](blockBootstrapQARDLECM.md)
