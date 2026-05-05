# blockBootstrapQARDLMethod

## Purpose

Computes block-bootstrap confidence intervals for levels-form QARDL using a
specified resampling method.

## Format

```gauss
{ beta_ci, gamma_ci, phi_ci } =
    blockBootstrapQARDLMethod(data, ppp, qqq, tau, B, blk_len, alpha, method);
```

## Parameters

- `method` (*string*) - `"moving"`, `"circular"`, or `"stationary"`.
- Other parameters match `blockBootstrapQARDL`.

## Returns

Bootstrap confidence interval matrices for beta, gamma/theta, and phi.

## Remarks

Use `"moving"` for the compatibility moving-block bootstrap.

## Examples

```gauss
{ beta_ci, gamma_ci, phi_ci } =
    blockBootstrapQARDLMethod(data, 2, 1, tau, 499, 0, 0.05, "circular");
```

## Source

`qardl.src`

## See Also

[blockBootstrapQARDL](blockBootstrapQARDL.md)
