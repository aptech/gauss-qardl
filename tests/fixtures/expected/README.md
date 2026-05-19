# Expected Outputs

Expected outputs are grouped by validation source type:

- `synthetic/` contains deterministic fixtures generated from bundled data or
  seeded synthetic data.
- `published/` is reserved for exact published-result replications after the
  underlying data and transformations are documented.

Within each source type, expected outputs are grouped by category:

- `coefficients/`
- `diagnostics/`
- `forecasts/`
- `intervals/`
- `decompositions/`
- `multipliers/`
- `panels/`
- `predictions/`

CSV files are numeric and intentionally header-free so GAUSS validation scripts
can read them with `csvReadM`.
