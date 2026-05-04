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
call assert_true(pst >= 1 and qst >= 0, "pqorder returned invalid lag orders");
{ pst_aic, qst_aic } = pqorder(data, 2, 2, "aic");
call assert_true(pst_aic >= 1 and qst_aic >= 0, "pqorder AIC returned invalid lag orders");
{ pst_range, qst_range } = pqorderRange(data, 2, 2, 2, 2, "bic");
call assert_true(pst_range == 2 and qst_range == 2, "pqorderRange fixed grid returned invalid lag orders");
ic_grid = pqorderGrid(data, 2, 2, "bic");
ic_range_grid = pqorderRangeGrid(data, 2, 2, 2, 2, "bic");
call assert_true(rows(ic_grid) == 6 and cols(ic_grid) == 3, "pqorderGrid returned wrong shape");
call assert_true(rows(ic_range_grid) == 1 and cols(ic_range_grid) == 3, "pqorderRangeGrid returned wrong shape");
{ pst_x, qst_x } = pqorderX(data, 2, 1, "bic");
ic_x_grid = pqorderXGrid(data, 2, 1, "bic");
call assert_true(pst_x >= 1 and rows(qst_x) == 2 and rows(ic_x_grid) == 8 and cols(ic_x_grid) == 4,
                 "pqorderX output invalid");

struct qardlOut qaOut;
qaOut = qardl(data, pst, qst, tau);
call assert_true(rows(qaOut.bigbt) == 2*rows(tau), "qardl beta shape changed");
struct qardlOut qaQ0Out;
qaQ0Out = qardl(data, 2, 0, tau);
call assert_true(qaQ0Out.q == 0 and rows(qaQ0Out.bigbt) == 2*rows(tau), "qardl q=0 output changed");
qaQ0Out = qardlX(data, 2, { 1, 0 }, tau);
call assert_true(qaQ0Out.q == 1 and rows(qaQ0Out.bigbt) == 2*rows(tau),
                 "qardlX output changed");
struct qardlOut qaRobustOut;
qaRobustOut = qardlRobust(data, pst, qst, tau);
call assert_true(rows(qaRobustOut.bigbt_cov) == rows(qaOut.bigbt) and cols(qaRobustOut.bigbt_cov) == rows(qaOut.bigbt),
                 "qardlRobust beta covariance shape changed");
struct qardlOut qaHACOut;
qaHACOut = qardlHAC(data, pst, qst, tau, 2);
call assert_true(rows(qaHACOut.bigbt_cov) == rows(qaOut.bigbt) and cols(qaHACOut.bigbt_cov) == rows(qaOut.bigbt),
                 "qardlHAC beta covariance shape changed");
qaHACOut = qardl(data, pst, qst, tau, "hac", 2);
call assert_true(rows(qaHACOut.bigbt_cov) == rows(qaOut.bigbt), "qardl HAC covariance option changed");

struct qardlECMOut qECMOut;
qECMOut = qardlECM(data, pst, qst, tau);
call assert_true(rows(qECMOut.rho) == rows(tau), "qardlECM rho shape changed");
qECMOut = qardlECM(data, 2, 0, tau);
call assert_true(qECMOut.q == 0 and rows(qECMOut.rho) == rows(tau), "qardlECM q=0 output changed");
qECMOut = qardlECMX(data, 2, { 1, 0 }, tau);
call assert_true(qECMOut.q == 1 and rows(qECMOut.rho) == rows(tau),
                 "qardlECMX output changed");
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
{ fstat_case, tstat_case, cv, case_id, q_restrict } = ardlboundsCase(data, 2, 1, 4);
call assert_true(case_id == 4 and cv[2, 1] == 3.88 and cv[2, 2] == 4.61,
                 "ardlboundsCase Case IV table lookup invalid");
cv = ardlboundsCaseSimCV(2, 4, 80, 100, 12345);
call assert_true(rows(cv) == 3 and cols(cv) == 2 and cv[2, 2] > cv[2, 1],
                 "ardlboundsCaseSimCV output invalid");
{ fstat_case, tstat_case, cv_case, case_id, q_restrict } = ardlboundsCase(data, pst, qst, 3);
call assert_true(fstat_case > 0 and tstat_case < 0 and case_id == 3, "ardlboundsCase output invalid");

struct qirfOut qiOut;
qiOut = qirf(qaOut, pst, qst, 4, tau);
call assert_true(rows(qiOut.irf) == 5 and cols(qiOut.irf) == rows(tau), "qirf output shape changed");

struct qardlFullOut qfOut;
qfOut = qardlFull(data, 2, 2, tau);
call assert_true(qfOut.pst >= 1 and qfOut.qst >= 1, "qardlFull returned invalid lag orders");
qfOut = qardlFull(data, 2, 2, tau, "", 0, "hq");
call assert_true(qfOut.pst >= 1 and qfOut.qst >= 1, "qardlFull HQ returned invalid lag orders");
qfOut = qardlFull(data, 2, 2, tau, "", 0, "bic", "robust", 0);
call assert_true(rows(qfOut.qa.bigbt_cov) == rows(qfOut.qa.bigbt), "qardlFull robust covariance changed");
{ ci_rho, ci_alpha } = blockBootstrapQARDLECM(data, pst, qst, tau, 2, 10, 0.10);
call assert_true(rows(ci_rho) == rows(tau) and cols(ci_rho) == 2, "blockBootstrapQARDLECM rho CI shape changed");
call assert_true(rows(ci_alpha) == rows(tau) and cols(ci_alpha) == 2, "blockBootstrapQARDLECM alpha CI shape changed");
{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDLMethod(data, pst, qst, tau, 2, 10, 0.10, "circular");
call assert_true(rows(ci_beta) == 2*rows(tau) and cols(ci_beta) == 2, "blockBootstrapQARDLMethod output changed");
{ ci_rho, ci_alpha } = blockBootstrapQARDLECMMethod(data, pst, qst, tau, 2, 10, 0.10, "stationary");
call assert_true(rows(ci_rho) == rows(tau) and cols(ci_rho) == 2, "blockBootstrapQARDLECMMethod output changed");
{ ci_rho_seed, ci_alpha_seed, boot_diag } = blockBootstrapQARDLECMDiag(data, pst, qst, tau, 2, 10, 0.10, 24680);
call assert_true(rows(boot_diag) == 1 and cols(boot_diag) == 5, "blockBootstrapQARDLECMDiag diagnostics shape changed");
call assert_true(boot_diag[1, 1] == 2 and boot_diag[1, 2] == 2 and boot_diag[1, 3] == 0,
                 "blockBootstrapQARDLECMDiag diagnostics content changed");

printQARDLECM(qECMOut, tau);

print "package_public_api.e: PASS";
