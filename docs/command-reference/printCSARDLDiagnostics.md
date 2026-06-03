# printCSARDLDiagnostics

## Purpose

Prints CS-ARDL panel diagnostics.

## Format

```gauss
printCSARDLDiagnostics(diagOut);
```

## Parameters

- `diagOut` (*csardlDiagOut structure*) - Output from `csardlDiagnostics`.

## Returns

No return value. Results are printed to the GAUSS output window.

## Remarks

The printed table includes mean-group versus pooled long-run coefficients,
poolability, slope heterogeneity, Pesaran-Yamagata slope homogeneity, and
Pesaran CD diagnostics.

After the significance note, the printed output includes a tabular 5%
interpretation for each panel diagnostic, including residual cross-sectional
dependence.

## Examples

```gauss
diagOut = csardlDiagnostics(panel, 2, 1, 1, "", 0);
printCSARDLDiagnostics(diagOut);
```

## Source

`csardl.src`

## See Also

[csardlDiagnostics](csardlDiagnostics.md), [csardl](csardl.md)
