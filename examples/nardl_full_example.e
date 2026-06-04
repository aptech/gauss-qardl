new;
library qardl;
cls;

/*
** NARDL full-workflow example.
**
** nardlFull combines lag selection and NARDL levels estimation. This example
** also shows formula strings, ECM output, prediction, and forecasting.
*/

// Step 1: Create a small synthetic nonlinear time-series dataset.
rndseed 260520;
nnn = 160;
x1 = cumsumc(rndn(nnn, 1));
x2 = cumsumc(rndn(nnn, 1));
y = zeros(nnn, 1);

tt = 2;
do until tt > nnn;
    dx1 = x1[tt] - x1[tt-1];
    dx2 = x2[tt] - x2[tt-1];
    y[tt] = 0.40*y[tt-1] + 0.35*maxc(dx1|0) - 0.18*minc(dx1|0)
            - 0.12*maxc(dx2|0) + 0.28*minc(dx2|0) + 0.25*rndn(1, 1);
    tt = tt + 1;
endo;

// Step 2: Store the data in a dataframe and define the formula.
data = y~x1~x2;
df = asDF(data, "y", "x1", "x2");
formula = "y ~ x1 + x2";

// Step 3: Run the integrated NARDL workflow. Omitting pend/qend uses the
//         package default maximum lag search bounds.
nfOut = nardlFull(df, formula = formula, verbose = 0, criterion = "bic");

// Step 4: Estimate the matching ECM representation at the selected lag orders.
nECMOut = nardlECM(df, nfOut.pst, nfOut.qst, formula, 0);

// Step 5: Inspect workflow-level fields and model-specific asymmetry output.
print;
print "NARDL formula full workflow";
print "---------------------------";
print "BIC-selected p, q: " nfOut.pst~nfOut.qst;
print "ECM alpha rho:     " nECMOut.alpha~nECMOut.rho;
print "Short-run asymmetry p-values";
print nfOut.na.short_run_pv;

// Step 6: Print formatted levels and ECM output tables.
printNARDL(nfOut.na);
printNARDLECM(nECMOut);

// Step 7: Use the unified prediction and forecast helpers. They infer the
//         model type from the output structure.
fit = predictARDL(nfOut.na, df, formula);
fcst = forecastARDL(nfOut.na, df, 3, formula);

// Step 8: Display the fitted-sample prediction size and 3-step forecast.
print;
print "Prediction rows and 3-step forecast";
print rows(fit);
print fcst;
