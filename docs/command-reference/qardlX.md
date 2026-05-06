# qardlX

## Purpose

Estimates levels-form QARDL with a separate distributed-lag order for each
regressor.

## Format

```gauss
qaOut = qardlX(data, ppp, qvec);
qaOut = qardlX(data, ppp, qvec, tau, cov_type, hac_lags, print_results);
```

## Parameters

- `data` (*Tx(1+k) matrix*) - Dependent variable followed by regressors.
- `ppp` (*scalar*) - Autoregressive lag order.
- `qvec` (*kx1 vector*) - Distributed-lag order for each regressor.
- `tau` (*Sx1 vector*) - Quantiles. Default is `{ 0.25, 0.5, 0.75 }`.
- `cov_type` (*string*) - `"iid"`, `"robust"`, or `"hac"`. Default is
  `"robust"`.
- `hac_lags` (*scalar*) - HAC truncation lag. Use `0` for automatic bandwidth.
- `print_results` (*scalar*) - If `1`, print a formatted table. Default is
  `1`.

## Returns

A `qardlOut` structure. The `q` metadata field stores `maxc(qvec)` for
compatibility; keep the `qvec` model specification with your analysis script.

## Remarks

Use `qardlX` when theory or lag-selection results imply that regressors need
different distributed-lag lengths.

## Examples

```gauss
qaOut = qardlX(data, 2, { 0, 1, 3 }, tau, "hac", 4);
```

## Source

`qardl.src`

## See Also

[qardl](qardl.md), [pqorderX](pqorderX.md), [qardlECMX](qardlECMX.md)
