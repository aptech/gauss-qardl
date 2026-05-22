new;
library qardl;
cls;

/*
** ARDL full-workflow example.
**
** ardlFull combines information-criterion lag selection, ARDL bounds testing,
** levels-form ARDL estimation, prediction, and forecasting.
*/

// Step 1: Load the dataframe and define the model with a formula string.
shiller = loadd(__FILE_DIR $+ "shiller_stocks_qt.csv",
                "date($date) + real_price + real_dividend + real_earnings");
formula = "real_dividend ~ real_earnings";

// Step 2: Run the integrated ARDL workflow. Omitting pend/qend uses the
//         package default maximum lag search bounds.
struct ardlFullOut afOut;
afOut = ardlFull(shiller, formula = formula, verbose = 0, criterion = "bic");

// Step 3: Inspect workflow-level output, including bounds testing and lags.
print;
print "S&P 500 dividend/earnings ARDL full workflow";
print "--------------------------------------------";
print "Bounds F-stat: " afOut.ardl_fstat;
print "Selected p, q: " afOut.pst~afOut.qst;

// Step 4: Print the ARDL model estimated inside the full workflow object.
printARDL(afOut.ar);

// Step 5: Use the unified prediction and forecast helpers on the ARDL output.
fit = predictARDL(afOut.ar, shiller, formula);
fcst = forecastARDL(afOut.ar, shiller, 3, formula);

// Step 6: Display the fitted-sample prediction size and 3-step forecast.
print;
print "Prediction rows and 3-step forecast";
print rows(fit);
print fcst;

/*
** TODO: Validate ARDL forecast examples against published applied workflows
**       once exact references and data transformations are selected.
*/
