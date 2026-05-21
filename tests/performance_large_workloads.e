new;

/*
** Performance smoke workloads for larger lag grids and bootstrap paths.
** This test checks execution and output shape; wall-clock thresholds live in
** tests/run_performance_smoke.ps1.
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
        errorlog "performance_large_workloads.e failed: " $+ msg;
        end;
    endif;
endp;

data = loadd(__FILE_DIR $+ "../examples/qardl_data.dat");
data = data[1:260, 1:3];
tau = { 0.25, 0.50, 0.75 };

grid = pqorderGrid(data, 4, 4, "bic");
call assert_true(rows(grid) == 20 and cols(grid) == 3,
                 "pqorderGrid large workload shape changed");

xgrid = pqorderXGrid(data, 3, 2, "bic");
call assert_true(rows(xgrid) == 27 and cols(xgrid) == 4,
                 "pqorderXGrid workload shape changed");

ngrid = nardlOrderGrid(data, 3, 3, "bic");
call assert_true(rows(ngrid) == 12 and cols(ngrid) == 3,
                 "nardlOrderGrid workload shape changed");

{ ci_beta, ci_gamma, ci_phi } = blockBootstrapQARDLMethod(data, 1, 1, tau, 8, 0, 0.10, "moving");
call assert_true(rows(ci_beta) == 6 and cols(ci_beta) == 2 and
                 rows(ci_gamma) == 6 and rows(ci_phi) == 3,
                 "blockBootstrapQARDLMethod workload shape changed");

{ ci_rho, ci_alpha } = blockBootstrapQARDLECMMethod(data, 1, 1, tau, 8, 0, 0.10, "moving");
call assert_true(rows(ci_rho) == rows(tau) and cols(ci_rho) == 2 and
                 rows(ci_alpha) == rows(tau) and cols(ci_alpha) == 2,
                 "blockBootstrapQARDLECMMethod workload shape changed");

print "performance_large_workloads.e: PASS";
