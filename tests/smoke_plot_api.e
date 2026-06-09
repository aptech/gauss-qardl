new;

/*
** Optional plot smoke test. This file is run only when
** QARDL_RUN_PLOT_TESTS=1 is set for tests/run_plot_smoke_tests.ps1.
*/

#include ../src/qardl.sdf
#include ../src/qardl.src
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

data = loadd(__FILE_DIR $+ "../examples/qardl_data.dat");
data = data[1:180, 1:3];
tau = { 0.25, 0.5, 0.75 };

struct qardlOut qaOut;
qaOut = qardl(data, 1, 1, tau, "iid", 0, 0);

plotQARDL(qaOut, tau, 0, 0.05);
plotQARDL(qaOut, tau, 1, 0.05);

struct qirfOut qOut;
qOut = qirf(qaOut, qaOut.p, qaOut.q, 4, tau, 1, 1);
plotQIRF(qOut, 0, 0.05);
plotQIRF(qOut, 1, 0.05);

tau_grid = { 0.10, 0.25, 0.40, 0.55, 0.70, 0.85 };

struct qardlOut qaGridOut;
qaGridOut = qardl(data, 1, 1, tau_grid, "iid", 0, 0);

struct qirfOut qGridOut;
qGridOut = qirf(qaGridOut, qaGridOut.p, qaGridOut.q, 4, tau_grid, 1, 1);
plotQIRF(qGridOut, 0, 0.05);

qGridOut.irf_lb = qGridOut.irf - 0.05;
qGridOut.irf_ub = qGridOut.irf + 0.05;
qGridOut.bands_available = 1;
qGridOut.alpha = 0.05;
plotQIRF(qGridOut, 1, 0.05);

print "smoke_plot_api.e: PASS";
