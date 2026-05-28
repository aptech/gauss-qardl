# ARDL/NARDL R Package Validation

This optional validation suite compares selected GAUSS ARDL and NARDL outputs
against the CRAN `ardl.nardl` package.

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_r_package_validation.ps1
```

The runner skips cleanly when `Rscript` or the R package is not installed. To
make the check required, use:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_r_package_validation.ps1 -RequireRPackage
```

To install the CRAN package before running, use:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_r_package_validation.ps1 -InstallMissingRPackage
```

## Coverage

The suite builds deterministic GAUSS datasets and validates:

- ARDL long-run coefficients against `ardl_uecm()$Longrun_relation`;
- ARDL levels fitted values, residuals, `sigma2`, and usable observations
  against `ardl_uecm()$ARDL_fit`;
- NARDL long-run positive, negative, and control coefficients against
  `nardl_uecm()$Longrun_relation`;
- NARDL levels fitted values, residuals, `sigma2`, and usable observations
  against `nardl_uecm()$NARDL_fit`;
- coarse runtime budgets for the GAUSS export step and the R package reference
  step.

Generated comparison files are written to ignored directories under
`tests/r_package/actual/` and `tests/r_package/r_expected/`.

This is a cross-implementation software validation target, not a published
empirical replication. The default tolerances are `1e-6` absolute and relative
because the two packages use different but algebraically equivalent ARDL/NARDL
parameterizations before comparing fitted values and long-run effects.
