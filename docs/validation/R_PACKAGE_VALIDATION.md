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
- fixed-order ARDL unrestricted ECM coefficients, fitted values, residuals,
  `sigma2`, and usable observations against `ardl_uecm()$ARDL_ECM_fit`;
- NARDL long-run positive, negative, and control coefficients against
  `nardl_uecm()$Longrun_relation`;
- NARDL levels fitted values, residuals, `sigma2`, and usable observations
  against `nardl_uecm()$NARDL_fit`;
- public GAUSS `nardlECM` two-step restricted ECM coefficients, fitted values,
  residuals, `sigma2`, and usable observations against an equivalent R
  reconstruction of the GAUSS restricted ECM design;
- fixed-order NARDL unrestricted ECM coefficients, fitted values, residuals,
  `sigma2`, and usable observations against `nardl_uecm()$NARDL_ECM_fit`;
- standalone ARDL and NARDL sparse GETS outputs against
  `gets_ardl_uecm()` and `gets_nardl_uecm()` where the R package reference is
  available. These diagnostic rows compare the final keep vector, full
  coefficient vector in GAUSS term order, `sigma2`, usable observations, and
  dropped-term count;
- coarse runtime budgets for the GAUSS export step and the R package reference
  step.

The `ardl.nardl` package names its ECM fits as unrestricted error-correction
models. In those regressions, the lagged dependent variable and lagged level
regressors are estimated directly and the long-run relation is derived from
those coefficients. GAUSS ECM workflows default to the restricted two-step
estimator: they estimate the long-run levels relation first, then include a
single lagged error-correction term in the ECM regression. Public GAUSS
ECM-specific workflows now also accept `ecm_type = "uecm"`. The R-package
UECM checks in this harness still use validation design matrices where needed
to match the R package's exact sample and lag convention.

Rows that intentionally compare different conventions are retained as
diagnostics and marked `required = FALSE` in the generated summary. These
include package-reported long-run relations derived from the R UECM fit and the
R package's NARDL levels fit, which uses a shorter sample than GAUSS's fixed
levels estimator. Sparse GETS rows are also diagnostic because the R package
delegates deletion to `gets.lm`, while GAUSS uses its own deterministic
max-p-value deletion loop with the same protected lagged-level convention.

Generated comparison files are written to ignored directories under
`tests/r_package/actual/` and `tests/r_package/r_expected/`.

This is a cross-implementation software validation target, not a published
empirical replication. The default tolerances are `1e-6` absolute and relative
because the two packages use different but algebraically equivalent ARDL/NARDL
parameterizations before comparing fitted values and long-run effects.
