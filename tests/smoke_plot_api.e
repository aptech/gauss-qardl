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

print "smoke_plot_api.e: PASS";
