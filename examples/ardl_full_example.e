new;
library qardl;
cls;

/*
** ARDL full-workflow example.
**
** ardlFull combines information-criterion lag selection, ARDL bounds testing,
** levels-form ARDL estimation, prediction, and forecasting.
*/

shiller = loadd(__FILE_DIR $+ "shiller_stocks_qt.csv",
                "date($date) + real_price + real_dividend + real_earnings");
formula = "real_dividend ~ real_earnings";

// Omitting pend/qend uses the package default maximum lag search bounds.
struct ardlFullOut afOut;
afOut = ardlFull(shiller, formula = formula, verbose = 0, criterion = "bic");

print;
print "S&P 500 dividend/earnings ARDL full workflow";
print "--------------------------------------------";
print "Bounds F-stat: " afOut.ardl_fstat;
print "Selected p, q: " afOut.pst~afOut.qst;

printARDL(afOut.ar);

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
