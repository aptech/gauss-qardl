new;
library qardl;
cls;

/*
** CS-ARDL estimation example.
**
** The matrix panel is balanced and stacked by unit: [unit, y, x1, x2].
** Dataframe workflows include unit/time metadata so CS-ARDL can infer the
** panel id and time columns using GAUSS panel-data conventions.
*/

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

panel = make_csardl_example_panel(8, 70);
_time = vec(seqa(1, 1, 70)*ones(1, 8));
df = asDF(panel[., 1]~_time~panel[., 2:4], "unit", "time", "y", "x1", "x2");
df = dftype(df, META_TYPE_CATEGORY, "unit");
formula = "y ~ x1 + x2";

// Fixed-order pooled CS-ARDL levels estimator.
struct csardlOut csaOut;
csaOut = csardl(panel, 1, 1, 1, "", 0);

print;
print "CS-ARDL fixed-order example";
print "---------------------------";
print "p q cs_lags units nobs: " csaOut.p~csaOut.q~csaOut.cs_lags~csaOut.nunits~csaOut.nobs;
print "Pooled long-run beta";
print csaOut.bigbt;

printCSARDL(csaOut);

// Formula-string workflow with information-criterion lag selection.
// Omitting pend/qend uses the package default maximum lag search bounds.
struct csardlFullOut cfOut;
cfOut = csardlFull(df, cs_lags = 1, formula = formula, verbose = 0, criterion = "bic");

struct csardlECMOut cECMOut;
cECMOut = csardlECM(df, cfOut.pst, cfOut.qst, cfOut.cs_lags, formula, 0);

print;
print "CS-ARDL formula workflow";
print "------------------------";
print "BIC-selected p, q: " cfOut.pst~cfOut.qst;
print "ECM alpha rho:     " cECMOut.alpha~cECMOut.rho;

printCSARDLECM(cECMOut);

// Optional diagnostic layer: unit-specific long-run coefficients, mean-group
// estimates, and a Wald-style poolability check.
struct csardlDiagOut diagOut;
diagOut = csardlDiagnostics(df, cfOut.pst, cfOut.qst, cfOut.cs_lags, formula, 0);
printCSARDLDiagnostics(diagOut);

fit = predictARDL(cfOut.csa, df, formula);
fcst = forecastARDL(cfOut.csa, df, 3, formula);

print;
print "Prediction rows and 3-step forecast";
print rows(fit);
print fcst;

/*
** TODO: Add published-result CS-ARDL validation once exact DGP grids,
**       datasets, and estimator variants are confirmed.
*/
