new;

/*
** Release-gate smoke test for the installed GAUSS package catalog.
** Unlike the source-tree tests, this loads `library qardl;` and verifies that
** procedures registered in package.json are callable from the installed app.
**
** Run this after reinstalling/rebuilding the package.
*/

library qardl;

proc (0) = assert_true(ok, msg);
    if not ok;
        errorlog "package_public_api.e failed: " $+ msg;
        end;
    endif;
endp;

data = loadd(__FILE_DIR $+ "../examples/qardl_data.dat");
data = data[1:350, 1:3];
tau = { 0.25, 0.5, 0.75 };

{ pst, qst } = pqorder(data, 2, 2);
call assert_true(pst >= 1 and qst >= 1, "pqorder returned invalid lag orders");
{ pst_aic, qst_aic } = pqorder(data, 2, 2, "aic");
call assert_true(pst_aic >= 1 and qst_aic >= 1, "pqorder AIC returned invalid lag orders");
{ pst_range, qst_range } = pqorderRange(data, 2, 2, 2, 2, "bic");
call assert_true(pst_range == 2 and qst_range == 2, "pqorderRange fixed grid returned invalid lag orders");
ic_grid = pqorderGrid(data, 2, 2, "bic");
ic_range_grid = pqorderRangeGrid(data, 2, 2, 2, 2, "bic");
call assert_true(rows(ic_grid) == 4 and cols(ic_grid) == 3, "pqorderGrid returned wrong shape");
call assert_true(rows(ic_range_grid) == 1 and cols(ic_range_grid) == 3, "pqorderRangeGrid returned wrong shape");

struct qardlOut qaOut;
qaOut = qardl(data, pst, qst, tau);
call assert_true(rows(qaOut.bigbt) == 2*rows(tau), "qardl beta shape changed");

struct qardlECMOut qECMOut;
qECMOut = qardlECM(data, pst, qst, tau);
call assert_true(rows(qECMOut.rho) == rows(tau), "qardlECM rho shape changed");
struct qardlECMOut qECMRobustOut;
qECMRobustOut = qardlECMRobust(data, pst, qst, tau);
call assert_true(rows(qECMRobustOut.rho_cov) == rows(tau) and cols(qECMRobustOut.rho_cov) == rows(tau),
                 "qardlECMRobust rho covariance shape changed");
struct qardlECMOut qECMHACOut;
qECMHACOut = qardlECMHAC(data, pst, qst, tau, 2);
call assert_true(rows(qECMHACOut.rho_cov) == rows(tau) and cols(qECMHACOut.rho_cov) == rows(tau),
                 "qardlECMHAC rho covariance shape changed");
qECMHACOut = qardlECM(data, pst, qst, tau, "hac", 2);
call assert_true(rows(qECMHACOut.rho_cov) == rows(tau), "qardlECM HAC covariance option changed");

{ p_beta, p_phi, p_gamma } = qardl_pval(qaOut);
call assert_true(rows(p_beta) == rows(qaOut.bigbt), "qardl_pval beta p-values shape changed");

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } = wtestconst(qaOut, tau, data);
call assert_true(pv_beta >= 0 and pv_beta <= 1, "wtestconst beta p-value invalid");
call assert_true(pv_gamma >= 0 and pv_gamma <= 1, "wtestconst gamma p-value invalid");
call assert_true(pv_phi >= 0 and pv_phi <= 1, "wtestconst phi p-value invalid");

{ fstat, cv } = ardlbounds(data, pst, qst);
call assert_true(fstat > 0 and rows(cv) == 3 and cols(cv) == 2, "ardlbounds output invalid");

struct qirfOut qiOut;
qiOut = qirf(qaOut, pst, qst, 4, tau);
call assert_true(rows(qiOut.irf) == 5 and cols(qiOut.irf) == rows(tau), "qirf output shape changed");

struct qardlFullOut qfOut;
qfOut = qardlFull(data, 2, 2, tau);
call assert_true(qfOut.pst >= 1 and qfOut.qst >= 1, "qardlFull returned invalid lag orders");
qfOut = qardlFull(data, 2, 2, tau, "", 0, "hq");
call assert_true(qfOut.pst >= 1 and qfOut.qst >= 1, "qardlFull HQ returned invalid lag orders");
{ ci_rho, ci_alpha } = blockBootstrapQARDLECM(data, pst, qst, tau, 2, 10, 0.10);
call assert_true(rows(ci_rho) == rows(tau) and cols(ci_rho) == 2, "blockBootstrapQARDLECM rho CI shape changed");
call assert_true(rows(ci_alpha) == rows(tau) and cols(ci_alpha) == 2, "blockBootstrapQARDLECM alpha CI shape changed");
{ ci_rho_seed, ci_alpha_seed, boot_diag } = blockBootstrapQARDLECMDiag(data, pst, qst, tau, 2, 10, 0.10, 24680);
call assert_true(rows(boot_diag) == 1 and cols(boot_diag) == 5, "blockBootstrapQARDLECMDiag diagnostics shape changed");
call assert_true(boot_diag[1, 1] == 2 and boot_diag[1, 2] == 2 and boot_diag[1, 3] == 0,
                 "blockBootstrapQARDLECMDiag diagnostics content changed");

printQARDLECM(qECMOut, tau);

print "package_public_api.e: PASS";
