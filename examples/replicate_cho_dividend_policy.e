new;
library qardl;
cls;

/*
** Published empirical example scaffold:
** Cho, Kim, and Shin (2015), U.S. dividend-policy application.
**
** This script uses the public Shiller stock-market data bundled with the
** package as a transparent dividend/earnings approximation. Treat it as a
** reproducible replication scaffold unless the exact publication data,
** transformations, sample window, and lag specification are supplied.
*/

shiller = loadd(__FILE_DIR $+ "shiller_stocks_qt.csv",
                "date($date) + real_dividend + real_earnings");

tau = seqa(0.10, 0.10, 9);
formula = "real_dividend ~ real_earnings";

/*
** The original QARDL paper demonstrates dividend smoothing and
** cross-quantile heterogeneity. Here we let BIC select p and q from a
** conservative grid, then estimate robust and HAC variants for comparison.
*/
struct qardlFullOut qfRobust;
qfRobust = qardlFull(shiller, 8, 8, tau, formula, 0, "bic", "robust", 0);

struct qardlFullOut qfHAC;
qfHAC = qardlFull(shiller, 8, 8, tau, formula, 0, "bic", "hac", 4);

data = applyQARDLFormula(shiller, formula);

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qfRobust.qa, tau, data);

print;
print "Cho-Kim-Shin dividend-policy replication scaffold";
print "------------------------------------------------";
print "Data: bundled Shiller quarterly real dividends and real earnings";
print "Formula: " formula;
print "Quantiles: " tau';
print;
print "BIC-selected p, q: " qfRobust.pst~qfRobust.qst;
print "ARDL bounds F-statistic: " qfRobust.ardl_fstat;
print;
print "Robust long-run beta by quantile";
print reshape(qfRobust.qa.bigbt, rows(tau), qfRobust.qa.k);
print;
print "HAC long-run beta by quantile";
print reshape(qfHAC.qa.bigbt, rows(tau), qfHAC.qa.k);
print;
print "Constancy tests from robust covariance: statistic | p-value";
print "beta  " wt_beta~pv_beta;
print "gamma " wt_gamma~pv_gamma;
print "phi   " wt_phi~pv_phi;

print;
print "Replication note:";
print "Use this as a public-data scaffold. For exact numerical replication,";
print "replace the bundled data and lag choices with the publication dataset";
print "and specification.";
