# printQARDLWald

## Purpose

Prints QARDL Wald-test results with interpretation notes.

## Format

```gauss
call printQARDLWald(wOut);
call printQARDLWald(wOut, alpha);
```

## Parameters

- `wOut` - `qardlWaldOut` structure returned by `qardlWald`.
- `alpha` - Optional test size used for interpretation notes. Default is `0.05`.

## Returns

Nothing. Results are printed to the GAUSS output window.

## Remarks

The printed table reports the Wald statistic, p-value, significance stars, and an interpretation table. Interpretation notes are placed after the significance note to match the other QARDL diagnostic printers.

`qardlWald` calls this printer automatically when `print_results = 1`.

## Examples

```gauss
wOut = qardlWald(qaOut, data = data, test = "constancy",
                 print_results = 0);

call printQARDLWald(wOut);
```

## Source

`qardl.src`

## See Also

[qardlWald](qardlWald.md), [qardlRestriction](qardlRestriction.md)
