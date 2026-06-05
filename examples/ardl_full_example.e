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
afOut = ardlFull(shiller, formula = formula, verbose = 1, criterion = "bic");

// Step 4: Use the unified prediction and forecast helpers on the ARDL output.
fit = predictARDL(afOut.ar, shiller, formula);
fcst = forecastARDL(afOut.ar, shiller, 3, formula);

// Step 5: Display the fitted-sample prediction size and 3-step forecast.
print;
print "Prediction rows and 3-step forecast";
print rows(fit);
print fcst;
