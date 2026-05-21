new;
library qardl;
cls;

/*
** NARDL step-by-step estimation example.
**
** This example uses a small synthetic time-series dataset to show the
** nonlinear ARDL levels estimator and model-specific diagnostics.
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

// Fixed-order levels estimator. Set the final argument to 1 to print here.
struct nardlOut naOut;
naOut = nardl(data, 1, 1, "", 0);

print;
print "NARDL fixed-order example";
print "-------------------------";
print "p q k nobs: " naOut.p~naOut.q~naOut.k~naOut.nobs;
print "Bounds F-stat: " naOut.bounds_fstat;
print "Long-run coefficients";
print "Name          beta_pos      beta_neg";
ii = 1;
do until ii > naOut.k;
    sprintf("x%-9d%14.6f%14.6f", ii, naOut.beta_pos[ii], naOut.beta_neg[ii]);
    ii = ii + 1;
endo;
print "Long-run asymmetry tests";
print "Name        statistic       p-value";
ii = 1;
do until ii > naOut.k;
    sprintf("x%-9d%14.6f%14.6f", ii, naOut.asymmetry_wald[ii], naOut.asymmetry_pv[ii]);
    ii = ii + 1;
endo;

printNARDL(naOut);

/*
** TODO: Add published-result NARDL validation once exact datasets and
**       specifications are available for redistribution or reproduction.
*/
