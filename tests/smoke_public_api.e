new;

/*
** Smoke tests for the source tree. These tests intentionally include the local
** source files instead of loading `library qardl`, so they are not masked by a
** stale installed GAUSS package catalog.
*/

#include ../src/qardl.sdf
#include ../src/qardl.src
#include ../src/wtestlrb.src
#include ../src/wtestsrp.src
#include ../src/wtestsrg.src
#include ../src/icmean.src
#include ../src/p_values_qardl.src
#include ../src/wtestsym.src
#include ../src/wtestconst.src
#include ../src/ardlbounds.src
#include ../src/qirf.src

proc (0) = assert_true(ok, msg);
    if not ok;
        errorlog "smoke_public_api.e failed: " $+ msg;
        end;
    endif;
endp;

proc (0) = assert_close(actual, expected, tol, msg);
    if maxc(abs(actual - expected)) > tol;
        errorlog "smoke_public_api.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(maxc(abs(actual - expected)), "%g", 1, 0);
        end;
    endif;
endp;

data = loadd(__FILE_DIR $+ "../examples/qardl_data.dat");
data = data[., 1:3];
tau = { 0.25, 0.5, 0.75 };

// Core lag selection and QARDL estimation.
{ pst, qst } = pqorder(data, 3, 3);
call assert_true(pst >= 1 and qst >= 1, "pqorder returned invalid lag orders");
{ pst_aic, qst_aic } = pqorder(data, 3, 3, "aic");
{ pst_hq, qst_hq } = pqorder(data, 3, 3, "hq");
{ pst_rect, qst_rect } = pqorder(data, 2, 3, "bic");
{ pst_range, qst_range } = pqorderRange(data, 2, 3, 2, 3, "bic");
ic_grid = pqorderGrid(data, 2, 3, "bic");
ic_range_grid = pqorderRangeGrid(data, 2, 3, 2, 3, "bic");
call assert_true(pst_aic >= 1 and qst_aic >= 1, "pqorder AIC returned invalid lag orders");
call assert_true(pst_hq >= 1 and qst_hq >= 1, "pqorder HQ returned invalid lag orders");
call assert_true(pst_rect >= 1 and pst_rect <= 2 and qst_rect >= 1 and qst_rect <= 3,
                 "pqorder rectangular grid returned invalid lag orders");
call assert_true(pst_range >= 2 and qst_range >= 2,
                 "pqorderRange ignored lower lag bounds");
call assert_true(rows(ic_grid) == 6 and cols(ic_grid) == 3, "pqorderGrid returned wrong shape");
call assert_true(rows(ic_range_grid) == 4 and cols(ic_range_grid) == 3, "pqorderRangeGrid returned wrong shape");
best_idx = minindc(ic_grid[., 3]);
call assert_true(ic_grid[best_idx, 1] == pst_rect and ic_grid[best_idx, 2] == qst_rect,
                 "pqorderGrid minimum does not match pqorder");
best_idx = minindc(ic_range_grid[., 3]);
call assert_true(ic_range_grid[best_idx, 1] == pst_range and ic_range_grid[best_idx, 2] == qst_range,
                 "pqorderRangeGrid minimum does not match pqorderRange");
call assert_true(icmean(data, pst, qst) == icmean(data, pst, qst, "bic"), "icmean default criterion changed");

struct qardlOut qaOut;
qaOut = qardl(data, 2, 1, tau);

expected_beta = { 6.6645846,
                  6.6668972,
                  6.6659552,
                  6.6666716,
                  6.6652370,
                  6.6663398 };

call assert_close(qaOut.bigbt, expected_beta, 1e-4, "qardl beta estimates changed");
call assert_true(qaOut.p == 2 and qaOut.q == 1 and qaOut.k == 2, "qardl metadata changed");
call assert_true(rows(qaOut.tau) == rows(tau) and qaOut.nobs > 0, "qardl tau/nobs metadata invalid");
call assert_true(rows(qaOut.alpha) == rows(tau), "qardl alpha has wrong row count");
call assert_true(rows(qaOut.rho) == rows(tau), "qardl rho has wrong row count");
call assert_true(rows(qaOut.bt) == 7 and cols(qaOut.bt) == rows(tau), "qardl bt has wrong shape");

