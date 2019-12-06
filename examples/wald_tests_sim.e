
/****************************************************************************
This program conducts Monte Carlo experiments 
for the Wald test statistics defined in Cho, Kim, and Shin (2013).

Wald tests for 

1) beta coefficients;
2) phi coefficients;
3) gamma coefficients 

are computed kkk times using nnn number of observations, 
and their null distributions are compared with their null distributions.

Oct. 15, 2013
Jin Seo Cho
****************************************************************************/

new;
library qardl;


// Sample size
nnn = 2000;   

// Number of iterations
kkk = 2000;           

// Quantile levels
tau = { 0.2, 0.4, 0.6, 0.8 }; 

// Order p of QARDL(p,q)
ppp  = 1;             

// Order q of QARDL(p,q)
qqq  = 2;            

// Number of independent variables
k0   = 2;           


// dgp parameters 
alp = 1;
phi = 0.25;
rho = 0.5;
the0= 2;
the1= 3;
gam = the0+the1;
bes = gam/(1-phi);

// null restrictions
ca1 = zeros(2, k0*rows(tau));
ca1[1, 1] = 1; 
ca1[1, k0+1] = -1; 
ca1[2, 2*k0+1] = 1;
ca1[2, 3*k0+1] = -1; 
sm1 = zeros(2, 1);

ca2 = zeros(1, rows(tau)*ppp);
ca2[1, 1] = 1; 
ca2[1, ppp+1] = -1; 
sm2 = 0.0;

ca3 = zeros(1, k0*rows(tau));
ca3[1, 1] = 1; 
ca3[1, k0+1] = -1;
sm3 = zeros(1, 1);

// Storage matrix
www = zeros(kkk, 9);
iii = 1;
do until iii > kkk;

    // DGP
    eee1 = rndn(nnn+1, 1);
    eee  = rho*eee1[1:nnn] + (1-rho^2)* eee1[2:(nnn+1)];
    eee2 = rndn(nnn, 1);
    eee3 = rndn(nnn, 1);
    xxx  = cumsumc(eee)~cumsumc(eee2);
    uuu  = rndn(nnn, 1);
    yyy  = zeros(nnn, 1);
    jjj  = 2;
    do until jjj > nnn;
        yyy[jjj] = alp + phi*yyy[jjj-1] + the0*xxx[jjj, 1] + the1*xxx[jjj-1, 1] 
                       + the0*xxx[jjj, 2] + the1*xxx[jjj-1, 2] + uuu[jjj-1];
        jjj = jjj + 1;
    endo;
    
    // data construction 
    data = yyy~xxx;

    // Parameter estimation
    struct qardlOut qaOut;
    qaOut = qardl(data, ppp, qqq, tau); 

    // Long-run parameter (beta) testing 
    { wtlrb1, pvlrb1 } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, ca1, sm1, data);

    // Short-run parameter (phi) testing 
    { wtsrp1, pvsrp1 } = wtestsrp(qaOut.phi, qaOut.phi_cov, ca2, sm2, data);

    // Short-run parameter (gamma) testing 
    { wtsrg1, pvsrg1 } = wtestsrg(qaOut.gamma, qaOut.gamma_cov, ca3, sm3, data);

    www[iii, 1] = iii/kkk;
    www[iii, 2] = wtlrb1;
    www[iii, 3] = wtsrp1;
    www[iii, 4] = wtsrg1;
    www[iii, 5] = pvlrb1;
    www[iii, 6] = pvsrp1;
    www[iii, 7] = pvsrg1;
    www[iii, 8] = rndn(1, 1)^2;
    www[iii, 9] = rndn(1, 1)^2 + rndn(1, 1)^2;

    print /flush iii;

    iii = iii + 1;
endo;

jjj = 1;
do until jjj > 9;
    www[., jjj] = sortc(www[., jjj], 1);
    jjj = jjj + 1;
endo;

// p-p plot of wald test (beta) 
plotOpenWindow();
plotXY(www[., 1]~www[., 5], www[., 1]);

// p-p plot of wald test (phi) 
plotOpenWindow();
plotXY(www[., 1]~www[., 6], www[., 1]);

// p-p plot of wald test (gamma) 
plotOpenWindow();
plotXY(www[., 1]~www[., 7], www[., 1]);

// empirical and null distributions of wald test (beta) 
plotOpenWindow();
plotXY(www[., 2]~www[., 9], www[., 1]);

// empirical and null distributions of wald test (phi) 
plotOpenWindow();
plotXY(www[., 3]~www[., 8], www[., 1]);

// empirical and null distributions of wald test (gamma) 
plotOpenWindow();
plotXY(www[., 4]~www[., 8], www[., 1]);
