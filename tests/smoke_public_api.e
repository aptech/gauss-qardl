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

{ ci_rho, ci_alpha } = blockBootstrapQARDLECM(boot_data, 1, 1, tau, 2, 10, 0.10);
call assert_true(rows(ci_rho) == rows(tau) and cols(ci_rho) == 2, "blockBootstrapQARDLECM rho CI shape changed");
call assert_true(rows(ci_alpha) == rows(tau) and cols(ci_alpha) == 2, "blockBootstrapQARDLECM alpha CI shape changed");

print "smoke_public_api.e: PASS";
