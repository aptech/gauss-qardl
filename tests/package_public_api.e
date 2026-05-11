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

proc (1) = make_package_csardl_panel(nunits, tobs);
    local panel, rr, ii, tidx, x1_prev, x2_prev, y_prev, x1v, x2v, yv;

    rndseed 260522;
    panel = zeros(nunits*tobs, 4);
    rr = 1;

    for ii(1, nunits, 1);
        x1_prev = 0;
        x2_prev = 0;
        y_prev = 0;
        for tidx(1, tobs, 1);
            x1v = 0.50*x1_prev + 0.04*tidx + 0.10*ii + rndn(1, 1);
            x2v = 0.35*x2_prev - 0.02*tidx + 0.08*ii + rndn(1, 1);
            yv = 0.42*y_prev + 0.28*x1v - 0.16*x2v + 0.05*ii + 0.15*rndn(1, 1);
            panel[rr, .] = ii~yv~x1v~x2v;
            x1_prev = x1v;
            x2_prev = x2v;
            y_prev = yv;
            rr = rr + 1;
        endfor;
    endfor;

    retp(panel);
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
qaOut = qardl(data, pst, qst, tau, "iid", 0, 0);
call assert_true(rows(qaOut.bigbt) == 2*rows(tau), "qardl beta shape changed");
call assert_true(rows(predictQARDL(qaOut, data)) == qaOut.nobs,
                 "predictQARDL output changed");
call assert_true(rows(forecastQARDL(qaOut, data, 2)) == 2 and cols(forecastQARDL(qaOut, data, 2)) == rows(tau),
                 "forecastQARDL output changed");

struct ardlOut arOut;
arOut = ardl(data, pst, qst, "", 0);
call assert_true(rows(arOut.bigbt) == 2 and arOut.nobs > 0 and arOut.sigma2 > 0,
                 "ardl output changed");
call assert_true(rows(predictARDL(arOut, data)) == arOut.nobs and rows(forecastARDL(arOut, data, 2)) == 2,
                 "ARDL predict/forecast output changed");

struct ardlFullOut afOut;
afOut = ardlFull(data, 2, 2, "", 0, "bic");
call assert_true(afOut.pst >= 1 and afOut.qst >= 0 and afOut.ardl_fstat > 0,
                 "ardlFull output changed");
struct qardlOut qaQ0Out;
qaQ0Out = qardl(data, 2, 0, tau, "iid", 0, 0);
call assert_true(qaQ0Out.q == 0 and rows(qaQ0Out.bigbt) == 2*rows(tau), "qardl q=0 output changed");
qaQ0Out = qardlX(data, 2, { 1, 0 }, tau, "robust", 0, 0);
call assert_true(qaQ0Out.q == 1 and rows(qaQ0Out.bigbt) == 2*rows(tau),
                 "qardlX output changed");
struct qardlOut qaRobustOut;
qaRobustOut = qardlRobust(data, pst, qst, tau, 0);
call assert_true(rows(qaRobustOut.bigbt_cov) == rows(qaOut.bigbt) and cols(qaRobustOut.bigbt_cov) == rows(qaOut.bigbt),
                 "qardlRobust beta covariance shape changed");
struct qardlOut qaHACOut;
qaHACOut = qardlHAC(data, pst, qst, tau, 2, 0);
call assert_true(rows(qaHACOut.bigbt_cov) == rows(qaOut.bigbt) and cols(qaHACOut.bigbt_cov) == rows(qaOut.bigbt),
                 "qardlHAC beta covariance shape changed");
qaHACOut = qardl(data, pst, qst, tau, "hac", 2, 0);
call assert_true(rows(qaHACOut.bigbt_cov) == rows(qaOut.bigbt), "qardl HAC covariance option changed");

struct qardlECMOut qECMOut;
qECMOut = qardlECM(data, pst, qst, tau, "iid", 0, 0);
call assert_true(rows(qECMOut.rho) == rows(tau), "qardlECM rho shape changed");
qECMOut = qardlECM(data, 2, 0, tau, "iid", 0, 0);
call assert_true(qECMOut.q == 0 and rows(qECMOut.rho) == rows(tau), "qardlECM q=0 output changed");
qECMOut = qardlECMX(data, 2, { 1, 0 }, tau, "robust", 0, 0);
call assert_true(qECMOut.q == 1 and rows(qECMOut.rho) == rows(tau),
                 "qardlECMX output changed");
struct qardlECMOut qECMRobustOut;
qECMRobustOut = qardlECMRobust(data, pst, qst, tau, 0);
call assert_true(rows(qECMRobustOut.rho_cov) == rows(tau) and cols(qECMRobustOut.rho_cov) == rows(tau),
                 "qardlECMRobust rho covariance shape changed");
struct qardlECMOut qECMHACOut;
qECMHACOut = qardlECMHAC(data, pst, qst, tau, 2, 0);
call assert_true(rows(qECMHACOut.rho_cov) == rows(tau) and cols(qECMHACOut.rho_cov) == rows(tau),
                 "qardlECMHAC rho covariance shape changed");
qECMHACOut = qardlECM(data, pst, qst, tau, "hac", 2, 0);
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

nt = 80;
tseq = seqa(1, 1, nt);
nardl_data = (1 + 0.45*sin(tseq/3) - 0.20*cos(tseq/5) + 0.10*sin(tseq/2))~sin(tseq/3)~cos(tseq/5);
nardl_df = asDF(nardl_data, "y", "x1", "x2");

struct nardlOut naOut;
naOut = nardl(nardl_data, 1, 1, "", 0);
call assert_true(rows(naOut.beta_pos) == 2 and rows(naOut.asymmetry_pv) == 2,
                 "nardl output changed");

struct nardlFullOut nfOut;
nfOut = nardlFull(nardl_df, 1, 1, "y ~ x1 + x2", 0);
call assert_true(nfOut.pst == 1 and nfOut.qst >= 0 and rows(nfOut.na.beta_neg) == 2,
                 "nardlFull formula output changed");
call assert_true(rows(predictNARDL(nfOut.na, nardl_df, "y ~ x1 + x2")) == nfOut.na.nobs,
                 "predictNARDL formula output changed");

panel = make_package_csardl_panel(4, 60);
panel_df = asDF(panel, "unit", "y", "x1", "x2");

struct csardlOut csaOut;
csaOut = csardl(panel, 1, 1, 1, "", 0);
call assert_true(csaOut.nunits == 4 and rows(csaOut.bigbt) == 2,
                 "csardl output changed");

struct csardlFullOut cfOut;
cfOut = csardlFull(panel_df, 1, 1, 1, "unit + y ~ x1 + x2", 0);
call assert_true(cfOut.cs_lags == 1 and cfOut.csa.nunits == 4,
                 "csardlFull formula output changed");

struct csardlDiagOut diagOut;
diagOut = csardlDiagnostics(panel_df, 1, 1, 1, "unit + y ~ x1 + x2", 0);
call assert_true(diagOut.poolability_df == 6 and diagOut.poolability_pv >= 0 and diagOut.poolability_pv <= 1,
                 "csardlDiagnostics output changed");
call assert_true(rows(forecastCSARDL(cfOut.csa, panel_df, 2, "unit + y ~ x1 + x2")) == 2,
                 "forecastCSARDL formula output changed");

printQARDLECM(qECMOut, tau);

print "package_public_api.e: PASS";
