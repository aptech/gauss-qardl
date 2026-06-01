new;

/*
** Smoke tests for NARDL and CS-ARDL APIs.
** TODO: Add published-result validation cases once reference datasets and
**       specifications are available.
*/

#include ../src/qardl.sdf
#include ../src/qardl.src
#include ../src/nardl.src
#include ../src/csardl.src
#include ../src/ardl_dispatch.src
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
        errorlog "smoke_nardl_csardl_api.e failed: " $+ msg;
        end;
    endif;
endp;

proc (0) = assert_close(actual, expected, tol, msg);
    if maxc(abs(actual - expected)) > tol;
        errorlog "smoke_nardl_csardl_api.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(maxc(abs(actual - expected)), "%g", 1, 0);
        end;
    endif;
endp;

/*
** Formula hooks use the same dataframe parser surface as the rest of the
** library.  CS-ARDL uses GAUSS-style inferred panel id/time variables.
*/
shiller = loadd(__FILE_DIR $+ "../examples/shiller_stocks_qt.csv",
                "date($date) + real_price + real_dividend + real_earnings");
nardl_formula_data = applyNARDLFormula(shiller, "real_dividend ~ real_earnings + real_price");
call assert_true(cols(nardl_formula_data) == 3, "applyNARDLFormula did not select y and regressors");
call assert_true(maxc(abs(nardl_formula_data[., 1] - shiller[., "real_dividend"])) < 1e-12,
                 "applyNARDLFormula did not place y in column 1");

cs_formula_df = asDF(("b" $| "b" $| "a" $| "a"), "unit")~
                asDF(({ 2, 1, 2, 1 }~{ 4, 3, 2, 1 }~{ 40, 30, 20, 10 }),
                     "time", "y", "x1");
cs_formula_df = dftype(cs_formula_df, META_TYPE_CATEGORY, "unit");
cs_formula_data = applyCSARDLFormula(cs_formula_df, "y ~ x1");
call assert_true(cols(cs_formula_data) == 3, "applyCSARDLFormula did not select unit, y, and regressors");
call assert_close(cs_formula_data[., 2:3], { 1 10, 2 20, 3 30, 4 40 }, 1e-12,
                  "applyCSARDLFormula did not infer and sort panel id/time variables");
cs_explicit_df = asDF(({ 99, 98, 97, 96 }~{ 2, 2, 1, 1 }~{ 2, 1, 2, 1 }~
                       { 4, 3, 2, 1 }~{ 40, 30, 20, 10 }),
                     "row_order", "panel_id", "period", "y", "x1");
cs_explicit_data = applyCSARDLFormula(cs_explicit_df, "y ~ x1", "panel_id", "period");
call assert_close(cs_explicit_data[., 2:3], { 1 10, 2 20, 3 30, 4 40 }, 1e-12,
                  "applyCSARDLFormula explicit group/time variables changed ordering");

/*
** NARDL deterministic checks.
*/
n = 80;
t = seqa(1, 1, n);
x1 = sin(t/3);
x2 = cos(t/5);
y = 1 + 0.45*x1 - 0.20*x2 + 0.10*sin(t/2);
nardl_data = y~x1~x2;

struct nardlOut naOut;
naOut = nardl(nardl_data, 1, 1, "", 0);

{ nY, nX, npos, nneg } =
    _nardlBuildDesign(nardl_data, 1, 1, _nardlInfThresh(2));
