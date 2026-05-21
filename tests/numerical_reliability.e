new;

/*
** Numerical reliability checks for shared matrix safety helpers.
*/

#include ../src/qardl.sdf
#include ../src/qardl.src
#include ../src/nardl.src
#include ../src/csardl.src
#include ../src/ardl_dispatch.src
#include ../src/wtestlrb.src
#include ../src/wtestsrp.src
#include ../src/wtestsrg.src
#include ../src/icmean.src
#include ../src/p_values_qardl.src
#include ../src/wtestsym.src
#include ../src/wtestconst.src
#include ../src/ardlbounds.src
#include ../src/qirf.src
#include ../src/diagnostics.src

proc (0) = assert_true(ok, msg);
    if not ok;
        errorlog "numerical_reliability.e failed: " $+ msg;
        end;
    endif;
endp;

proc (0) = assert_close(actual, expected, tol, msg);
    if maxc(abs(actual - expected)) > tol;
        errorlog "numerical_reliability.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(maxc(abs(actual - expected)), "%g", 1, 0);
        end;
    endif;
endp;

singular_mat = { 1 2,
                 2 4 };
near_singular = { 1 0.999999,
                  0.999999 0.999998 };
regular_mat = { 2 0.25,
                0.25 1 };

call assert_true(_qardlConditionNumber(singular_mat) >= 1e250,
                 "singular matrix condition number policy changed");
call assert_true(_qardlConditionNumber(regular_mat) < 10,
                 "regular matrix condition number unexpectedly large");

{ inv_sing, rank_sing } =
    _qardlWaldInvAndRank(singular_mat, "numerical_reliability", "singular Wald covariance matrix");
call assert_true(rank_sing == 1, "rank-adjusted Wald inverse returned wrong rank");
call assert_close(inv_sing, pinv(singular_mat), 1e-12,
                  "rank-deficient Wald inverse no longer uses pseudoinverse");

{ inv_near, rank_near } =
    _qardlWaldInvAndRank(near_singular, "numerical_reliability", "near-singular Wald covariance matrix");
call assert_true(rank_near >= 1 and rows(inv_near) == 2 and cols(inv_near) == 2,
                 "near-singular Wald inverse returned invalid shape");

print "numerical_reliability.e: PASS";
