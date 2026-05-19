new;

/*
** Deterministic prediction and forecast validation for unified ARDL-family
** dispatch and backward-compatible QARDL wrappers.
**
** Forecast assumptions:
** - Missing future_x paths hold future regressors fixed at last observed
**   levels.
** - ARDL/QARDL/NARDL future_x paths are h x k regressor matrices.
** - CS-ARDL future_x panel paths are not yet supported.
**
** TODO: Add expected-error tests for malformed future_x paths once the GAUSS
**       validation harness has a standard expected-error capture pattern.
*/

#include src/qardl.sdf
#include src/qardl.src
#include src/nardl.src
#include src/csardl.src
#include src/ardl_dispatch.src
#include src/wtestlrb.src
#include src/wtestsrp.src
#include src/wtestsrg.src
#include src/icmean.src
#include src/p_values_qardl.src
#include src/wtestsym.src
#include src/wtestconst.src
#include src/ardlbounds.src
#include src/qirf.src

proc (0) = assert_close(actual, expected, tol, msg);
    local diff;

    if rows(actual) /= rows(expected) or cols(actual) /= cols(expected);
        errorlog "prediction_forecast_validation.e failed: " $+ msg;
        errorlog "  actual shape   = " $+ ftos(rows(actual), "%g", 1, 0) $+ " x " $+ ftos(cols(actual), "%g", 1, 0);
        errorlog "  expected shape = " $+ ftos(rows(expected), "%g", 1, 0) $+ " x " $+ ftos(cols(expected), "%g", 1, 0);
        end;
    endif;

    diff = maxc(abs(vec(actual - expected)));
    if scalmiss(diff) or diff > tol;
        errorlog "prediction_forecast_validation.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(diff, "%g", 1, 0);
        errorlog "  tolerance    = " $+ ftos(tol, "%g", 1, 0);
        end;
    endif;
endp;

proc (1) = read_expected(relpath);
    retp(csvReadM(__FILE_DIR $+ "../../fixtures/expected/" $+ relpath));
endp;

proc (1) = edge_rows(x);
    retp(x[1:3, .]|x[rows(x)-2:rows(x), .]);
endp;

proc (1) = make_nardl_validation_data(nnn);
    local x1, x2, y, ii;

    rndseed 260511;
    x1 = cumsumc(rndn(nnn, 1));
    x2 = cumsumc(rndn(nnn, 1));
    y = zeros(nnn, 1);

    ii = 2;
    do until ii > nnn;
        y[ii] = 0.42*y[ii-1] + 0.30*x1[ii] - 0.18*x2[ii] +
                0.10*(x1[ii] - x1[ii-1]) - 0.06*(x2[ii] - x2[ii-1]) +
                0.25*rndn(1, 1);
        ii = ii + 1;
    endo;

    retp(y~x1~x2);
endp;

proc (1) = make_csardl_validation_panel(nunits, tobs);
    local panel, rr, ii, tidx, x1_prev, x2_prev, y_prev;
    local common1, common2, x1v, x2v, yv;

    rndseed 260512;
    panel = zeros(nunits*tobs, 4);
    rr = 1;

    for ii(1, nunits, 1);
        x1_prev = 0;
        x2_prev = 0;
        y_prev = 0;
        for tidx(1, tobs, 1);
            common1 = sin(tidx/7);
            common2 = cos(tidx/11);
            x1v = 0.50*x1_prev + 0.15*common1 + 0.04*tidx + 0.10*ii + rndn(1, 1);
            x2v = 0.30*x2_prev - 0.10*common2 - 0.02*tidx + 0.07*ii + rndn(1, 1);
            yv = 0.40*y_prev + 0.28*x1v - 0.16*x2v + 0.08*common1 +
                 0.04*ii + 0.20*rndn(1, 1);
            panel[rr, .] = ii~yv~x1v~x2v;
            x1_prev = x1v;
            x2_prev = x2v;
            y_prev = yv;
            rr = rr + 1;
        endfor;
    endfor;

    retp(panel);
endp;

tol = 1e-8;
tau = { 0.25, 0.5, 0.75 };

data = loadd("examples/qardl_data.dat");
data = data[., 1:3];
future_x = data[rows(data), 2:3] + seqa(1, 1, 3)*(0.25~-0.10);

