new;
library qardl;
cls;

/*
** Modern QARDL workflow example.
**
** This example uses the higher-level API added in the GAUSS 26 version of the
** library: qardlFull(), output metadata, formatted print helpers, automatic
** Wald tests, QIRF, and bootstrap confidence intervals.
*/

data = loadd(__FILE_DIR $+ "qardl_data.dat");
data = data[., 1:3];

// qardlFull does lag selection, ARDL bounds testing, QARDL levels estimation,
// and QARDL-ECM estimation in one call.
tau = { 0.25, 0.5, 0.75 };
qfOut = qardlFull(data, 7, 7, tau);

print;
print "Selected model metadata";
print "-----------------------";
print "p     = " qfOut.qa.p;
print "q     = " qfOut.qa.q;
print "k     = " qfOut.qa.k;
print "nobs  = " qfOut.qa.nobs;
print "tau   = ";
print qfOut.qa.tau;

// Individual parameter p-values are available without manually computing
// standard errors.
{ p_beta, p_phi, p_gamma } = qardl_pval(qfOut.qa);

print;
print "First few long-run beta p-values";
print p_beta[1:minc(6|rows(p_beta))];

// Automatic cross-quantile tests are usually easier than hand-building
// restriction matrices.
{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qfOut.qa, tau, data);

print;
print "Constancy tests across quantiles: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestsym(qfOut.qa, tau, data);

print;
print "Symmetry tests across quantiles: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

// Quantile impulse response functions use the full coefficient matrix stored
// in qfOut.qa.bt.
qirfOut = qirf(qfOut.qa, qfOut.qa.p, qfOut.qa.q, 12, tau, 1, 1);

print;
print "Permanent-shock QIRF for regressor 1";
print qirfOut.irf;

// Small bootstrap example. Use a larger B, e.g. 999, in applied work.
{ ci_beta, ci_gamma, ci_phi } =
    blockBootstrapQARDL(data[1:350, .], qfOut.qa.p, qfOut.qa.q, tau, 25, 10, 0.05);

print;
print "Bootstrap beta confidence intervals from first 350 observations";
print ci_beta;

// Plot helpers remain separate from estimation, so batch workflows can skip
// them and interactive workflows can opt in.
plotQARDLbands(qfOut.qa, tau);
plotQIRF(qirfOut);
