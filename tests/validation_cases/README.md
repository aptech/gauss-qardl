# Validation Cases

GAUSS validation cases live in separate source-type directories:

- `synthetic/` contains deterministic bundled or seeded fixtures.
- `published/` contains exact published-result replications once data and
  specifications are available.

The runner discovers `*.e` files in these directories, so new validation cases
can be added without changing `tests/run_validation_benchmarks.ps1`.

