# ardlLongRun

## Purpose

Extracts long-run coefficient estimates and their covariance matrix from an
ARDL-family output structure.

## Format

```gauss
{ beta, beta_cov } = ardlLongRun(modelOut);
```

## Parameters

`modelOut` is an `ardlOut`, `qardlOut`, `nardlOut`, `csardlOut`, or the
corresponding full-workflow output structure returned by `ardlFull`,
`qardlFull`, `nardlFull`, or `csardlFull`.

## Returns

`beta` is the long-run coefficient vector or matrix stored in the model output.

`beta_cov` is the matching long-run covariance matrix stored in the model
output.

## Remarks

`ardlLongRun` infers the model family from the structure type and returns the
standard long-run fields used by ARDL, QARDL, NARDL, and CS-ARDL levels
outputs. For full-workflow outputs, it extracts the nested levels estimator
output before returning the long-run fields.

This helper does not recompute long-run estimates. It standardizes access to
the stored output fields for reporting, validation, and downstream tooling.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);
{ beta, beta_cov } = ardlLongRun(arOut);

nfOut = nardlFull(data, verbose = 0);
{ n_beta, n_beta_cov } = ardlLongRun(nfOut);
```

## Source

`ardl_dispatch.src`

## See Also

[ardl](ardl.md), [qardl](qardl.md), [nardl](nardl.md), [csardl](csardl.md),
[predictARDL](predictARDL.md), [forecastARDL](forecastARDL.md)
