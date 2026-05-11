new;
library qardl;
cls;

/*
** ARDL estimation example.
**
** This example uses the same formula and output conventions as the QARDL
** workflow, but estimates the levels-form ARDL by OLS.
*/

shiller = loadd(__FILE_DIR $+ "shiller_stocks_qt.csv",
                "date($date) + real_price + real_dividend + real_earnings");
formula = "real_dividend ~ real_earnings";

data = applyQARDLFormula(shiller, formula);

// Information-criterion lag selection can be used directly with ARDL.
{ pst, qst } = pqorder(data, 4, 4, "bic");

struct ardlOut arOut;
arOut = ardl(shiller, pst, qst, formula, 0);

print;
print "S&P 500 dividend/earnings ARDL";
print "------------------------------";
print "BIC-selected p, q: " pst~qst;
print "p q k nobs:        " arOut.p~arOut.q~arOut.k~arOut.nobs;
print "Long-run beta";
print arOut.bigbt;

printARDL(arOut);

// Integrated workflow: lag selection, ARDL bounds test, and ARDL estimation.
struct ardlFullOut afOut;
afOut = ardlFull(shiller, 4, 4, formula, 0, "bic");

print;
print "ARDL full workflow";
print "------------------";
print "Bounds F-stat: " afOut.ardl_fstat;
print "Selected p, q: " afOut.pst~afOut.qst;

fit = predictARDL(afOut.ar, shiller, formula);
fcst = forecastARDL(afOut.ar, shiller, 3, formula);

print;
print "Prediction rows and 3-step forecast";
print rows(fit);
print fcst;

/*
** TODO: Validate ARDL forecast examples against published applied workflows
**       once exact references and data transformations are selected.
*/
