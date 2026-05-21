new;
library qardl;
cls;

/*
** ARDL step-by-step estimation example.
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

struct ardlResidualDiagOut diagOut;
diagOut = ardlResidualDiagnostics(arOut, 4);
printARDLResidualDiagnostics(diagOut);
