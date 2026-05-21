new;
library qardl;
cls;

/*
** NARDL full-workflow example.
**
** nardlFull combines lag selection and NARDL levels estimation. This example
** also shows formula strings, ECM output, prediction, and forecasting.
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

// Omitting pend/qend uses the package default maximum lag search bounds.
struct nardlFullOut nfOut;
nfOut = nardlFull(df, formula = formula, verbose = 0, criterion = "bic");

struct nardlECMOut nECMOut;
nECMOut = nardlECM(df, nfOut.pst, nfOut.qst, formula, 0);

print;
print "NARDL formula full workflow";
print "---------------------------";
print "BIC-selected p, q: " nfOut.pst~nfOut.qst;
print "ECM alpha rho:     " nECMOut.alpha~nECMOut.rho;
print "Short-run asymmetry p-values";
print nfOut.na.short_run_pv;

printNARDL(nfOut.na);
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
