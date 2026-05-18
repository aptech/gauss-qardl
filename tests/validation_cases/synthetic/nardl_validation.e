new;

/*
** Deterministic NARDL validation for decomposition, asymmetric effects,
** bounds-style diagnostics, and dynamic multipliers.
**
** TODO: Add exact Shin-Yu-Greenwood-Nimmo published-result fixtures once
**       redistribution-safe datasets and specifications are available.
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
        errorlog "nardl_validation.e failed: " $+ msg;
        errorlog "  actual shape   = " $+ ftos(rows(actual), "%g", 1, 0) $+ " x " $+ ftos(cols(actual), "%g", 1, 0);
        errorlog "  expected shape = " $+ ftos(rows(expected), "%g", 1, 0) $+ " x " $+ ftos(cols(expected), "%g", 1, 0);
        end;
    endif;

    diff = maxc(abs(vec(actual - expected)));
    if scalmiss(diff) or diff > tol;
        errorlog "nardl_validation.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(diff, "%g", 1, 0);
        errorlog "  tolerance    = " $+ ftos(tol, "%g", 1, 0);
        end;
    endif;
endp;

proc (1) = read_expected(relpath);
    retp(csvReadM(__FILE_DIR $+ "../../fixtures/expected/" $+ relpath));
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

tol = 1e-8;

xsmall = { 1 10,
           3 8,
           2 9,
           5 7,
           4 7.5 };
ysmall = seqa(1, 1, rows(xsmall));
dsmall = ysmall~xsmall;

{ x_pos, x_neg, dx_pos, dx_neg } = _nardlPartialSumsWithDiffs(dsmall);
call assert_close(x_pos, read_expected("synthetic/decompositions/nardl_partial_sums_pos.csv"),
                  tol, "NARDL positive partial sums changed");
call assert_close(x_neg, read_expected("synthetic/decompositions/nardl_partial_sums_neg.csv"),
                  tol, "NARDL negative partial sums changed");
call assert_close(dx_pos, read_expected("synthetic/decompositions/nardl_diff_pos.csv"),
                  tol, "NARDL positive differences changed");
call assert_close(dx_neg, read_expected("synthetic/decompositions/nardl_diff_neg.csv"),
                  tol, "NARDL negative differences changed");

nardl_data = make_nardl_validation_data(300);
struct nardlOut naOut;
naOut = nardl(nardl_data, 2, 2, "", 0);

call assert_close(naOut.bigbt, read_expected("synthetic/coefficients/nardl_seeded_bigbt.csv"),
                  tol, "NARDL long-run coefficients changed");
call assert_close(naOut.theta_pos, read_expected("synthetic/coefficients/nardl_seeded_theta_pos.csv"),
                  tol, "NARDL positive level coefficients changed");
call assert_close(naOut.theta_neg, read_expected("synthetic/coefficients/nardl_seeded_theta_neg.csv"),
                  tol, "NARDL negative level coefficients changed");
call assert_close(naOut.phi, read_expected("synthetic/coefficients/nardl_seeded_phi.csv"),
                  tol, "NARDL phi coefficients changed");
call assert_close(naOut.asymmetry_wald~naOut.asymmetry_pv,
                  read_expected("synthetic/diagnostics/nardl_asymmetry.csv"),
                  tol, "NARDL long-run asymmetry diagnostics changed");
call assert_close(naOut.short_run_wald~naOut.short_run_pv,
                  read_expected("synthetic/diagnostics/nardl_short_run_asymmetry.csv"),
                  tol, "NARDL short-run asymmetry diagnostics changed");
call assert_close(naOut.bounds_fstat,
                  read_expected("synthetic/diagnostics/nardl_bounds_fstat.csv"),
                  tol, "NARDL bounds F-statistic changed");

struct nardlDynMultOut dmOut;
dmOut = nardlDynamicMultipliers(naOut, 6);
call assert_close(dmOut.pos, read_expected("synthetic/multipliers/nardl_dynamic_pos_h6.csv"),
                  tol, "NARDL positive dynamic multipliers changed");
call assert_close(dmOut.neg, read_expected("synthetic/multipliers/nardl_dynamic_neg_h6.csv"),
                  tol, "NARDL negative dynamic multipliers changed");
call assert_close(dmOut.asymmetry, read_expected("synthetic/multipliers/nardl_dynamic_asym_h6.csv"),
                  tol, "NARDL asymmetric dynamic multipliers changed");

print "synthetic/nardl_validation.e: PASS";

