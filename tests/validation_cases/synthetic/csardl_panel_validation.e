new;

/*
** CS-ARDL panel-layout validation.
**
** These checks lock down balanced-panel ordering, cross-sectional-average
** construction, lag alignment, formula sorting, and the current
** mean-group/poolability diagnostic calculations.
**
** TODO: Add exact Chudik-Pesaran published Monte Carlo fixtures once the
**       target DGP grid and estimator variants are finalized.
*/

#include src/qardl.sdf
#include src/qardl.src
#include src/csardl.src
#include src/wtestlrb.src
#include src/wtestsrp.src
#include src/wtestsrg.src
#include src/icmean.src
#include src/p_values_qardl.src
#include src/wtestsym.src
#include src/wtestconst.src
#include src/ardlbounds.src

proc (0) = assert_true(ok, msg);
    if not ok;
        errorlog "csardl_panel_validation.e failed: " $+ msg;
        end;
    endif;
endp;

proc (0) = assert_close(actual, expected, tol, msg);
    local diff;

    if rows(actual) /= rows(expected) or cols(actual) /= cols(expected);
        errorlog "csardl_panel_validation.e failed: " $+ msg;
        errorlog "  actual shape   = " $+ ftos(rows(actual), "%g", 1, 0) $+ " x " $+ ftos(cols(actual), "%g", 1, 0);
        errorlog "  expected shape = " $+ ftos(rows(expected), "%g", 1, 0) $+ " x " $+ ftos(cols(expected), "%g", 1, 0);
        end;
    endif;

    diff = maxc(abs(vec(actual - expected)));
    if scalmiss(diff) or diff > tol;
        errorlog "csardl_panel_validation.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(diff, "%g", 1, 0);
        errorlog "  tolerance    = " $+ ftos(tol, "%g", 1, 0);
        end;
    endif;
endp;

proc (1) = read_expected(relpath);
    retp(csvReadM(__FILE_DIR $+ "../../fixtures/expected/" $+ relpath));
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

proc (1) = make_csardl_validation_df(panel, nunits, tobs);
    local panel_time, panel_df;

    panel_time = vec(seqa(1, 1, tobs)*ones(1, nunits));
    panel_df = asDF(panel[., 1]~panel_time~panel[., 2:4], "unit", "time", "y", "x1", "x2");
    panel_df = dftype(panel_df, META_TYPE_CATEGORY, "unit");
    panel_df = dftype(panel_df, META_TYPE_DATE, "time");

    retp(panel_df);
endp;

tol = 1e-10;
small_panel = {
    1 10 1 5,
    1 11 2 4,
    1 13 4 3,
    1 16 7 2,
    2 20 3 6,
    2 21 4 5,
    2 22 5 4,
    2 24 8 1,
    3 30 5 7,
    3 29 6 8,
    3 31 7 9,
    3 35 9 10
};

{ y_small, x_small, csavg_small, unit_ids, unit_nobs } = _csardlBuildDesign(small_panel, 1, 1, 1);
call assert_close(csavg_small,
                  read_expected("synthetic/panels/csardl_known_cross_avg.csv"),
                  tol, "known cross-sectional averages changed");
call assert_close(y_small,
                  read_expected("synthetic/panels/csardl_known_design_y_p1_q1_cs1.csv"),
                  tol, "known CS-ARDL design Y lag alignment changed");
call assert_close(x_small,
                  read_expected("synthetic/panels/csardl_known_design_x_p1_q1_cs1.csv"),
                  tol, "known CS-ARDL design X lag alignment changed");
call assert_close(unit_ids, { 1, 2, 3 }, tol, "balanced panel unit ids changed");
call assert_close(unit_nobs, 4*ones(3, 1), tol, "balanced panel unit observation counts changed");

nunits = 12;
tobs = 90;
formula = "y ~ x1 + x2";
panel = make_csardl_validation_panel(nunits, tobs);
panel_df = make_csardl_validation_df(panel, nunits, tobs);
shuffle_idx = seqa(rows(panel), -1, rows(panel));
panel_df_shuffled = panel_df[shuffle_idx, .];

formula_panel_expected = applyCSARDLFormula(panel_df, formula);
formula_panel = applyCSARDLFormula(panel_df_shuffled, formula);
call assert_close(formula_panel[., 2:4], formula_panel_expected[., 2:4], 1e-12,
                  "formula sorting is not invariant to input row order");

