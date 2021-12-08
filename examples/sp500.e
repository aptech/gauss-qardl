library qardl;

// Load demonstration data
fname = "shiller_stocks_qt.csv";
shiller_stocks_qt = loadd(__FILE_DIR $+ fname, "date($date) + real_dividend + real_earnings");

// Plot data
struct plotControl myPlot;
myplot = plotGetDefaults("XY");

// Set up legend
plotSetLegend(&myPlot, "Dividend"$|"Earnings");
plotSetLegendFont(&myPlot, "Arial", 12);

// Place first x-tick mark at 1880 month 1
// draw one every 20 years
// Note that we pass in the first_labeled date in posix format
plotSetXTicInterval(&myPlot, 80, dttoposix(1880));

// Display only 4 digit year on x-tick labels
plotSetXTicLabel(&myPlot, "YYYY");
plotTSHF(myPlot, shiller_stocks_qt[., 1], "quarters", shiller_stocks_qt[., "real_dividend" "real_earnings"]);

// Max lags
pmax = 8;
qmax = 8;

// Quantile levels
tau = {0.25, 0.5, 0.75};

// Find optimal lags
{ pst, qst } = pqorder(shiller_stocks_qt[., "real_dividend" "real_earnings"], pmax, qmax);   

// Parameter estimation
struct qardlOut qaOut;
qaOut = qardl(shiller_stocks_qt[., "real_dividend" "real_earnings"], pst, qst, tau); 

