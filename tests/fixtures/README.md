# Validation Fixtures

This directory contains the deterministic fixture registry used by the
validation benchmark harness.

- `fixture_manifest.csv` lists every deterministic or pending published
  validation fixture.
- `expected/` stores expected numerical outputs by source type and output
  category.

Synthetic fixtures are generated inside validation case scripts and are safe to
redistribute. Published-result fixtures must not be added until the dataset,
transformations, sample window, and redistribution status are documented.

