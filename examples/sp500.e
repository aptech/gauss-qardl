new;
library qardl;
cls;

/*
** S&P 500 application using dataframe formula support.
**
** Formula strings let you keep the original dataframe column order and select
** the QARDL dependent/regressor variables by name.
*/

shiller = loadd(__FILE_DIR $+ "shiller_stocks_qt.csv",
                "date($date) + real_price + real_dividend + real_earnings");

// Plot the raw dividend and earnings series.
struct plotControl myPlot;
myPlot = plotGetDefaults("XY");
plotSetLegend(&myPlot, "Dividend"$|"Earnings");
plotSetLegendFont(&myPlot, "Arial", 12);
plotSetXTicInterval(&myPlot, 80, dttoposix(1880));
plotSetXTicLabel(&myPlot, "YYYY");
plotTSHF(myPlot, shiller[., "date"], "quarters",
         shiller[., "real_dividend" "real_earnings"]);

tau = { 0.25, 0.5, 0.75 };

// Integrated workflow: formula selects [y, x] internally.
qfOut = qardlFull(shiller, 8, 8, tau, "real_dividend ~ real_earnings", 0);

print;
print "S&P 500 dividend/earnings QARDL";
print "--------------------------------";
print "Selected p, q: " qfOut.pst~qfOut.qst;
print "Bounds-test F-statistic: " qfOut.ardl_fstat;

printQARDL(qfOut.qa, tau);
printQARDLECM(qfOut.ecm, tau);

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qfOut.qa, tau,
               applyQARDLFormula(shiller, "real_dividend ~ real_earnings"));

print;
print "Constancy tests: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

qOut = qirf(qfOut.qa, qfOut.qa.p, qfOut.qa.q, 20, tau);
plotQARDLbands(qfOut.qa, tau);
plotQIRF(qOut);
