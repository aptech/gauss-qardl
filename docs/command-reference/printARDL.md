# printARDL

## Purpose

Prints formatted levels-form ARDL results.

## Format

```gauss
printARDL(arOut);
```

## Parameters

- `arOut` (*ardlOut struct*) - Output returned by `ardl` or `ardlFull`.

## Returns

Prints a GAUSS-style results table to the console.

## Remarks

The table follows the QARDL print style and includes standard errors,
z-statistics, p-values, and significance asterisks.

## Examples

```gauss
library qardl;

arOut = ardl(data, 2, 1, "", 0);
printARDL(arOut);
```

## Source

`qardl.src`

## See Also

[ardl](ardl.md), [printQARDL](printQARDL.md)
