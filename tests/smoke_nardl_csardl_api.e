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

{ nY, nX, npos, nneg } = _nardlBuildDesign(nardl_data, 1, 1);
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
call assert_true(rows(naOut.asymmetry_wald) == 2 and minc(naOut.asymmetry_pv) >= 0 and maxc(naOut.asymmetry_pv) <= 1,
                 "nardl asymmetry tests invalid");
call assert_true(naOut.bounds_fstat > 0 and naOut.sigma2 > 0,
                 "nardl diagnostics invalid");
call assert_true(naOut.nobs == rows(nY) and naOut.k == 2 and naOut.p == 1 and naOut.q == 1,
                 "nardl metadata invalid");

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

struct nardlECMOut nECMOut;
nECMOut = nardlECM(nardl_data, 1, 1, "", 0);
call assert_true(nECMOut.nobs == n - 2 and nECMOut.k == 2,
                 "nardlECM metadata invalid");
call assert_true(rows(nECMOut.beta_pos) == 2 and rows(nECMOut.beta_neg) == 2,
                 "nardlECM long-run fields invalid");
call assert_true(nECMOut.sigma2 > 0 and rows(nECMOut.bt) > 2,
                 "nardlECM diagnostics invalid");

struct nardlFullOut nfOut;
nfOut = nardlFull(nardl_data, 1, 1, "", 0);
nardl_grid = nardlOrderGrid(nardl_data, 1, 1);
call assert_true(nfOut.pst == nardl_grid[minindc(nardl_grid[., 3]), 1] and
                 nfOut.qst == nardl_grid[minindc(nardl_grid[., 3]), 2] and
                 nfOut.na.nobs == naOut.nobs,
                 "nardlFull metadata invalid");

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

struct csardlOut csaFormulaOut;
csaFormulaOut = csardl(panel_df, 1, 1, 1, "y ~ x1 + x2", 0);
call assert_close(csaFormulaOut.bigbt, csaOut.bigbt, 1e-10,
                  "csardl inferred panel formula output changed");

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

struct csardlFullOut cfOut;
cfOut = csardlFull(panel, 1, 1, 1, "", 0);
csardl_grid = csardlOrderGrid(panel, 1, 1, 1);
call assert_true(cfOut.pst == csardl_grid[minindc(csardl_grid[., 3]), 1] and
                 cfOut.qst == csardl_grid[minindc(csardl_grid[., 3]), 2] and
                 cfOut.cs_lags == 1,
                 "csardlFull metadata invalid");
cfOut = csardlFull(panel, cs_lags = 1, verbose = 0);
call assert_true(cfOut.pst >= 1 and cfOut.pst <= 8 and cfOut.qst >= 0 and cfOut.qst <= 8,
                 "csardlFull default lag bounds invalid");

print "smoke_nardl_csardl_api.e: PASS";