struct qardlOut qaRobustOut;
qaRobustOut = qardlRobust(data, 2, 1, tau);
call assert_close(qaRobustOut.bigbt, qaOut.bigbt, 1e-12, "qardlRobust changed parameter estimates");
call assert_true(rows(qaRobustOut.bigbt_cov) == rows(qaOut.bigbt) and cols(qaRobustOut.bigbt_cov) == rows(qaOut.bigbt),
                 "qardlRobust beta covariance shape changed");
call assert_true(qaRobustOut.bigbt_cov[3, 3] > 0 and qaRobustOut.phi_cov[2, 2] > 0 and qaRobustOut.gamma_cov[3, 3] > 0,
                 "qardlRobust covariance diagonal invalid");

struct qardlOut qaHACOut;
qaHACOut = qardlHAC(data, 2, 1, tau, 2);
call assert_close(qaHACOut.bigbt, qaOut.bigbt, 1e-12, "qardlHAC changed parameter estimates");
call assert_true(rows(qaHACOut.bigbt_cov) == rows(qaOut.bigbt) and cols(qaHACOut.bigbt_cov) == rows(qaOut.bigbt),
                 "qardlHAC beta covariance shape changed");
call assert_true(qaHACOut.bigbt_cov[3, 3] > 0 and qaHACOut.phi_cov[2, 2] > 0 and qaHACOut.gamma_cov[3, 3] > 0,
                 "qardlHAC covariance diagonal invalid");
qaHACOut = qardl(data, 2, 1, tau, "hac", 2);
call assert_true(qaHACOut.bigbt_cov[3, 3] > 0, "qardl HAC covariance option invalid");

// Individual p-values.
{ p_beta, p_phi, p_gamma } = qardl_pval(qaOut);
call assert_true(rows(p_beta) == rows(qaOut.bigbt), "qardl_pval beta p-values have wrong shape");
call assert_true(rows(p_phi) == rows(qaOut.phi), "qardl_pval phi p-values have wrong shape");
call assert_true(rows(p_gamma) == rows(qaOut.gamma), "qardl_pval gamma p-values have wrong shape");

// Two-step ECM estimator and p-values.
struct qardlECMOut qECMOut;
qECMOut = qardlECM(data, 2, 1, tau);
call assert_true(qECMOut.p == 2 and qECMOut.q == 1 and qECMOut.k == 2, "qardlECM metadata changed");
call assert_true(rows(qECMOut.tau) == rows(tau) and qECMOut.nobs > 0, "qardlECM tau/nobs metadata invalid");
call assert_true(rows(qECMOut.rho) == rows(tau), "qardlECM rho has wrong row count");
call assert_true(rows(qECMOut.rho_cov) == rows(tau), "qardlECM rho covariance has wrong row count");

struct qardlECMOut qECMRobustOut;
qECMRobustOut = qardlECMRobust(data, 2, 1, tau);
call assert_true(rows(qECMRobustOut.rho_cov) == rows(tau) and cols(qECMRobustOut.rho_cov) == rows(tau),
                 "qardlECMRobust rho covariance shape changed");
call assert_true(qECMRobustOut.rho_cov[2, 2] > 0 and qECMRobustOut.alpha_cov[2, 2] > 0,
                 "qardlECMRobust covariance diagonal invalid");

struct qardlECMOut qECMHACOut;
qECMHACOut = qardlECMHAC(data, 2, 1, tau, 2);
call assert_true(rows(qECMHACOut.rho_cov) == rows(tau) and cols(qECMHACOut.rho_cov) == rows(tau),
                 "qardlECMHAC rho covariance shape changed");
