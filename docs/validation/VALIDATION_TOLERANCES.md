# Validation Tolerances

This note documents the tolerance policy used by deterministic validation and
benchmark tests.

## Default Policy

Stored expected-output fixtures should use the tightest tolerance that is stable
across GAUSS runs on the supported release platform.

| Fixture type | Typical tolerance | Notes |
| --- | ---: | --- |
| Algebraic identities and dispatch equivalence | `1e-10` to `1e-12` | Used when outputs should match exactly up to floating-point roundoff. |
| Stored synthetic coefficients, forecasts, and diagnostics | `1e-8` to `1e-6` | Used for deterministic seeded examples. |
| Published/reference replications | case-specific | Must document data source, transformations, deterministic terms, lag orders, and sample range. |
| Bootstrap fixtures | case-specific, generally wider | Must fix seed, block length, method, and requested replications. |
| Performance smoke tests | wall-clock targets | Intended to catch large regressions, not microbenchmark noise. |

## Fixture Manifest

The fixture manifest records the tolerance for each active validation case:

```text
tests/fixtures/fixture_manifest.csv
```

New validation cases should include:

- model family
- data source
- expected-output file path
- tolerance
- notes explaining whether the fixture is synthetic, independently
  reproduced, or published-reference

## Failure Interpretation

When a deterministic fixture fails:

1. Confirm the fixture source and transformation have not changed.
2. Compare the maximum absolute difference to the documented tolerance.
3. If the model implementation intentionally changed, regenerate the expected
   fixture and document why.
4. If the implementation did not intentionally change, treat the failure as a
   regression until explained.

Do not widen tolerances to hide unexplained numerical changes.
