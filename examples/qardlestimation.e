new;
library qardl;
cls;

/*
** Simulated-data QARDL estimation with the modern API.
**
** This keeps the original DGP idea, but uses the newer workflow objects,
** metadata fields, print helpers, QIRF, and bootstrap helpers.
*/

// DGP parameters
nnn = 3000;
alp = 1;
phi = 0.25;
the0 = 2;
the1 = 3;
true_beta = (the0 + the1) / (1 - phi);

// Generate two integrated regressors and a dependent variable.
eee1 = rndn(nnn+1, 1);
eee2 = rndn(nnn, 1);
xxx = cumsumc(eee1[1:nnn])~cumsumc(eee2);
uuu = rndn(nnn, 1);
yyy = zeros(nnn, 1);

jjj = 2;
do until jjj > nnn;
    yyy[jjj] = alp + phi*yyy[jjj-1]
                    + the0*xxx[jjj, 1] + the1*xxx[jjj-1, 1]
                    + the0*xxx[jjj, 2] + the1*xxx[jjj-1, 2]
                    + uuu[jjj];
    jjj = jjj + 1;
endo;

data = yyy~xxx;
tau = { 0.25, 0.5, 0.75 };

// Silent integrated workflow. Set the last argument to 1 for printed output.
qfOut = qardlFull(data, 4, 4, tau, "", 0);

print;
print "Simulated-data QARDL";
print "--------------------";
print "True long-run beta: " true_beta;
print "Selected p, q:      " qfOut.pst~qfOut.qst;
print "Bounds F-stat:      " qfOut.ardl_fstat;
print "Metadata p q k nobs:" qfOut.qa.p~qfOut.qa.q~qfOut.qa.k~qfOut.qa.nobs;

printQARDL(qfOut.qa, tau);

{ p_beta, p_phi, p_gamma } = qardl_pval(qfOut.qa);
print;
print "Long-run beta estimates and p-values";
print qfOut.qa.bigbt~p_beta;

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qfOut.qa, tau, data);

print;
print "Constancy tests: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

qOut = qirf(qfOut.qa, qfOut.qa.p, qfOut.qa.q, 10, tau);
print;
print "Permanent-shock QIRF";
print qOut.irf;

// Small, fast bootstrap demonstration. Use a larger B in applied work.
{ ci_rho, ci_alpha } =
    blockBootstrapQARDLECM(data[1:500, .], qfOut.ecm.p, qfOut.ecm.q, tau, 25, 10, 0.05);

print;
print "ECM bootstrap rho intervals";
print ci_rho;
