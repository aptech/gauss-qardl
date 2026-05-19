new;

/*
** Deterministic ARDL bounds-test validation.
**
** Covers PSS deterministic Cases I-V, the legacy Case III wrapper, and a
** fixed-seed simulation critical-value smoke fixture.
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
        errorlog "bounds_validation.e failed: " $+ msg;
        errorlog "  actual shape   = " $+ ftos(rows(actual), "%g", 1, 0) $+ " x " $+ ftos(cols(actual), "%g", 1, 0);
        errorlog "  expected shape = " $+ ftos(rows(expected), "%g", 1, 0) $+ " x " $+ ftos(cols(expected), "%g", 1, 0);
        end;
    endif;

    diff = maxc(abs(vec(actual - expected)));
    if scalmiss(diff) or diff > tol;
        errorlog "bounds_validation.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(diff, "%g", 1, 0);
        errorlog "  tolerance    = " $+ ftos(tol, "%g", 1, 0);
        end;
    endif;
endp;

proc (1) = read_expected(relpath);
    retp(csvReadM(__FILE_DIR $+ "../../fixtures/expected/" $+ relpath));
endp;

data = loadd("examples/qardl_data.dat");
data = data[., 1:3];
expected_cases = read_expected("synthetic/diagnostics/ardl_bounds_cases_i_v.csv");
actual_cases = zeros(5, 4);

for case_id(1, 5, 1);
    { Fstat, tstat, cv, used_case, q_restrict } = ardlboundsCase(data, 2, 1, case_id);
    actual_cases[case_id, .] = used_case~Fstat~tstat~q_restrict;
    call assert_close(cv, ardlboundsCaseCV(2, case_id, 1000, 0, 0), 1e-12,
                      "ardlboundsCase and ardlboundsCaseCV table values differ");
endfor;
call assert_close(actual_cases, expected_cases, 1e-3,
                  "ARDL bounds Cases I-V statistics changed");

{ F_legacy, cv_legacy } = ardlbounds(data, 2, 1);
call assert_close(F_legacy, actual_cases[3, 2], 1e-8,
                  "legacy ardlbounds wrapper no longer matches Case III F-statistic");
call assert_close(cv_legacy, ardlboundsCaseCV(2, 3, 1000, 0, 0), 1e-12,
                  "legacy ardlbounds wrapper no longer returns Case III critical values");

expected_sim = read_expected("synthetic/diagnostics/ardl_bounds_simcv_case3_k2_t80_reps100_seed12345.csv");
call assert_close(ardlboundsCaseSimCV(2, 3, 80, 100, 12345),
                  expected_sim,
                  1e-7, "fixed-seed ARDL bounds simulated critical values changed");
{ Fsim, tsim, cvsim, sim_case, sim_q } = ardlboundsCaseSim(data, 2, 1, 3, 100, 12345);
call assert_close(Fsim~tsim~sim_case~sim_q,
                  actual_cases[3, 2]~actual_cases[3, 3]~3~actual_cases[3, 4],
                  1e-8, "ardlboundsCaseSim statistic dispatch changed");
call assert_close(cvsim, ardlboundsCaseSimCV(2, 3, rows(data), 100, 12345), 1e-7,
                  "ardlboundsCaseSim critical-value dispatch changed");

print "synthetic/bounds_validation.e: PASS";
