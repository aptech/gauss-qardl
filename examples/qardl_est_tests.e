new;
library qardl;
cls;

/*
** Estimation and inference with the modern QARDL API.
**
** This example uses the newer output helpers, automatic tests, and
** string-based custom Wald restrictions.
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
** Custom Wald restrictions can be written directly. The generated R and r
** matrices are returned for auditing or reuse.
*/
restr_beta = "beta[x1,0.25] = beta[x1,0.50]" $|
             "beta[x1,0.50] = beta[x1,0.75]";
restr_gamma = "gamma[x1,0.25] = gamma[x1,0.50]" $|
              "gamma[x1,0.50] = gamma[x1,0.75]";
restr_phi = "phi[1,0.25] = phi[1,0.50]" $|
            "phi[1,0.50] = phi[1,0.75]";

{ wt_beta, pv_beta, bigR_beta, smr_beta } =
    qardlWald(qaOut, "beta", restr_beta, data);
{ wt_gamma, pv_gamma, bigR_gamma, smr_gamma } =
    qardlWald(qaOut, "gamma", restr_gamma, data);
{ wt_phi, pv_phi, bigR_phi, smr_phi } =
    qardlWald(qaOut, "phi", restr_phi, data);

print;
print "Custom Wald tests: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

plotQARDL(qaOut, tau, 1);
