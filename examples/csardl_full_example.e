new;
library qardl;
cls;

/*
** CS-ARDL full-workflow example.
**
** Dataframe workflows can infer unit/time metadata using GAUSS panel-data
** conventions, or you can pass explicit panel id and time column names.
*/

// Step 1: Define a helper to create a balanced panel stacked by unit.
proc (1) = make_csardl_example_panel(nunits, tobs);
    local panel, rr, ii, tidx, x1_prev, x2_prev, y_prev;
    local common1, common2, x1v, x2v, yv;

    rndseed 260521;
    panel = zeros(nunits*tobs, 4);
    rr = 1;

    for ii(1, nunits, 1);
        x1_prev = 0;
        x2_prev = 0;
        y_prev = 0;
        for tidx(1, tobs, 1);
            common1 = sin(tidx/8);
            common2 = cos(tidx/10);
            x1v = 0.45*x1_prev + 0.12*common1 + 0.03*tidx + 0.08*ii + rndn(1, 1);
            x2v = 0.25*x2_prev - 0.10*common2 - 0.02*tidx + 0.05*ii + rndn(1, 1);
            yv = 0.42*y_prev + 0.26*x1v - 0.14*x2v + 0.08*common1 +
                 0.03*ii + 0.20*rndn(1, 1);
            panel[rr, .] = ii~yv~x1v~x2v;
            x1_prev = x1v;
            x2_prev = x2v;
            y_prev = yv;
            rr = rr + 1;
        endfor;
    endfor;

    retp(panel);
endp;

// Step 2: Create the panel and add dataframe unit/time metadata.
panel = make_csardl_example_panel(8, 70);
_time = vec(seqa(1, 1, 70)*ones(1, 8));
df = asDF(panel[., 1]~_time~panel[., 2:4], "unit", "time", "y", "x1", "x2");
df = dftype(df, META_TYPE_CATEGORY, "unit");
formula = "y ~ x1 + x2";

// Step 3: Run the integrated CS-ARDL workflow. Omitting pend/qend uses the
//         package default maximum lag search bounds.
struct csardlFullOut cfOut;
cfOut = csardlFull(df, cs_lags = 1, formula = formula, verbose = 0,
                   criterion = "bic", group_var = "unit", time_var = "time");

// Step 4: Estimate the matching ECM representation at the selected lag orders.
struct csardlECMOut cECMOut;
cECMOut = csardlECM(df, cfOut.pst, cfOut.qst, cfOut.cs_lags, formula, 0,
                    "unit", "time");

// Step 5: Inspect workflow-level fields from the full output structure.
print;
print "CS-ARDL formula full workflow";
print "-----------------------------";
print "BIC-selected p, q: " cfOut.pst~cfOut.qst;
print "ECM alpha rho:     " cECMOut.alpha~cECMOut.rho;

// Step 6: Print formatted levels and ECM output tables.
printCSARDL(cfOut.csa);
printCSARDLECM(cECMOut);

// Step 7: Use the unified prediction and forecast helpers on CS-ARDL output.
fit = predictARDL(cfOut.csa, df, formula, "unit", "time");
fcst = forecastARDL(cfOut.csa, df, 3, formula, group_var = "unit", time_var = "time");

// Step 8: Display the fitted-sample prediction size and 3-step forecast.
print;
print "Prediction rows and 3-step forecast";
print rows(fit);
print fcst;

/*
** TODO: Add published-result CS-ARDL validation once exact DGP grids,
**       datasets, and estimator variants are confirmed.
*/
