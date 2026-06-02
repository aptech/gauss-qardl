# R `ardl.nardl` Functionality Inventory

This note compares the public scope of the CRAN `ardl.nardl` package with the
current GAUSS QARDL library. It uses CRAN `ardl.nardl` 1.3.0 and the GAUSS
command reference/source tree in this repository.

Sources:

- CRAN package page: <https://cran.r-project.org/web/packages/ardl.nardl/index.html>
- CRAN reference manual: <https://cran.r-project.org/web/packages/ardl.nardl/refman/ardl.nardl.html>
- GAUSS command reference: `docs/COMMAND_REFERENCE.md`
- GAUSS feature matrix: `docs/FEATURE_SUPPORT_MATRIX.md`

## Summary

The R package is focused on single-equation ARDL/NARDL workflows, especially
unrestricted ECM estimation, general-to-specific variable reduction, automatic
case workflows, bounds testing, and NARDL symmetry restrictions. The GAUSS
library is broader across the ARDL family: it includes ARDL, QARDL, NARDL, and
CS-ARDL estimators, IC and hierarchical GETS lag selection, unified
prediction/forecasting, QARDL bootstrap and QIRF tools, panel diagnostics,
table export, and validation infrastructure.

## Comparison Table

| Scope | R `ardl.nardl` | GAUSS QARDL library | Status | Notes |
| --- | --- | --- | --- | --- |
| Package orientation | Single-equation time-series ARDL/NARDL with UECM, GETS, bounds, and symmetry workflows. | Broader ARDL-family library: ARDL, QARDL, NARDL, CS-ARDL, forecasting, bootstrap, rolling, diagnostics, and export. | Different scope | R is narrower but deeper on UECM/GETS; GAUSS is broader across model families. |
| Fixed-order ARDL levels model | `ardl_uecm()` returns `ARDL_fit`. | `ardl()` and `ardlFull()`. | Match | Current R-package validation shows levels fitted values, residuals, sigma2, and nobs match for fixed orders. |
| Fixed-order ARDL unrestricted ECM | `ardl_uecm()` returns `ARDL_ECM_fit` and UECM summaries. | `ardlECM(..., ecm_type = "uecm", case_id = 1..5)` returns unrestricted ECM estimates in `ardlECMOut`. | Partial | Public GAUSS support exists with deterministic cases; exact R parity still depends on sample and lag-convention alignment. |
| ARDL long-run relation from UECM | Derived from unrestricted ECM lagged-level coefficients. | Levels-form `ardl()` stores long-run effects; validation-only UECM comparison exists. | Partial | The two long-run conventions are intentionally reported separately in `R_PACKAGE_COMPARISON.md`. |
| ARDL deterministic cases | Estimators accept `case = 1` through `5`. | `ardlboundsCase*` supports cases I-V; `ardlECM(..., case_id = 1..5)` supports two-step and UECM deterministic cases; `ardlFull(..., case_id)` exposes bounds case controls. | Broad match | Levels-form `ardl()` remains the package's constant-only levels estimator; deterministic cases are handled in bounds/ECM workflows. |
| ARDL bounds testing | `dynamac_pkg_bounds_test()` and estimator outputs report PSS bounds information. | `ardlbounds`, `ardlboundsCase`, `ardlboundsCaseCV`, `ardlboundsCaseSim`, and print helpers. | GAUSS broader for ARDL bounds | GAUSS has direct case-specific and simulation critical-value APIs; R integrates bounds into UECM workflows. |
| ARDL GETS selection | `gets_ardl_uecm()` performs general-to-specific reduction with `gets.lm`. | `ardlFull()` and scalar `pqSelect` accept `criterion = "gets"` and `gets_pval`; `ardlAutoCase(..., gets_mode = "sparse")` prunes individual non-level Case V UECM terms. | Partial | GAUSS now covers hierarchical lag-block GETS plus sparse auto-case UECM pruning; standalone sparse `gets_ardl_uecm` output parity remains deferred. |
| ARDL automatic case workflow | `auto_case_ardl()` searches case/specification workflow. | `ardlAutoCase()` supports hierarchical or sparse GETS modes, infers the admissible PSS case set from Case V UECM deterministic terms, and reports case-specific bounds rows. | Broad partial | Sparse mode stores the pruned Case V UECM fit in `sparse_*` fields while retaining dense `.ecm` compatibility output. |
| Fixed-order NARDL levels model | `nardl_uecm()` returns `NARDL_fit`; `nardl_mdv()` handles two decomposed variables. | `nardl()` supports named `decomp_vars`, `control_vars`, `q_decomp`, `q_control`, and partial-sum reset thresholds. | Broad match | GAUSS supports multiple decomposed variables/controls and R-style threshold reset options; exact R parity still depends on UECM/sample convention alignment. |
| Fixed-order NARDL unrestricted ECM | `nardl_uecm()` returns `NARDL_ECM_fit` and UECM summaries. | `nardlECM(..., ecm_type = "uecm", case_id = 1..5, d, thresh1, thresh2)`. | Partial | Public GAUSS support exists with deterministic cases and threshold reset controls; standalone sparse GETS output parity remains deferred. |
| Public NARDL restricted ECM | Not a direct R package estimator; R focuses on UECM fits. | `nardlECM()` is a two-step restricted ECM estimator with `case_id = 1..5`. | GAUSS-only | Current validation compares GAUSS `nardlECM` to an equivalent R reconstruction. |
| NARDL decomposed-variable selection | `decomp`, optional `control`, and `c_q_order`; `nardl_mdv()` supports two decomposed variables. | `decomp_vars`, `control_vars`, `q_decomp`, and `q_control`; multiple named decomposed variables and controls. | GAUSS broader | GAUSS is broader on variable count/control count; R remains broader on sparse UECM GETS and symmetry-restricted estimators. |
| NARDL threshold partial sums | `d`, `thresh1`, and `thresh2` allow `Inf`, `mean`, `0`, or custom thresholds. | `nardl`, `nardlECM`, `nardlFull`, `nardlOrder`, `nardlOrderGrid`, and `nardlICMean` accept `d`, `thresh1`, and `thresh2`; defaults preserve standard cumulative sums. | Match | GAUSS follows R's reset-threshold convention while also allowing a threshold vector for more than two decomposed variables. |
| NARDL GETS selection | `gets_nardl_uecm()` and `nardl_auto_case()` perform general-to-specific reduction. | `nardlFull()` and `nardlOrder()` accept `criterion = "gets"` and `gets_pval`; `nardlAutoCase(..., gets_mode = "sparse")` prunes individual non-level Case V NARDL UECM terms. | Partial | GAUSS now covers hierarchical lag-block GETS plus sparse auto-case UECM pruning; standalone sparse `gets_nardl_uecm` output parity remains deferred. |
| NARDL automatic case workflow | `nardl_auto_case()` combines NARDL, GETS, and case selection. | `nardlAutoCase()` combines hierarchical or sparse GETS, named NARDL decomposition/control specs, threshold reset options, Case V deterministic-term inference, and case-specific bounds rows. | Broad partial | Sparse mode stores the pruned Case V NARDL UECM fit in `sparse_*` fields while retaining dense `.ecm` compatibility output. |
| NARDL long-run and short-run asymmetry tests | `nardl_uecm()` / GETS outputs include long-run and short-run asymmetry tests. | `nardl()` / `nardlECM()` report long-run and short-run asymmetry Wald tests. | Broad match | Exact finite-sample/sample-convention parity still depends on model parameterization. |
| NARDL symmetry-restricted estimation | `nardl_uecm_sym()` estimates SRSR and LRSR restrictions. | `nardl`, `nardlECM`, and `nardlFull` accept `symmetry = "SRSR"`, `"LRSR"`, or `"both"` to impose short-run and/or long-run symmetry restrictions. | Broad match | GAUSS exposes the restrictions through existing procedures rather than a separate function; exact R printed-list parity remains deferred. |
| NARDL dynamic multipliers | Not a primary exported command in `ardl.nardl` 1.3.0. | `nardlDynamicMultipliers()`. | GAUSS-only | Useful GAUSS extension beyond the R package surface. |
| Residual diagnostics | Estimator outputs include BG serial-correlation, ARCH LM, Jarque-Bera, RESET, and Ljung-Box diagnostics. | `ardlResidualDiagnostics()` includes Ljung-Box, BG LM, Breusch-Pagan-style, ARCH LM, Jarque-Bera, RESET, and CUSUM/CUSUMSQ stability diagnostics; CS-ARDL has separate panel diagnostics. | Broad match | GAUSS exposes diagnostics through a helper rather than embedding them in every estimator output; BG/RESET use stored fitted values because full design matrices are not retained uniformly. |
| Stability plots/tests | Imports/help entries for `cusum` and `cumsq`; `graph_save` can display stability plots. | CUSUM/CUSUMSQ residual stability diagnostics and QARDL/rolling plot helpers. | Partial | GAUSS has diagnostics and richer QARDL plotting; R integrates stability plots into ARDL/NARDL workflows. |
| ARCH helper | `ArchTest` help is imported from the R `nardl` package and used in diagnostics. | ARCH LM is available through `ardlResidualDiagnostics()`. | Broad match | GAUSS does not expose a standalone `ArchTest` utility, but the model diagnostic workflow now reports ARCH LM rows. |
| Matrix lag helper | `lagm()` is exported. | Lag construction is internal, not a public utility. | R-only utility | Low priority unless users need a public helper. |
| Output renaming helper | `output_ren()` renames NARDL UECM summary rows. | No exact equivalent; generic table export controls output format. | R-only utility | GAUSS may not need this if table exports expose labels sufficiently. |
| Example datasets | `expectation`, `fuel_price`, `ssa`, and `syg_data`. | Synthetic validation fixtures and examples, but no matching public data commands. | R-only | Consider adding optional replication datasets only if licensing/source provenance is clear. |
| Formula strings | Variables supplied by character names in R data frames. | Formula support through `applyQARDLFormula`, `applyNARDLFormula`, and CS-ARDL formula paths. | Match | Syntax differs by language. |
| Robust/HAC covariance | `F_HC` affects GETS F-statistic handling. | QARDL robust/HAC levels and ECM covariance; OLS ARDL/NARDL remain baseline OLS. | Partial | GAUSS is broader for QARDL; R exposes HC behavior in GETS workflows. |
| QARDL levels estimation | Not in `ardl.nardl`. | `qardl()`, `qardlRobust()`, `qardlHAC()`, `qardlX()`. | GAUSS-only | Major scope beyond the R package. |
| QARDL ECM estimation | Not in `ardl.nardl`. | `qardlECM()`, `qardlECMRobust()`, `qardlECMHAC()`, `qardlECMX()` with `ecm_type = "two-step"` or `"uecm"`. | GAUSS-only | Quantile restricted and unrestricted ECM workflows. |
| QARDL lag selection/full workflow | Not in `ardl.nardl`. | `qardlFull()` and documented `pqSelect`; legacy `pqorder*` and `pqorderX*` aliases remain callable. | GAUSS-only | Includes IC selection, scalar GETS selection, restricted grids, and per-regressor lag vector support. |
| QARDL inference tests | Not in `ardl.nardl`. | `qardl_pval`, `qardl_pval_ecm`, `wtestlrb`, `wtestsrp`, `wtestsrg`, `wtestconst`, `wtestsym`. | GAUSS-only | Quantile-specific inference surface. |
| QARDL bootstrap and QIRF | Not in `ardl.nardl`. | `blockBootstrapQARDL*`, `blockBootstrapQARDLECM*`, `qirf`, `blockBootstrapQIRF`. | GAUSS-only | Major GAUSS extension. |
| Rolling QARDL | Not in `ardl.nardl`. | `rollingQardl()`, `rollingQardlECM()`, and plot helpers. | GAUSS-only | Major GAUSS extension. |
| CS-ARDL panel estimation | Not in `ardl.nardl`. | `csardl()`, `csardlECM(..., ecm_type)`, `csardlFull()`, `csardlOrder*`. | GAUSS-only | Major GAUSS extension into panel ARDL. |
| CS-ARDL diagnostics | Not in `ardl.nardl`. | `csardlDiagnostics()` with Pesaran CD/CD(p), Pesaran-Yamagata slope homogeneity, mean-group and poolability diagnostics. | GAUSS-only | Full panel diagnostic surface is outside R package scope. |
| Unified prediction | Not a primary exported `ardl.nardl` surface. | `predictARDL()` dispatches across ARDL, QARDL, NARDL, and CS-ARDL. | GAUSS-only | R users can use fitted/model objects, but no comparable package-level dispatcher. |
| Unified forecasting | Not a primary exported `ardl.nardl` surface. | `forecastARDL()` dispatches across supported model families with point forecasts. | GAUSS-only | Forecast intervals remain deferred in GAUSS. |
| Long-run extraction | Long-run relation appears in estimator outputs. | `ardlLongRun()` extracts long-run coefficients/covariances across families. | GAUSS broader | R has output fields; GAUSS has a generic dispatcher. |
| Table/result export | R returns `lm`, summaries, and lists; external packages can format output. | `saveARDLTable`, `saveARDLMarkdown`, `saveARDLLaTeX`, `saveQARDLResults`, `saveQARDLECMResults`. | GAUSS broader | GAUSS has direct package-level export commands. |
| Cross-implementation validation | Not applicable. | `tests/run_r_package_validation.ps1` validates selected outputs against R. | GAUSS-only | Current required checks cover ARDL levels, ARDL/NARDL UECM validation designs, and public GAUSS NARDL restricted ECM reconstruction. |

## R-Parity Gaps To Prioritize

| Priority | Gap | Why it matters |
| ---: | --- | --- |
| 1 | Standalone sparse GETS outputs | Auto-case sparse UECM pruning exists for ARDL/NARDL; standalone `gets_*_uecm`-style public outputs with term labels and exact `gets.lm` parity are still deferred. |
| 2 | Optional example datasets/replications | Useful for user onboarding, but lower priority than estimator parity. |

## GAUSS Scope Beyond R `ardl.nardl`

The GAUSS library already goes well beyond the R package in several areas:

- QARDL levels, robust/HAC covariance, ECM, per-regressor lag orders, Wald tests,
  plotting, bootstrap intervals, rolling windows, and QIRF.
- CS-ARDL levels/ECM/full workflows with panel diagnostics.
- Unified prediction, forecasting, long-run extraction, and result export across
  ARDL-family output structures.
- Cross-implementation validation and release-oriented documentation.
