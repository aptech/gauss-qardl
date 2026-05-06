new;
library qardl;
cls;

/*
** Estimation and inference with the modern QARDL API.
**
** This example keeps the manual Wald-test construction from the original
** example, but anchors it in the newer output helpers and automatic tests.
*/

data = loadd(__FILE_DIR $+ "qardl_data.dat");
data = data[., 1:3];
tau = { 0.25, 0.5, 0.75 };

{ pst, qst } = pqorder(data, 7, 7);
qaOut = qardl(data, pst, qst, tau, "iid", 0, 0);
qECMOut = qardlECM(data, pst, qst, tau, "iid", 0, 0);

printQARDL(qaOut, tau);
printQARDLECM(qECMOut, tau);

print;
print "Model metadata";
print "--------------";
print "levels: p q k nobs = " qaOut.p~qaOut.q~qaOut.k~qaOut.nobs;
print "ecm:    p q k nobs = " qECMOut.p~qECMOut.q~qECMOut.k~qECMOut.nobs;

/*
** Automatic Wald tests:
** - wtestconst tests whether parameters are constant across all quantiles.
** - wtestsym tests tau/(1-tau) symmetry pairs.
*/
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qaOut, tau, data);

print;
print "Constancy tests: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestsym(qaOut, tau, data);

print;
print "Symmetry tests: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

/*
** Manual restriction matrices are still supported for custom hypotheses.
** The output metadata makes the dimensions explicit.
*/
k = qaOut.k;
s = rows(qaOut.tau);

ca_beta = zeros(2, k*s);
ca_beta[1, 1] = 1;
ca_beta[1, k+1] = -1;
ca_beta[2, k+1] = 1;
ca_beta[2, 2*k+1] = -1;
sm_beta = zeros(2, 1);

ca_phi = zeros(2, qaOut.p*s);
ca_phi[1, 1] = 1;
ca_phi[1, qaOut.p+1] = -1;
ca_phi[2, qaOut.p+1] = 1;
ca_phi[2, 2*qaOut.p+1] = -1;
sm_phi = zeros(2, 1);

ca_gamma = ca_beta;
sm_gamma = sm_beta;

{ wt_beta, pv_beta } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, ca_beta, sm_beta, data);
{ wt_phi, pv_phi } = wtestsrp(qaOut.phi, qaOut.phi_cov, ca_phi, sm_phi, data);
{ wt_gamma, pv_gamma } = wtestsrg(qaOut.gamma, qaOut.gamma_cov, ca_gamma, sm_gamma, data);

print;
print "Custom Wald tests: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

plotQARDL(qaOut, tau);
