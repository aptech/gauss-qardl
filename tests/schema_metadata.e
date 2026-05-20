new;

/*
** Schema and formula-parity checks for the public ARDL-family outputs.
** These tests protect the baseline metadata contract used by diagnostics,
** validation fixtures, reporting, and unified prediction/forecast dispatch.
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
#include ../src/diagnostics.src

proc (0) = assert_true(ok, msg);
    if not ok;
        errorlog "schema_metadata.e failed: " $+ msg;
        end;
    endif;
endp;

proc (0) = assert_close(actual, expected, tol, msg);
    if maxc(abs(actual - expected)) > tol;
        errorlog "schema_metadata.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(maxc(abs(actual - expected)), "%g", 1, 0);
        end;
    endif;
endp;

proc (0) = assert_string(actual, expected, msg);
    if not (actual $== expected);
        errorlog "schema_metadata.e failed: " $+ msg;
        errorlog "  expected: " $+ expected;
        errorlog "  actual:   " $+ actual;
        end;
    endif;
endp;

proc (0) = assert_common_metadata(model_family, formula, depvar, xvars, cov_type,
                                  sample_start, sample_end, est_start, est_end,
                                  expected_family, expected_formula, expected_cov,
                                  expected_rows, expected_est_start, expected_est_end);
    call assert_string(model_family, expected_family, expected_family $+ " model_family metadata");
    call assert_string(formula, expected_formula, expected_family $+ " formula metadata");
    call assert_string(depvar, "y", expected_family $+ " depvar metadata");
    call assert_true(rows(xvars) == 2 and xvars[1] $== "x1" and xvars[2] $== "x2",
                     expected_family $+ " xvars metadata");
    call assert_string(cov_type, expected_cov, expected_family $+ " covariance metadata");
    call assert_true(sample_start == 1 and sample_end == expected_rows,
                     expected_family $+ " sample range metadata");
    call assert_true(est_start == expected_est_start and est_end == expected_est_end,
                     expected_family $+ " estimation range metadata");
endp;

n = 90;
t = seqa(1, 1, n);
x1 = sin(t/5) + 0.01*t;
x2 = cos(t/7) - 0.005*t;
y = 1 + 0.42*x1 - 0.18*x2 + 0.35*lagn(zeros(1, 1)|seqa(1, 1, n-1), 0)/n;
data = y~x1~x2;
df = asDF(data, "y", "x1", "x2");
formula = "y ~ x1 + x2";
tau = { 0.25, 0.5, 0.75 };

struct ardlOut ar_matrix;
struct ardlOut ar_formula;
ar_matrix = ardl(data, 1, 1, "", 0);
ar_formula = ardl(df, 1, 1, formula, 0);
call assert_close(ar_formula.bt, ar_matrix.bt, 1e-10, "ARDL formula and matrix estimates differ");
call assert_common_metadata(ar_formula.model_family, ar_formula.formula, ar_formula.depvar,
                            ar_formula.xvars, ar_formula.covariance_type,
                            ar_formula.sample_start, ar_formula.sample_end,
                            ar_formula.estimation_start, ar_formula.estimation_end,
                            "ARDL", formula, "ols", n, 2, n);
call assert_string(ar_formula.deterministic, "constant", "ARDL deterministic metadata");
call assert_string(ar_formula.selection_criterion, "none", "ARDL selection metadata");
call assert_true(rows(ar_formula.qvec) == 2 and ar_formula.qvec[1] == 1 and ar_formula.qvec[2] == 1,
                 "ARDL qvec metadata");
call assert_true(rows(ar_formula.fitted) == ar_formula.nobs and rows(ar_formula.resid) == ar_formula.nobs,
                 "ARDL fitted/residual metadata");
struct ardlResidualDiagOut rd_schema;
rd_schema = ardlResidualDiagnostics(ar_formula, 3);
call assert_string(rd_schema.model_family, "ARDL-Residual-Diagnostics", "residual diagnostic family metadata");
call assert_string(rd_schema.source_model_family, "ARDL", "residual diagnostic source metadata");
call assert_true(rd_schema.nobs == ar_formula.nobs and rd_schema.nseries == 1 and rd_schema.lags == 3,
                 "residual diagnostic dimension metadata");

struct qardlOut qa_matrix;
struct qardlOut qa_formula;
qa_matrix = qardl(data, 1, 1, tau, "iid", 0, 0);
qa_formula = qardl(applyQARDLFormula(df, formula), 1, 1, tau, "iid", 0, 0);
call assert_close(qa_formula.bigbt, qa_matrix.bigbt, 1e-10, "QARDL formula and matrix estimates differ");
call assert_common_metadata(qa_formula.model_family, qa_formula.formula, qa_formula.depvar,
                            qa_formula.xvars, qa_formula.covariance_type,
                            qa_formula.sample_start, qa_formula.sample_end,
                            qa_formula.estimation_start, qa_formula.estimation_end,
                            "QARDL", "", "iid", n, 2, n);
call assert_true(rows(qa_formula.qvec) == 2 and qa_formula.qvec[1] == 1 and qa_formula.qvec[2] == 1,
                 "QARDL qvec metadata");
call assert_true(rows(qa_formula.fitted) == qa_formula.nobs and cols(qa_formula.fitted) == rows(tau),
                 "QARDL fitted metadata");

struct qardlECMOut qecm;
qecm = qardlECM(data, 1, 1, tau, "robust", 0, 0);
call assert_common_metadata(qecm.model_family, qecm.formula, qecm.depvar,
                            qecm.xvars, qecm.covariance_type,
                            qecm.sample_start, qecm.sample_end,
                            qecm.estimation_start, qecm.estimation_end,
                            "QARDL-ECM", "", "robust", n, 3, n);
call assert_true(rows(qecm.bt) >= 2 and rows(qecm.fitted) == qecm.nobs and cols(qecm.fitted) == rows(tau),
                 "QARDL-ECM coefficient/fitted metadata");

struct qardlFullOut qf;
qf = qardlFull(df, 1, 1, tau, formula, 0, "bic", "hac", 2);
call assert_string(qf.model_family, "QARDL", "qardlFull model_family metadata");
call assert_string(qf.formula, formula, "qardlFull formula metadata");
call assert_string(qf.selection_criterion, "bic", "qardlFull criterion metadata");
call assert_string(qf.covariance_type, "hac", "qardlFull covariance metadata");
call assert_true(qf.pmax == 1 and qf.qmax == 1 and qf.sample_end == n,
                 "qardlFull search/sample metadata");
call assert_string(qf.qa.formula, formula, "qardlFull nested QARDL formula metadata");
call assert_string(qf.ecm.formula, formula, "qardlFull nested ECM formula metadata");

struct nardlOut na_matrix;
struct nardlOut na_formula;
na_matrix = nardl(data, 1, 1, "", 0);
na_formula = nardl(df, 1, 1, formula, 0);
call assert_close(na_formula.bigbt, na_matrix.bigbt, 1e-10, "NARDL formula and matrix estimates differ");
call assert_common_metadata(na_formula.model_family, na_formula.formula, na_formula.depvar,
                            na_formula.xvars, na_formula.covariance_type,
                            na_formula.sample_start, na_formula.sample_end,
                            na_formula.estimation_start, na_formula.estimation_end,
                            "NARDL", formula, "ols", n, 2, n);
call assert_true(rows(na_formula.qvec) == 2 and rows(na_formula.fitted) == na_formula.nobs,
                 "NARDL qvec/fitted metadata");
struct nardlDynMultOut ndm;
ndm = nardlDynamicMultipliers(na_formula, 3);
call assert_string(ndm.model_family, "NARDL-Dynamic-Multipliers", "NARDL multiplier model_family metadata");
call assert_string(ndm.formula, formula, "NARDL multiplier formula metadata");
call assert_true(ndm.horizon == 3 and rows(ndm.pos) == 4 and cols(ndm.neg) == 2,
                 "NARDL multiplier shape metadata");

struct nardlECMOut necm;
necm = nardlECM(df, 1, 1, formula, 0);
call assert_common_metadata(necm.model_family, necm.formula, necm.depvar,
                            necm.xvars, necm.covariance_type,
                            necm.sample_start, necm.sample_end,
                            necm.estimation_start, necm.estimation_end,
                            "NARDL-ECM", formula, "ols", n, 3, n);
call assert_true(rows(necm.qvec) == 2 and rows(necm.fitted) == necm.nobs,
                 "NARDL-ECM qvec/fitted metadata");

struct nardlFullOut nf;
nf = nardlFull(df, 1, 1, formula, 0, "bic");
call assert_string(nf.model_family, "NARDL", "nardlFull model_family metadata");
call assert_string(nf.formula, formula, "nardlFull formula metadata");
call assert_string(nf.selection_criterion, "bic", "nardlFull criterion metadata");
call assert_true(nf.pmax == 1 and nf.qmax == 1 and nf.sample_end == n,
                 "nardlFull search/sample metadata");
call assert_string(nf.na.formula, formula, "nardlFull nested NARDL formula metadata");
call assert_string(nf.ecm.formula, formula, "nardlFull nested ECM formula metadata");

nunits = 3;
TT = 40;
panel = zeros(nunits*TT, 4);
rr = 1;
rndseed 260512;
for ii(1, nunits, 1);
    y_prev = 0;
    for tt(1, TT, 1);
        x1v = 0.04*tt + 0.10*ii + sin(tt/4) + 0.05*rndn(1, 1);
        x2v = -0.03*tt + 0.08*ii + cos(tt/5) + 0.05*rndn(1, 1);
        yv = 0.35*y_prev + 0.30*x1v - 0.15*x2v + 0.02*ii + 0.03*rndn(1, 1);
        panel[rr, .] = ii~yv~x1v~x2v;
        y_prev = yv;
        rr = rr + 1;
    endfor;
endfor;

panel_time = vec(seqa(1, 1, TT)*ones(1, nunits));
panel_df = asDF(panel[., 1]~panel_time~panel[., 2:4], "unit", "time", "y", "x1", "x2");
panel_df = dftype(panel_df, META_TYPE_CATEGORY, "unit");

struct csardlOut csa_matrix;
struct csardlOut csa_formula;
csa_matrix = csardl(panel, 1, 1, 1, "", 0);
csa_formula = csardl(panel_df, 1, 1, 1, formula, 0);
call assert_close(csa_formula.bigbt, csa_matrix.bigbt, 1e-10, "CS-ARDL formula and matrix estimates differ");
call assert_common_metadata(csa_formula.model_family, csa_formula.formula, csa_formula.depvar,
                            csa_formula.xvars, csa_formula.covariance_type,
                            csa_formula.sample_start, csa_formula.sample_end,
                            csa_formula.estimation_start, csa_formula.estimation_end,
                            "CS-ARDL", formula, "ols", rows(panel), 2, TT);
call assert_string(csa_formula.unitvar, "unit", "CS-ARDL unit variable metadata");
call assert_string(csa_formula.timevar, "time", "CS-ARDL time variable metadata");
call assert_true(rows(csa_formula.qvec) == 2 and csa_formula.nunits == nunits,
                 "CS-ARDL qvec/panel metadata");

struct csardlECMOut cecm;
cecm = csardlECM(panel_df, 1, 1, 1, formula, 0);
call assert_common_metadata(cecm.model_family, cecm.formula, cecm.depvar,
                            cecm.xvars, cecm.covariance_type,
                            cecm.sample_start, cecm.sample_end,
                            cecm.estimation_start, cecm.estimation_end,
                            "CS-ARDL-ECM", formula, "ols", rows(panel), 3, TT);
call assert_string(cecm.unitvar, "unit", "CS-ARDL-ECM unit variable metadata");
call assert_string(cecm.timevar, "time", "CS-ARDL-ECM time variable metadata");
call assert_true(rows(cecm.qvec) == 2 and rows(cecm.fitted) == cecm.nobs,
                 "CS-ARDL-ECM qvec/fitted metadata");

struct csardlDiagOut cdiag;
cdiag = csardlDiagnostics(panel_df, 1, 1, 1, formula, 0);
call assert_string(cdiag.model_family, "CS-ARDL-Diagnostics", "CS-ARDL diagnostics model_family metadata");
call assert_string(cdiag.formula, formula, "CS-ARDL diagnostics formula metadata");
call assert_string(cdiag.unitvar, "unit", "CS-ARDL diagnostics unit metadata");
call assert_true(cdiag.estimation_start == 2 and cdiag.estimation_end == TT,
                 "CS-ARDL diagnostics estimation range metadata");

struct csardlFullOut cf;
cf = csardlFull(panel_df, 1, 1, 1, formula, 0, "bic");
call assert_string(cf.model_family, "CS-ARDL", "csardlFull model_family metadata");
call assert_string(cf.formula, formula, "csardlFull formula metadata");
call assert_string(cf.selection_criterion, "bic", "csardlFull criterion metadata");
call assert_string(cf.csa.formula, formula, "csardlFull nested CS-ARDL formula metadata");
call assert_string(cf.ecm.formula, formula, "csardlFull nested ECM formula metadata");

print "schema_metadata.e: PASS";