call assert_true(qECMHACOut.rho_cov[2, 2] > 0 and qECMHACOut.alpha_cov[2, 2] > 0,
                 "qardlECMHAC covariance diagonal invalid");
qECMHACOut = qardlECM(data, 2, 1, tau, "hac", 2);
call assert_true(qECMHACOut.rho_cov[2, 2] > 0, "qardlECM HAC covariance option invalid");

{ p_alpha, p_rho } = qardl_pval_ecm(qECMOut);
call assert_true(rows(p_alpha) == rows(tau), "qardl_pval_ecm alpha p-values have wrong shape");
call assert_true(rows(p_rho) == rows(tau), "qardl_pval_ecm rho p-values have wrong shape");

// Bounds test and automatic Wald tests.
{ fstat, cv } = ardlbounds(data, 2, 1);
call assert_true(rows(cv) == 3 and cols(cv) == 2, "ardlbounds critical-value shape changed");
call assert_true(fstat > 0, "ardlbounds F-statistic should be positive");

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } = wtestconst(qaOut, tau, data);
call assert_true(wt_beta >= 0 and pv_beta >= 0 and pv_beta <= 1, "wtestconst beta output invalid");
call assert_true(wt_gamma >= 0 and pv_gamma >= 0 and pv_gamma <= 1, "wtestconst gamma output invalid");
call assert_true(wt_phi >= 0 and pv_phi >= 0 and pv_phi <= 1, "wtestconst phi output invalid");

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } = wtestsym(qaOut, tau, data);
call assert_true(wt_beta >= 0 and pv_beta >= 0 and pv_beta <= 1, "wtestsym beta output invalid");
call assert_true(wt_gamma >= 0 and pv_gamma >= 0 and pv_gamma <= 1, "wtestsym gamma output invalid");
call assert_true(wt_phi >= 0 and pv_phi >= 0 and pv_phi <= 1, "wtestsym phi output invalid");

// QIRF public API.
struct qirfOut qiOut;
qiOut = qirf(qaOut, 2, 1, 8, tau);
call assert_true(rows(qiOut.irf) == 9 and cols(qiOut.irf) == rows(tau), "qirf output shape changed");

