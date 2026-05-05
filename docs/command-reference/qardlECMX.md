# qardlECMX

## Purpose

Estimates the two-step QARDL-ECM model with a separate distributed-lag order
for each regressor.

## Format

```gauss
qECMOut = qardlECMX(data, ppp, qvec);
qECMOut = qardlECMX(data, ppp, qvec, tau, cov_type, hac_lags);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qvec` (*kx1 vector*) - Distributed-lag order for each regressor.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `cov_type` (*string*) - `"iid"`, `"robust"`, or `"hac"`. Default is
  `"robust"`.
- `hac_lags` (*scalar*) - HAC truncation lag. Use `0` for automatic bandwidth.

## Returns

A `qardlECMOut` structure. The `q` metadata field stores `maxc(qvec)` for
compatibility.

## Remarks

Use this procedure when the ECM workflow needs heterogeneous distributed-lag
orders across regressors.

## Examples

```gauss
qECMOut = qardlECMX(data, 2, { 0, 1 }, tau, "hac", 2);
```

## Source

`qardl.src`

## See Also

[qardlECM](qardlECM.md), [qardlX](qardlX.md), [pqorderX](pqorderX.md)
