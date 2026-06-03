# printARDLSparseGETS

## Purpose

Prints the sparse GETS retained/dropped term table.

## Format

```gauss
printARDLSparseGETS(spOut);
```

## Parameters

- `spOut` (*ardlSparseGETSOut structure*) - Output from `ardlSparseGETS` or
  `nardlSparseGETS`.

## Returns

No return value. Results are printed to the GAUSS output window.

## Remarks

The table reports each candidate Case V UECM term, whether it was retained or
dropped, and coefficient details for retained terms.

## Examples

```gauss
spOut = ardlSparseGETS(data, 2, 2, "", 0.10, 0);
printARDLSparseGETS(spOut);
```

## Source

`qardl.src`

## See Also

[ardlSparseGETS](ardlSparseGETS.md), [nardlSparseGETS](nardlSparseGETS.md)