// Small bootstrap smoke checks. Keep B tiny; this validates API/shape, not inference quality.
boot_data = data[1:250, .];
{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDL(boot_data, 1, 1, tau, 2, 10, 0.10);
call assert_true(rows(ci_beta) == 2*rows(tau) and cols(ci_beta) == 2, "blockBootstrapQARDL beta CI shape changed");
call assert_true(rows(ci_gamma) == 2*rows(tau) and cols(ci_gamma) == 2, "blockBootstrapQARDL gamma CI shape changed");
call assert_true(rows(ci_phi) == rows(tau) and cols(ci_phi) == 2, "blockBootstrapQARDL phi CI shape changed");
{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDLMethod(boot_data, 1, 1, tau, 2, 10, 0.10, "circular");
call assert_true(rows(ci_beta) == 2*rows(tau) and cols(ci_beta) == 2, "blockBootstrapQARDLMethod circular shape changed");
{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDLMethod(boot_data, 1, 1, tau, 2, 10, 0.10, "stationary");
call assert_true(rows(ci_phi) == rows(tau) and cols(ci_phi) == 2, "blockBootstrapQARDLMethod stationary shape changed");

{ ci_rho, ci_alpha } = blockBootstrapQARDLECM(boot_data, 1, 1, tau, 2, 10, 0.10);
call assert_true(rows(ci_rho) == rows(tau) and cols(ci_rho) == 2, "blockBootstrapQARDLECM rho CI shape changed");
call assert_true(rows(ci_alpha) == rows(tau) and cols(ci_alpha) == 2, "blockBootstrapQARDLECM alpha CI shape changed");
{ ci_rho, ci_alpha } = blockBootstrapQARDLECMMethod(boot_data, 1, 1, tau, 2, 10, 0.10, "circular");
call assert_true(rows(ci_rho) == rows(tau) and cols(ci_rho) == 2, "blockBootstrapQARDLECMMethod circular shape changed");
{ ci_rho, ci_alpha } = blockBootstrapQARDLECMMethod(boot_data, 1, 1, tau, 2, 10, 0.10, "stationary");
call assert_true(rows(ci_alpha) == rows(tau) and cols(ci_alpha) == 2, "blockBootstrapQARDLECMMethod stationary shape changed");

{ ci_beta_seed1, ci_gamma_seed1, ci_phi_seed1, boot_diag1 } =
    blockBootstrapQARDLDiag(boot_data, 1, 1, tau, 2, 10, 0.10, 12345);
{ ci_beta_seed2, ci_gamma_seed2, ci_phi_seed2, boot_diag2 } =
    blockBootstrapQARDLDiag(boot_data, 1, 1, tau, 2, 10, 0.10, 12345);
call assert_close(ci_beta_seed1, ci_beta_seed2, 1e-12, "blockBootstrapQARDLDiag seed reproducibility failed");
call assert_close(ci_gamma_seed1, ci_gamma_seed2, 1e-12, "blockBootstrapQARDLDiag gamma seed reproducibility failed");
call assert_close(ci_phi_seed1, ci_phi_seed2, 1e-12, "blockBootstrapQARDLDiag phi seed reproducibility failed");
call assert_true(rows(boot_diag1) == 1 and cols(boot_diag1) == 5, "blockBootstrapQARDLDiag diagnostics shape changed");
call assert_true(boot_diag1[1, 1] == 2 and boot_diag1[1, 2] == 2 and boot_diag1[1, 3] == 0 and
                 boot_diag1[1, 4] == 10 and boot_diag1[1, 5] == 12345,
                 "blockBootstrapQARDLDiag diagnostics content changed");

{ ci_rho_seed1, ci_alpha_seed1, boot_ecm_diag1 } =
    blockBootstrapQARDLECMDiag(boot_data, 1, 1, tau, 2, 10, 0.10, 67890);
{ ci_rho_seed2, ci_alpha_seed2, boot_ecm_diag2 } =
    blockBootstrapQARDLECMDiag(boot_data, 1, 1, tau, 2, 10, 0.10, 67890);
call assert_close(ci_rho_seed1, ci_rho_seed2, 1e-12, "blockBootstrapQARDLECMDiag rho seed reproducibility failed");
call assert_close(ci_alpha_seed1, ci_alpha_seed2, 1e-12, "blockBootstrapQARDLECMDiag alpha seed reproducibility failed");
call assert_true(rows(boot_ecm_diag1) == 1 and cols(boot_ecm_diag1) == 5, "blockBootstrapQARDLECMDiag diagnostics shape changed");

// Rolling estimators on a small sample and a small lag-search grid.
struct waldTestRestrictions waldR;
waldR.bigR_beta = zeros(1, 2*rows(tau));
waldR.bigR_beta[1, 1] = 1;
waldR.bigR_beta[1, 3] = -1;
waldR.smlr_beta = 0;

waldR.bigR_phi = zeros(1, rows(tau));
waldR.bigR_phi[1, 1] = 1;
waldR.bigR_phi[1, 2] = -1;
waldR.smlr_phi = 0;

waldR.bigR_gamma = waldR.bigR_beta;
waldR.smlr_gamma = 0;

roll_data = data[1:300, .];
struct rollingQardlOut rqaOut;
rqaOut = rollingQardl(roll_data, 1, 1, tau, waldR);
roll_dims = getorders(rqaOut.bigbt);
call assert_true(roll_dims[1] == 2 and roll_dims[3] == rows(tau), "rollingQardl beta array dimensions changed");

struct rollingQardlECMOut rECMOut;
rECMOut = rollingQardlECM(roll_data, 1, 1, tau);
call assert_true(cols(rECMOut.rho) == rows(tau) and rows(rECMOut.rho) > 0, "rollingQardlECM rho shape changed");

print "smoke_public_api.e: PASS";
