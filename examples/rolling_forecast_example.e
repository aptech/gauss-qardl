new;
library qardl;
cls;

/*
** Rolling-origin ARDL forecast example.
**
** Uses a fixed ARDL order and a supplied future regressor path for each
** origin. The example is intentionally compact so it can run as part of the
** example smoke suite.
*/

shiller = loadd(__FILE_DIR $+ "shiller_stocks_qt.csv",
                "date($date) + real_price + real_dividend + real_earnings");
formula = "real_dividend ~ real_earnings";
data = applyQARDLFormula(shiller, formula);

window = 180;
h = 3;
origins = 5;
n = rows(data);

fcst = zeros(origins, h);
actual = zeros(origins, h);
selected_rows = zeros(origins, 1);

for ii(1, origins, 1);
    end_ix = n - origins - h + ii;
    start_ix = end_ix - window + 1;
    train = data[start_ix:end_ix, .];
    future_x = data[end_ix+1:end_ix+h, 2:cols(data)];

    struct ardlOut arOut;
    arOut = ardl(train, 2, 1, "", 0);

    fcst[ii, .] = forecastARDL(arOut, train, h, "", future_x)';
    actual[ii, .] = data[end_ix+1:end_ix+h, 1]';
    selected_rows[ii] = end_ix;
endfor;

print "Rolling-origin ARDL forecasts";
print "Origin row, forecast h1-h3, actual h1-h3";
print selected_rows~fcst~actual;
