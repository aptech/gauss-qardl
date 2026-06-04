new;
library qardl;
cls;

/*
** ARDL step-by-step estimation example.
**
** This example uses the same formula and output conventions as the QARDL
** workflow, but estimates the levels-form ARDL by OLS.
*/

// Step 1: Load the data and define the model with a formula string.
shiller = loadd(__FILE_DIR $+ "shiller_stocks_qt.csv",
                "date($date) + real_price + real_dividend + real_earnings");
formula = "real_dividend ~ real_earnings";

// Step 2: Convert the formula to a numeric [y, x] matrix for lag selection.
data = applyQARDLFormula(shiller, formula);

// Step 3: Select AR and distributed-lag orders by information criterion.
{ pst, qst } = pqorder(data, 4, 4, "bic");

// Step 4: Estimate the levels-form ARDL model at the selected lag orders.
arOut = ardl(shiller, pst, qst, formula, 0);

// Step 5: Access selected output fields directly from the returned structure.
print;
print "S&P 500 dividend/earnings ARDL";
print "------------------------------";
print "BIC-selected p, q: " pst~qst;
print "p q k nobs:        " arOut.p~arOut.q~arOut.k~arOut.nobs;
print "Long-run beta";
print arOut.bigbt;

// Step 6: Print the standard formatted ARDL coefficient table.
printARDL(arOut);

// Step 7: Run and print residual diagnostics for the fitted ARDL model.
diagOut = ardlResidualDiagnostics(arOut, 4);
printARDLResidualDiagnostics(diagOut);
