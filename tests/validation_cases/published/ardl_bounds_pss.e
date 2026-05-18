new;

/*
** Published-reference validation for selected Pesaran-Shin-Smith ARDL bounds
** critical values. This is a table-value check, not an empirical replication.
**
** TODO: Expand to the full Cases I-V support matrix after the bounds-test
**       support matrix is finalized.
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
        errorlog "ardl_bounds_pss.e failed: " $+ msg;
        errorlog "  actual shape   = " $+ ftos(rows(actual), "%g", 1, 0) $+ " x " $+ ftos(cols(actual), "%g", 1, 0);
        errorlog "  expected shape = " $+ ftos(rows(expected), "%g", 1, 0) $+ " x " $+ ftos(cols(expected), "%g", 1, 0);
        end;
    endif;

    diff = maxc(abs(vec(actual - expected)));
    if scalmiss(diff) or diff > tol;
        errorlog "ardl_bounds_pss.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(diff, "%g", 1, 0);
        errorlog "  tolerance    = " $+ ftos(tol, "%g", 1, 0);
        end;
    endif;
endp;

expected = csvReadM(__FILE_DIR $+ "../../fixtures/expected/published/ardl_bounds_pss_selected_cv.csv");
tol = 1e-12;

for ii(1, rows(expected), 1);
    case_id = expected[ii, 1];
    kk = expected[ii, 2];
    cv = ardlboundsCaseCV(kk, case_id, 1000, 0, 0);
    call assert_close(cv[2, .]',
                      expected[ii, 4:5]',
                      tol,
                      "Case " $+ ftos(case_id, "%g", 1, 0) $+ " selected critical value changed");
endfor;

print "published/ardl_bounds_pss.e: PASS";