struct csardlOut csa_matrix;
struct csardlOut csa_formula;
csa_matrix = csardl(panel, 2, 1, 1, "", 0);
csa_formula = csardl(panel_df_shuffled, 2, 1, 1, formula, 0);

call assert_close(csa_matrix.bigbt,
                  read_expected("synthetic/coefficients/csardl_seeded_bigbt.csv"),
                  1e-8, "CS-ARDL seeded long-run coefficient fixture changed");
call assert_close(csa_formula.bigbt, csa_matrix.bigbt, tol,
                  "CS-ARDL formula estimates changed after panel sorting");
call assert_close(csa_formula.cross_avg, csa_matrix.cross_avg, 1e-12,
                  "CS-ARDL formula cross-sectional averages changed after panel sorting");
call assert_true(csa_formula.unitvar $== "unit" and csa_formula.timevar $== "time",
                 "CS-ARDL inferred unit/time metadata changed");

struct csardlDiagOut diag_matrix;
struct csardlDiagOut diag_formula;
diag_matrix = csardlDiagnostics(panel, 2, 1, 1, "", 0);
diag_formula = csardlDiagnostics(panel_df_shuffled, 2, 1, 1, formula, 0);

call assert_close(diag_matrix.mean_group_bigbt,
                  read_expected("synthetic/coefficients/csardl_seeded_mean_group_bigbt.csv"),
                  1e-8, "CS-ARDL seeded mean-group fixture changed");
call assert_close(diag_matrix.poolability_wald~diag_matrix.poolability_df~diag_matrix.poolability_pv,
                  read_expected("synthetic/diagnostics/csardl_poolability.csv"),
                  1e-8, "CS-ARDL seeded poolability fixture changed");
call assert_close(diag_formula.mean_group_bigbt, diag_matrix.mean_group_bigbt, tol,
                  "CS-ARDL formula diagnostics changed after panel sorting");
call assert_close(diag_formula.poolability_wald~diag_formula.poolability_df~diag_formula.poolability_pv,
                  diag_matrix.poolability_wald~diag_matrix.poolability_df~diag_matrix.poolability_pv,
                  1e-8, "CS-ARDL formula poolability changed after panel sorting");

manual_mg = zeros(diag_matrix.k, 1);
manual_mg_se = zeros(diag_matrix.k, 1);
for jj(1, diag_matrix.k, 1);
    manual_mg[jj] = meanc(diag_matrix.unit_bigbt[., jj]);
    manual_mg_se[jj] = sqrt(sumc((diag_matrix.unit_bigbt[., jj] - manual_mg[jj])^2) /
                             (diag_matrix.nunits*(diag_matrix.nunits-1)));
endfor;
call assert_close(diag_matrix.mean_group_bigbt, manual_mg, 1e-12,
                  "manual CS-ARDL mean-group reproduction changed");
call assert_close(diag_matrix.mean_group_se, manual_mg_se, 1e-12,
                  "manual CS-ARDL mean-group SE reproduction changed");

manual_poolability = 0;
for ii(1, diag_matrix.nunits, 1);
    { y_unit, x_unit } = _csardlBuildUnitDesign(panel, 2, 1, 1, ii);
    bt_unit = _qardlSafeInv(x_unit'*x_unit, "csardl_panel_validation", "unit moment matrix")*x_unit'*y_unit;
    resid_unit = y_unit - x_unit*bt_unit;
    { cov_unit, sigma2_unit } = _csardlOLSCov(x_unit, resid_unit, "csardl_panel_validation");
    beta_unit = _csardlLongRunBeta(bt_unit, 2, diag_matrix.k);
    beta_cov_unit = _csardlLongRunCov(bt_unit, cov_unit, 2, 1, 1, diag_matrix.k);
    diff = beta_unit - csa_matrix.bigbt;
    manual_poolability = manual_poolability +
                         diff'*_qardlSafeInv(beta_cov_unit, "csardl_panel_validation", "unit long-run covariance")*diff;
endfor;
call assert_close(diag_matrix.poolability_wald, manual_poolability, 1e-10,
                  "manual CS-ARDL poolability reproduction changed");

print "synthetic/csardl_panel_validation.e: PASS";
