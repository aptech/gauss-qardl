new;
library qardl;
cls;

/*
** CS-ARDL step-by-step estimation example.
**
** The matrix panel is balanced and stacked by unit: [unit, y, x1, x2].
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

// Step 2: Create the matrix panel [unit, y, x1, x2].
panel = make_csardl_example_panel(8, 70);

// Step 3: Estimate a fixed-order pooled CS-ARDL levels model.
csaOut = csardl(panel, 1, 1, 1, "", 0);

// Step 4: Access selected output fields directly from the returned structure.
print;
print "CS-ARDL fixed-order example";
print "---------------------------";
print "p q cs_lags units nobs: " csaOut.p~csaOut.q~csaOut.cs_lags~csaOut.nunits~csaOut.nobs;
print "Pooled long-run beta";
print csaOut.bigbt;

// Step 5: Print the standard formatted CS-ARDL coefficient table.
printCSARDL(csaOut);

// Step 6: Run the optional mean-group and panel diagnostic layer.
//         This reports unit-specific long-run coefficients, mean-group
//         estimates, Wald-style checks, and Pesaran CD.
struct csardlDiagOut diagOut;
diagOut = csardlDiagnostics(panel, 1, 1, 1, "", 0);
printCSARDLDiagnostics(diagOut);
print "Slope heterogeneity p-value: " diagOut.slope_hetero_pv;
print "Pesaran CD p-value: " diagOut.cd_pv;

/*
** TODO: Add published-result CS-ARDL validation once exact DGP grids,
**       datasets, and estimator variants are confirmed.
*/