expected_bt = _qardlSafeInv(nX'*nX, "smoke_nardl", "expected NARDL moment matrix")*nX'*nY;
expected_resid = nY - nX*expected_bt;
{ expected_cov, expected_sigma2 } = _nardlOLSCov(nX, expected_resid, "smoke_nardl");
expected_bigbt_cov = _nardlLongRunCov(expected_bt, expected_cov, 1, 1, 2);
expected_phi = expected_bt[6];
expected_beta_pos = expected_bt[2:3] ./ (1 - expected_phi);
expected_beta_neg = expected_bt[4:5] ./ (1 - expected_phi);

call assert_close(naOut.bt, expected_bt, 1e-10, "nardl bt does not match levels design");
call assert_close(naOut.bigbt, expected_beta_pos | expected_beta_neg, 1e-10,
                  "nardl long-run coefficients do not match formula");
call assert_close(naOut.bigbt_cov, expected_bigbt_cov, 1e-10,
                  "nardl long-run covariance does not match delta method");
{ lr_beta, lr_cov } = ardlLongRun(naOut);
call assert_close(lr_beta, naOut.bigbt, 1e-12, "ardlLongRun NARDL beta changed");
call assert_close(lr_cov, naOut.bigbt_cov, 1e-12, "ardlLongRun NARDL covariance changed");
call assert_true(rows(naOut.asymmetry_wald) == 2 and minc(naOut.asymmetry_pv) >= 0 and maxc(naOut.asymmetry_pv) <= 1,
                 "nardl asymmetry tests invalid");
call assert_true(naOut.bounds_fstat > 0 and naOut.sigma2 > 0,
                 "nardl diagnostics invalid");
call assert_true(naOut.nobs == rows(nY) and naOut.k == 2 and naOut.p == 1 and naOut.q == 1,
                 "nardl metadata invalid");
call assert_true(rows(naOut.decomp_thresholds) == 2 and minc(naOut.decomp_thresholds .> 1e200),
                 "nardl default threshold metadata invalid");

nardl_fit = predictNARDL(naOut, nardl_data);
call assert_close(nardl_fit, nX*expected_bt, 1e-10, "predictNARDL did not use stored design");
call assert_close(predictARDL(naOut, nardl_data), nardl_fit, 1e-10,
                  "predictARDL NARDL dispatch changed fitted values");
nardl_fcst = forecastNARDL(naOut, nardl_data, 3);
call assert_true(rows(nardl_fcst) == 3 and cols(nardl_fcst) == 1,
                 "forecastNARDL returned wrong shape");
call assert_close(forecastARDL(naOut, nardl_data, 3), nardl_fcst, 1e-10,
                  "forecastARDL NARDL dispatch changed forecasts");
struct nardlDynMultOut dmOut;
dmOut = nardlDynamicMultipliers(naOut, 4);
call assert_true(rows(dmOut.pos) == 5 and cols(dmOut.pos) == naOut.k and
                 rows(dmOut.neg) == 5 and rows(dmOut.asymmetry) == 5,
                 "nardlDynamicMultipliers output shape changed");
call assert_close(dmOut.asymmetry, dmOut.pos - dmOut.neg, 1e-12,
                  "nardlDynamicMultipliers asymmetry calculation changed");

/*
** Explicit NARDL decomposition/control checks.  x1 is decomposed while x2
** remains a linear control, matching the R-style decomp/control workflow.
*/
struct nardlOut nsOut;
nsOut = nardl(nardl_data, 1, 0, print_results = 0, decomp_vars = "x1",
              control_vars = "x2", q_decomp = 1, q_control = 1);
{ nY, nX, npos, nneg } =
    _nardlBuildSpecDesign(nardl_data, 1, 1, { 1 }, { 2 }, 1,
                          _nardlInfThresh(1));
expected_bt = _qardlSafeInv(nX'*nX, "smoke_nardl_spec", "expected NARDL spec moment matrix")*nX'*nY;
expected_resid = nY - nX*expected_bt;
{ expected_cov, expected_sigma2 } = _nardlOLSCov(nX, expected_resid, "smoke_nardl_spec");
expected_bigbt_cov = _nardlLongRunSpecCov(expected_bt, expected_cov, 1, 1, 1);
expected_phi = expected_bt[5];
expected_beta_pos = expected_bt[2] ./ (1 - expected_phi);
expected_beta_neg = expected_bt[3] ./ (1 - expected_phi);
expected_beta_control = expected_bt[4] ./ (1 - expected_phi);

call assert_close(nsOut.bt, expected_bt, 1e-10, "nardl optional spec bt does not match explicit design");
call assert_close(nsOut.bigbt, expected_beta_pos | expected_beta_neg | expected_beta_control, 1e-10,
                  "nardl optional spec long-run coefficients changed");
call assert_close(nsOut.bigbt_cov, expected_bigbt_cov, 1e-10,
                  "nardl optional spec long-run covariance changed");
call assert_true(nsOut.ndecomp == 1 and nsOut.ncontrol == 1 and nsOut.k == 2 and
                 nsOut.decomp_vars[1] $== "x1" and nsOut.control_vars[1] $== "x2",
                 "nardl optional spec metadata invalid");
call assert_true(rows(nsOut.asymmetry_wald) == 1 and rows(nsOut.beta_control) == 1,
                 "nardl optional spec asymmetry/control output shape invalid");
call assert_close(predictNARDL(nsOut, nardl_data), nX*expected_bt, 1e-10,
                  "predictNARDL optional spec output changed");
call assert_true(rows(forecastNARDL(nsOut, nardl_data, 2)) == 2,
                 "forecastNARDL optional spec output shape invalid");

struct nardlOut nthOut;
nthOut = nardl(nardl_data, 1, 0, "", 0, "x1", "x2", 1, 1, 0.50);
call assert_true(rows(nthOut.decomp_thresholds) == 1 and nthOut.decomp_thresholds[1] == 0.50,
                 "nardl scalar threshold metadata invalid");
{ nY, nX, npos, nneg } =
    _nardlBuildSpecDesign(nardl_data, 1, 1, { 1 }, { 2 }, 1, 0.50);
call assert_close(nthOut.bt,
                  _qardlSafeInv(nX'*nX, "smoke_nardl_thresh", "threshold moment matrix")*nX'*nY,
                  1e-10, "nardl threshold bt does not match threshold design");

struct nardlECMOut nthECM;
nthECM = nardlECM(nardl_data, 1, 0, "", 0, "x1", "x2", 1, 1,
                  "uecm", 3, 0.50);
call assert_true(nthECM.decomp_thresholds[1] == 0.50 and nthECM.ecm_type $== "uecm",
                 "nardlECM threshold metadata invalid");

struct nardlOut nsAutoControl;
nsAutoControl = nardl(nardl_data, 1, 1, "", 0, "x1", "", -1, 1);
call assert_close(nsAutoControl.bt, nsOut.bt, 1e-10,
                  "nardl automatic control complement changed");

struct nardlECMOut nsECMOut;
nsECMOut = nardlECM(nardl_data, 1, 0, print_results = 0, decomp_vars = "x1",
                    control_vars = "x2", q_decomp = 1, q_control = 1);
call assert_true(nsECMOut.ndecomp == 1 and nsECMOut.ncontrol == 1 and
                 rows(nsECMOut.beta_control) == 1 and nsECMOut.sigma2 > 0,
                 "nardlECM optional spec metadata invalid");

struct nardlECMOut nECMOut;
nECMOut = nardlECM(nardl_data, 1, 1, "", 0);
call assert_true(nECMOut.nobs == n - 2 and nECMOut.k == 2,
                 "nardlECM metadata invalid");
call assert_true(rows(nECMOut.beta_pos) == 2 and rows(nECMOut.beta_neg) == 2,
                 "nardlECM long-run fields invalid");
call assert_true(nECMOut.sigma2 > 0 and rows(nECMOut.bt) > 2,
                 "nardlECM diagnostics invalid");
nECMOut = nardlECM(nardl_data, 1, 1, "", 0, "", "", -1, 0, "uecm");
call assert_true(nECMOut.ecm_type $== "uecm" and nECMOut.nobs == n - 2 and
                 rows(nECMOut.beta_pos) == 2 and rows(nECMOut.beta_neg) == 2,
                 "nardlECM UECM option metadata invalid");
call assert_true(rows(nECMOut.bt) == 10 and nECMOut.sigma2 > 0,
                 "nardlECM UECM option output shape invalid");
nECMOut = nardlECM(nardl_data, 1, 1, "", 0, "", "", -1, 0, "uecm", 1);
call assert_true(nECMOut.deterministic $== "case I: no intercept, no trend" and
                 rows(nECMOut.bt) == 9 and nECMOut.alpha == 0,
                 "nardlECM Case I UECM output invalid");
nECMOut = nardlECM(nardl_data, 1, 1, "", 0, "", "", -1, 0, "uecm", 5);
call assert_true(nECMOut.deterministic $== "case V: unrestricted intercept, unrestricted trend" and
                 rows(nECMOut.bt) == 11 and rows(nECMOut.beta_pos) == 2,
                 "nardlECM Case V UECM output invalid");

struct nardlFullOut nfOut;
nfOut = nardlFull(nardl_data, 1, 1, "", 0);
nardl_grid = nardlOrderGrid(nardl_data, 1, 1);
call assert_true(nfOut.pst == nardl_grid[minindc(nardl_grid[., 3]), 1] and
                 nfOut.qst == nardl_grid[minindc(nardl_grid[., 3]), 2] and
                 nfOut.na.nobs == naOut.nobs,
                 "nardlFull metadata invalid");
nfOut = nardlFull(nardl_data, 1, 1, "", 0, "bic", "x1", "x2", 1);
call assert_true(nfOut.na.ndecomp == 1 and nfOut.na.ncontrol == 1 and
                 nfOut.ecm.ndecomp == 1 and nfOut.ecm.ncontrol == 1,
                 "nardlFull optional spec metadata invalid");
nfOut = nardlFull(nardl_data, 1, 1, "", 0, "bic", "", "", 0, "uecm");
call assert_true(nfOut.ecm.ecm_type $== "uecm" and rows(nfOut.ecm.beta_pos) == 2,
                 "nardlFull UECM option metadata invalid");
nfOut = nardlFull(nardl_data, 1, 1, "", 0, "bic", "", "", 0, "uecm", 0.1, 1);
call assert_true(nfOut.deterministic $== "case I: no intercept, no trend" and
                 rows(nfOut.ecm.bt) == 9,
                 "nardlFull Case I UECM output invalid");

rndseed 260511;
n_default = 120;
x1_default = cumsumc(rndn(n_default, 1));
x2_default = cumsumc(rndn(n_default, 1));
y_default = zeros(n_default, 1);
for tt(2, n_default, 1);
    y_default[tt] = 0.35*y_default[tt-1] + 0.45*x1_default[tt] - 0.25*x2_default[tt] + 0.10*rndn(1, 1);
endfor;
default_nardl_data = y_default~x1_default~x2_default;
nfOut = nardlFull(default_nardl_data, verbose = 0);
call assert_true(nfOut.pst >= 1 and nfOut.pst <= 8 and nfOut.qst >= 0 and nfOut.qst <= 8,
                 "nardlFull default lag bounds invalid");
{ n_p_gets, n_q_gets } = nardlOrder(default_nardl_data, 2, 2, "gets", 0.1);
call assert_true(n_p_gets >= 1 and n_p_gets <= 2 and
                 n_q_gets >= 0 and n_q_gets <= 2,
                 "nardlOrder GETS returned invalid lag orders");
nfOut = nardlFull(default_nardl_data, 2, 2, "", 0, "gets", "x1", "x2", 1,
                  "uecm", 0.1);
call assert_true(nfOut.selection_criterion $== "gets" and nfOut.pst >= 1 and
                 nfOut.pst <= 2 and nfOut.qst >= 0 and nfOut.qst <= 2 and
                 nfOut.ecm.ecm_type $== "uecm",
                 "nardlFull GETS output invalid");

struct nardlAutoCaseOut nacOut;
nacOut = nardlAutoCase(default_nardl_data, 2, 2, "", 0, "x1", "x2", 1, 0.1);
call assert_true(nacOut.selection_criterion $== "gets" and nacOut.pst >= 1 and
                 nacOut.pst <= 2 and nacOut.qst >= 0 and nacOut.qst <= 2,
                 "nardlAutoCase lag metadata invalid");
call assert_true(nacOut.case_count == rows(nacOut.case_ids) and
                 rows(nacOut.bounds_table) == nacOut.case_count and
                 cols(nacOut.bounds_table) == 10,
                 "nardlAutoCase case/bounds metadata invalid");
call assert_true(nacOut.primary_case == nacOut.case_ids[rows(nacOut.case_ids)] and
                 nacOut.ecm.ecm_type $== "uecm" and
                 nacOut.ecm.deterministic $== _ardlDeterministicLabel(nacOut.primary_case) and
                 nacOut.na.ndecomp == 1 and nacOut.na.ncontrol == 1,
                 "nardlAutoCase nested output metadata invalid");

/*
** CS-ARDL deterministic checks.  Panel data are balanced and stacked
** by unit: [unit_id, y, x1, x2].
*/
nunits = 4;
TT = 60;
panel = zeros(nunits*TT, 4);
rndseed 260510;
rr = 1;
for ii(1, nunits, 1);
    x1_prev = 0;
    x2_prev = 0;
    y_prev = 0;
    for tt(1, TT, 1);
        x1v = 0.55*x1_prev + 0.04*tt + 0.12*ii + rndn(1, 1);
        x2v = 0.35*x2_prev - 0.02*tt + 0.08*ii + rndn(1, 1);
        yv = 0.45*y_prev + 0.30*x1v - 0.18*x2v + 0.06*ii + 0.15*rndn(1, 1);
        panel[rr, .] = ii~yv~x1v~x2v;
        x1_prev = x1v;
        x2_prev = x2v;
        y_prev = yv;
        rr = rr + 1;
    endfor;
endfor;

struct csardlOut csaOut;
csaOut = csardl(panel, 1, 1, 1, "", 0);

panel_time = vec(seqa(1, 1, TT)*ones(1, nunits));
panel_df = asDF(panel[., 1]~panel_time~panel[., 2:4], "unit", "time", "y", "x1", "x2");
panel_df = dftype(panel_df, META_TYPE_CATEGORY, "unit");
cs_formula_panel = applyCSARDLFormula(panel_df, "y ~ x1 + x2");
call assert_close(cs_formula_panel[., 2:4], panel[., 2:4], 1e-12,
                  "applyCSARDLFormula inferred panel formula changed y/x ordering");
panel_df_explicit = asDF((panel_time + 1000)~panel[., 1]~panel_time~panel[., 2:4],
                         "row_order", "panel_id", "period", "y", "x1", "x2");
cs_explicit_panel = applyCSARDLFormula(panel_df_explicit, "y ~ x1 + x2", "panel_id", "period");
call assert_close(cs_explicit_panel, panel, 1e-12,
                  "applyCSARDLFormula explicit panel id/time variables changed data");

struct csardlOut csaFormulaOut;
csaFormulaOut = csardl(panel_df, 1, 1, 1, "y ~ x1 + x2", 0);
call assert_close(csaFormulaOut.bigbt, csaOut.bigbt, 1e-10,
                  "csardl inferred panel formula output changed");
struct csardlOut csaExplicitOut;
csaExplicitOut = csardl(panel_df_explicit, 1, 1, 1, "y ~ x1 + x2", 0, "panel_id", "period");
call assert_close(csaExplicitOut.bigbt, csaOut.bigbt, 1e-10,
                  "csardl explicit panel id/time output changed");
call assert_true(csaExplicitOut.unitvar $== "panel_id" and csaExplicitOut.timevar $== "period",
                 "csardl explicit panel id/time metadata invalid");

{ cY, cX, csavg, unit_ids, unit_nobs } = _csardlBuildDesign(panel, 1, 1, 1);
expected_cbt = _qardlSafeInv(cX'*cX, "smoke_csardl", "expected CSARDL moment matrix")*cX'*cY;
expected_cresid = cY - cX*expected_cbt;
{ expected_ccov, expected_csigma2 } = _csardlOLSCov(cX, expected_cresid, "smoke_csardl");
expected_cbigbt_cov = _csardlLongRunCov(expected_cbt, expected_ccov, 1, 1, 1, 2);
expected_cphi = expected_cbt[4];
expected_cbeta = expected_cbt[2:3] ./ (1 - expected_cphi);

call assert_close(csaOut.bt, expected_cbt, 1e-10, "csardl bt does not match levels design");
call assert_close(csaOut.bigbt, expected_cbeta, 1e-10,
                  "csardl long-run coefficients do not match formula");
call assert_close(csaOut.bigbt_cov, expected_cbigbt_cov, 1e-10,
                  "csardl long-run covariance does not match delta method");
{ lr_beta, lr_cov } = ardlLongRun(csaOut);
call assert_close(lr_beta, csaOut.bigbt, 1e-12, "ardlLongRun CS-ARDL beta changed");
call assert_close(lr_cov, csaOut.bigbt_cov, 1e-12, "ardlLongRun CS-ARDL covariance changed");
call assert_true(csaOut.sigma2 > 0 and rows(csaOut.cross_avg_coef) > 0,
                 "csardl diagnostics invalid");
call assert_true(csaOut.nunits == nunits and csaOut.nobs == rows(cY) and csaOut.cs_lags == 1,
                 "csardl metadata invalid");
call assert_close(csaOut.cross_avg, csavg, 1e-12, "csardl cross averages changed");

struct csardlDiagOut diagOut;
diagOut = csardlDiagnostics(panel, 1, 1, 1, "", 0);
manual_mg = zeros(2, 1);
manual_mg[1] = meanc(diagOut.unit_bigbt[., 1]);
manual_mg[2] = meanc(diagOut.unit_bigbt[., 2]);
call assert_close(diagOut.pooled_bigbt, csaOut.bigbt, 1e-10,
                  "csardlDiagnostics pooled coefficients changed");
call assert_close(diagOut.mean_group_bigbt, manual_mg, 1e-12,
                  "csardlDiagnostics mean-group coefficients changed");
call assert_true(rows(diagOut.unit_bigbt) == nunits and cols(diagOut.unit_bigbt) == 2,
                 "csardlDiagnostics unit coefficient shape invalid");
call assert_true(diagOut.poolability_df == (nunits-1)*2 and
                 diagOut.poolability_pv >= 0 and diagOut.poolability_pv <= 1,
                 "csardlDiagnostics poolability statistic invalid");
call assert_true(diagOut.slope_hetero_df == (nunits-1)*2 and
                 diagOut.slope_hetero_pv >= 0 and diagOut.slope_hetero_pv <= 1,
                 "csardlDiagnostics slope heterogeneity statistic invalid");
call assert_true(diagOut.py_k == 5 and diagOut.py_delta_pv >= 0 and
                 diagOut.py_delta_pv <= 1 and diagOut.py_delta_adj_pv >= 0 and
                 diagOut.py_delta_adj_pv <= 1,
                 "csardlDiagnostics Pesaran-Yamagata statistic invalid");
call assert_true(diagOut.py_lr_k == 2 and diagOut.py_lr_delta_pv >= 0 and
                 diagOut.py_lr_delta_pv <= 1 and diagOut.py_lr_delta_adj_pv >= 0 and
                 diagOut.py_lr_delta_adj_pv <= 1,
                 "csardlDiagnostics long-run Pesaran-Yamagata statistic invalid");
call assert_true(diagOut.cd_pairs == nunits*(nunits-1)/2 and
                 diagOut.cd_pv >= 0 and diagOut.cd_pv <= 1 and
                 diagOut.cd_order == -1 and diagOut.cd_min_t == diagOut.unit_nobs and
                 diagOut.cd_max_t == diagOut.unit_nobs,
                 "csardlDiagnostics CD statistic invalid");

cs_fit = predictCSARDL(csaOut, panel);
call assert_close(cs_fit, cX*expected_cbt, 1e-10, "predictCSARDL did not use stored design");
call assert_close(predictARDL(csaOut, panel), cs_fit, 1e-10,
                  "predictARDL CSARDL dispatch changed fitted values");
cs_fcst = forecastCSARDL(csaOut, panel, 2);
call assert_true(rows(cs_fcst) == 2 and cols(cs_fcst) == 1,
                 "forecastCSARDL returned wrong shape");
call assert_close(forecastARDL(csaOut, panel, 2), cs_fcst, 1e-10,
                  "forecastARDL CSARDL dispatch changed forecasts");

struct csardlECMOut cECMOut;
cECMOut = csardlECM(panel, 1, 1, 1, "", 0);
call assert_true(cECMOut.nunits == nunits and cECMOut.k == 2,
                 "csardlECM metadata invalid");
call assert_true(rows(cECMOut.beta_lr) == 2 and rows(cECMOut.cross_avg_coef) > 0,
                 "csardlECM levels fields invalid");
call assert_true(cECMOut.sigma2 > 0 and rows(cECMOut.bt) > 2,
                 "csardlECM diagnostics invalid");
cECMOut = csardlECM(panel, 1, 1, 1, "", 0, "", "", "uecm");
call assert_true(cECMOut.ecm_type $== "uecm" and cECMOut.nunits == nunits and
                 rows(cECMOut.beta_lr) == 2 and rows(cECMOut.bt) == 12,
                 "csardlECM UECM option output shape invalid");

struct csardlFullOut cfOut;
cfOut = csardlFull(panel, 1, 1, 1, "", 0);
csardl_grid = csardlOrderGrid(panel, 1, 1, 1);
call assert_true(cfOut.pst == csardl_grid[minindc(csardl_grid[., 3]), 1] and
                 cfOut.qst == csardl_grid[minindc(csardl_grid[., 3]), 2] and
                 cfOut.cs_lags == 1,
                 "csardlFull metadata invalid");
{ c_p_gets, c_q_gets } = csardlOrder(panel, 2, 2, 1, "gets", 0.1);
call assert_true(c_p_gets >= 1 and c_p_gets <= 2 and
                 c_q_gets >= 0 and c_q_gets <= 2,
                 "csardlOrder GETS returned invalid lag orders");
cfOut = csardlFull(panel, 1, 1, 1, "", 0, "bic", "", "", "uecm");
call assert_true(cfOut.ecm.ecm_type $== "uecm" and rows(cfOut.ecm.beta_lr) == 2,
                 "csardlFull UECM option metadata invalid");
cfOut = csardlFull(panel, 2, 2, 1, "", 0, "gets", "", "", "uecm", 0.1);
call assert_true(cfOut.selection_criterion $== "gets" and cfOut.pst >= 1 and
                 cfOut.pst <= 2 and cfOut.qst >= 0 and cfOut.qst <= 2 and
                 cfOut.ecm.ecm_type $== "uecm",
                 "csardlFull GETS output invalid");
cfOut = csardlFull(panel, cs_lags = 1, verbose = 0);
call assert_true(cfOut.pst >= 1 and cfOut.pst <= 8 and cfOut.qst >= 0 and cfOut.qst <= 8,
                 "csardlFull default lag bounds invalid");

print "smoke_nardl_csardl_api.e: PASS";