struct ardlOut arOut;
arOut = ardl(data, 2, 1, "", 0);
ar_fit = predictARDL(arOut, data);
call assert_close(ar_fit, arOut.fitted, tol, "ARDL predict dispatch changed fitted values");
call assert_close(edge_rows(ar_fit),
                  read_expected("synthetic/predictions/ardl_qardl_data_fit_edges.csv"),
                  tol, "ARDL fitted edge fixture changed");
call assert_close(forecastARDL(arOut, data, 3),
                  read_expected("synthetic/forecasts/ardl_qardl_data_h3.csv"),
                  tol, "ARDL hold-last forecast fixture changed");
call assert_close(forecastARDL(arOut, data, 3, "", future_x),
                  read_expected("synthetic/forecasts/ardl_qardl_data_futurex_h3.csv"),
                  tol, "ARDL future_x forecast fixture changed");

struct qardlOut qaOut;
qaOut = qardl(data, 2, 1, tau, "iid", 0, 0);
qa_fit = predictARDL(qaOut, data);
call assert_close(qa_fit, qaOut.fitted, tol, "QARDL predict dispatch changed fitted values");
call assert_close(predictQARDL(qaOut, data), qa_fit, tol,
                  "predictQARDL no longer matches unified predictARDL");
call assert_close(edge_rows(qa_fit),
                  read_expected("synthetic/predictions/qardl_qardl_data_fit_edges.csv"),
                  tol, "QARDL fitted edge fixture changed");
call assert_close(forecastARDL(qaOut, data, 3),
                  read_expected("synthetic/forecasts/qardl_qardl_data_h3.csv"),
                  tol, "QARDL hold-last forecast fixture changed");
call assert_close(forecastQARDL(qaOut, data, 3), forecastARDL(qaOut, data, 3), tol,
                  "forecastQARDL no longer matches unified forecastARDL");
call assert_close(forecastARDL(qaOut, data, 3, "", future_x),
                  read_expected("synthetic/forecasts/qardl_qardl_data_futurex_h3.csv"),
                  tol, "QARDL future_x forecast fixture changed");

nardl_data = make_nardl_validation_data(300);
n_future = nardl_data[rows(nardl_data), 2:3] + seqa(1, 1, 3)*(0.15~-0.12);
struct nardlOut naOut;
naOut = nardl(nardl_data, 2, 2, "", 0);
na_fit = predictARDL(naOut, nardl_data);
call assert_close(na_fit, naOut.fitted, tol, "NARDL predict dispatch changed fitted values");
call assert_close(predictNARDL(naOut, nardl_data), na_fit, tol,
                  "predictNARDL no longer matches unified predictARDL");
call assert_close(edge_rows(na_fit),
                  read_expected("synthetic/predictions/nardl_seeded_fit_edges.csv"),
                  tol, "NARDL fitted edge fixture changed");
call assert_close(forecastARDL(naOut, nardl_data, 3),
                  read_expected("synthetic/forecasts/nardl_seeded_h3.csv"),
                  tol, "NARDL hold-last forecast fixture changed");
call assert_close(forecastNARDL(naOut, nardl_data, 3), forecastARDL(naOut, nardl_data, 3), tol,
                  "forecastNARDL no longer matches unified forecastARDL");
call assert_close(forecastARDL(naOut, nardl_data, 3, "", n_future),
                  read_expected("synthetic/forecasts/nardl_seeded_futurex_h3.csv"),
                  tol, "NARDL future_x forecast fixture changed");

panel = make_csardl_validation_panel(12, 90);
struct csardlOut csaOut;
csaOut = csardl(panel, 2, 1, 1, "", 0);
csa_fit = predictARDL(csaOut, panel);
call assert_close(csa_fit, csaOut.fitted, tol, "CS-ARDL predict dispatch changed fitted values");
call assert_close(predictCSARDL(csaOut, panel), csa_fit, tol,
                  "predictCSARDL no longer matches unified predictARDL");
call assert_close(edge_rows(csa_fit),
                  read_expected("synthetic/predictions/csardl_seeded_fit_edges.csv"),
                  tol, "CS-ARDL fitted edge fixture changed");
call assert_close(forecastARDL(csaOut, panel, 3),
                  read_expected("synthetic/forecasts/csardl_seeded_h3.csv"),
                  tol, "CS-ARDL hold-last forecast fixture changed");
call assert_close(forecastCSARDL(csaOut, panel, 3), forecastARDL(csaOut, panel, 3), tol,
                  "forecastCSARDL no longer matches unified forecastARDL");

print "synthetic/prediction_forecast_validation.e: PASS";
