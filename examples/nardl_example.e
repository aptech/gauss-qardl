new;
library qardl;
cls;

/*
** NARDL estimation example.
**
** This example uses a small synthetic time-series dataset to show the
** nonlinear ARDL levels estimator, the integrated workflow, formula strings,
** ECM output, prediction/forecast hooks, and model-specific diagnostics.
*/

rndseed 260520;
nnn = 160;
x1 = cumsumc(rndn(nnn, 1));
x2 = cumsumc(rndn(nnn, 1));
y = zeros(nnn, 1);

tt = 2;
do until tt > nnn;
    dx1 = x1[tt] - x1[tt-1];
    dx2 = x2[tt] - x2[tt-1];
    y[tt] = 0.40*y[tt-1] + 0.35*maxc(dx1|0) - 0.18*minc(dx1|0)
            - 0.12*maxc(dx2|0) + 0.28*minc(dx2|0) + 0.25*rndn(1, 1);
    tt = tt + 1;
endo;

data = y~x1~x2;
df = asDF(data, "y", "x1", "x2");
formula = "y ~ x1 + x2";

// Fixed-order levels estimator. Set the final argument to 1 to print here.
struct nardlOut naOut;
naOut = nardl(data, 1, 1, "", 0);

print;
print "NARDL fixed-order example";
print "-------------------------";
print "p q k nobs: " naOut.p~naOut.q~naOut.k~naOut.nobs;
print "Bounds F-stat: " naOut.bounds_fstat;
print "Long-run beta_pos | beta_neg";
print naOut.beta_pos~naOut.beta_neg;
print "Long-run asymmetry tests: statistic | p-value";
print naOut.asymmetry_wald~naOut.asymmetry_pv;

printNARDL(naOut);

// Formula-string integrated workflow with information-criterion lag selection.
// Omitting pend/qend uses the package default maximum lag search bounds.
struct nardlFullOut nfOut;
nfOut = nardlFull(df, formula = formula, verbose = 0, criterion = "bic");

struct nardlECMOut nECMOut;
nECMOut = nardlECM(df, nfOut.pst, nfOut.qst, formula, 0);

print;
print "NARDL formula workflow";
print "----------------------";
print "BIC-selected p, q: " nfOut.pst~nfOut.qst;
print "ECM alpha rho:     " nECMOut.alpha~nECMOut.rho;
print "Short-run asymmetry p-values";
print nfOut.na.short_run_pv;

printNARDLECM(nECMOut);

// Unified prediction and forecast hooks infer the model type.
fit = predictARDL(nfOut.na, df, formula);
fcst = forecastARDL(nfOut.na, df, 3, formula);

print;
print "Prediction rows and 3-step forecast";
print rows(fit);
print fcst;

/*
** TODO: Add published-result NARDL validation once exact datasets and
**       specifications are available for redistribution or reproduction.
*/
