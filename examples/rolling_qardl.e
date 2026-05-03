new;
library qardl;
cls;

/*
** Modern rolling-estimation example.
**
** The rollingQardl procedure still accepts explicit Wald-test restrictions.
** Newer plot helpers can display the rolling beta surfaces directly, and
** rollingQardlECM provides a simpler ECM-focused rolling workflow.
*/

data = loadd(__FILE_DIR $+ "qardl_data.dat");
data = data[1:1000, 1:3];

tau = seqa(0.1, 0.1, 9);
{ pst, qst } = pqorder(data, 7, 7);

// Fit the full sample once so dimensions can be read from metadata.
qaOut = qardl(data, pst, qst, tau);

print;
print "Full-sample model metadata";
print "--------------------------";
print "p q k nobs = " qaOut.p~qaOut.q~qaOut.k~qaOut.nobs;

struct waldTestRestrictions waldR;

// Constancy-style restrictions for beta_1, phi_1, and gamma_1 across the
// first two quantiles. The rolling routine will trim phi restrictions if a
// smaller p is selected in a window.
waldR.bigR_beta = zeros(1, qaOut.k*rows(tau));
waldR.bigR_beta[1, 1] = 1;
waldR.bigR_beta[1, qaOut.k+1] = -1;
waldR.smlr_beta = 0;

waldR.bigR_phi = zeros(1, 7*rows(tau));
waldR.bigR_phi[1, 1] = 1;
waldR.bigR_phi[1, 8] = -1;
waldR.smlr_phi = 0;

waldR.bigR_gamma = zeros(1, qaOut.k*rows(tau));
waldR.bigR_gamma[1, 1] = 1;
waldR.bigR_gamma[1, qaOut.k+1] = -1;
waldR.smlr_gamma = 0;

rqaOut = rollingQardl(data, 7, 7, tau, waldR);
rECMOut = rollingQardlECM(data, pst, qst, tau);
rolling_dims = getorders(rqaOut.bigbt);

print;
print "Rolling QARDL windows: " rolling_dims[2];
print "Rolling ECM windows:   " rows(rECMOut.rho);

// New rolling plot helpers handle the multi-quantile output structures.
plotRollingQARDL(rqaOut, tau);
plotRollingQARDLECM(rECMOut, tau);
