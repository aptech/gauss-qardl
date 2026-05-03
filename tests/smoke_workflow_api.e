new;

/*
** Smoke tests for higher-level source-tree workflows. These intentionally
** include local source files instead of loading `library qardl`.
*/

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
        errorlog "smoke_workflow_api.e failed: " $+ msg;
        end;
    endif;
endp;

tau = { 0.25, 0.5, 0.75 };

/*
** Formula preprocessing should work with named-column dataframes and preserve
** the requested y, x ordering for downstream matrix-based procedures.
*/
shiller = loadd(__FILE_DIR $+ "../examples/shiller_stocks_qt.csv",
                "date($date) + real_dividend + real_earnings");
formula_data = applyQARDLFormula(shiller, "real_dividend ~ real_earnings");
call assert_true(cols(formula_data) == 2, "applyQARDLFormula did not select two columns");
call assert_true(maxc(abs(formula_data[., 1] - shiller[., "real_dividend"])) < 1e-12,
                 "applyQARDLFormula did not place y in column 1");
call assert_true(maxc(abs(formula_data[., 2] - shiller[., "real_earnings"])) < 1e-12,
                 "applyQARDLFormula did not place x in column 2");

/*
** Integrated workflow: keep the search small for a fast release gate, but
** exercise lag selection, bounds, levels QARDL, ECM, and printing.
*/
data = loadd(__FILE_DIR $+ "../examples/qardl_data.dat");
data = data[1:350, 1:3];

struct qardlFullOut qfOut;
qfOut = qardlFull(data, 2, 2, tau);

call assert_true(qfOut.pst >= 1 and qfOut.qst >= 1, "qardlFull returned invalid lag orders");
call assert_true(qfOut.ardl_fstat > 0, "qardlFull ARDL F-statistic should be positive");
call assert_true(rows(qfOut.ardl_cv) == 3 and cols(qfOut.ardl_cv) == 2, "qardlFull critical values shape changed");
call assert_true(rows(qfOut.qa.bigbt) == 2*rows(tau), "qardlFull levels beta shape changed");
call assert_true(rows(qfOut.ecm.rho) == rows(tau), "qardlFull ECM rho shape changed");

print "smoke_workflow_api.e: PASS";
