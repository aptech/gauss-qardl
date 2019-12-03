new;
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

library Qreg, pgraph;
#include pgraph.ext;
#include qardl.prc;
#include wtestlrb.prc;
#include wtestsrp.prc;
#include wtestsrg.prc;
#include icmean.prc;

_pgrid = {1,1};
_plwidth = 10;

setQreg;
cls;

_Qreg_algr = 1;       /* Interior-point method       */
_Qreg_PrintIters = 0; /* Do not print the iterations */
__output = 0;         /* Print the statistics        */

nnn = 2000;           /* sample size */
kkk = 2000;           /* number if iterations */

tau1 = 0.20;          /* quantile level 1 */
tau2 = 0.40;          /* quantile level 2 */  
tau3 = 0.60;          /* quantile level 3 */  
tau4 = 0.80;          /* quantile level 4 */  

ppp  = 1;             /* order p of QARDL(p,q) */
qqq  = 2;             /* order q of QARDL(p,q) */  
k0   = 2;             /* # of X variables */

tau = zeros(4,1);
tau[1,1] = tau1;
tau[2,1] = tau2;
tau[3,1] = tau3;
tau[4,1] = tau4;

/* dgp parameters */
alp = 1;
phi = 0.25;
rho = 0.5;
the0= 2;
the1= 3;
gam = the0+the1;
bes = gam/(1-phi);

/* null restrictions */
ca1 = zeros(2,k0*rows(tau));
ca1[1,1] = 1; 
ca1[1,k0+1] = -1; 
ca1[2,2*k0+1] = 1;
ca1[2,3*k0+1] = -1; 
sm1 = zeros(2,1);

ca2 = zeros(1,rows(tau)*ppp);
ca2[1,1] = 1; 
ca2[1,ppp+1] = -1; 
sm2 = 0.0;

ca3 = zeros(1,k0*rows(tau));
ca3[1,1] = 1; 
ca3[1,k0+1] = -1;
sm3 = zeros(1,1);

www = zeros(kkk,9);
iii = 1;
do until iii > kkk;

    /* dgp */
    eee1 = rndn(nnn+1,1);
    eee  = rho*eee1[1:nnn] + (1-rho^2)* eee1[2:(nnn+1)];
    eee2 = rndn(nnn,1);
    eee3 = rndn(nnn,1);
    xxx  = cumsumc(eee)~cumsumc(eee2);
    uuu  = rndn(nnn,1);
    yyy  = zeros(nnn,1);
    jjj  = 2;
    do until jjj > nnn;
        yyy[jjj] = alp + phi*yyy[jjj-1] + the0*xxx[jjj,1] + the1*xxx[jjj-1,1] 
                       + the0*xxx[jjj,2] + the1*xxx[jjj-1,2] + uuu[jjj-1];
        jjj = jjj + 1;
    endo;
    /* data construction */
    data = yyy~xxx;

    /* parameter estimation */
    {bigbt, cv, bigphi, bigpi, biggam, biglam} = qardl(data,ppp,qqq,tau);

    /* long-run parameter (beta) testing */
    {wtlrb1, pvlrb1} = wtestlrb(bigbt,cv,ca1,sm1,data);

    /* short-run parameter (phi) testing */
    {wtsrp1, pvsrp1} = wtestsrp(bigphi,bigpi,ca2,sm2,data);

    /* long-run parameter (gamma) testing */
    {wtsrg1, pvsrg1} = wtestsrg(biggam,biglam,ca3,sm3,data);

    www[iii,1] = iii/kkk;
    www[iii,2] = wtlrb1;
    www[iii,3] = wtsrp1;
    www[iii,4] = wtsrg1;
    www[iii,5] = pvlrb1;
    www[iii,6] = pvsrp1;
    www[iii,7] = pvsrg1;
    www[iii,8]= rndn(1,1)^2;
    www[iii,9]= rndn(1,1)^2 + rndn(1,1)^2;

    print /flush iii;

    iii = iii + 1;
endo;

jjj = 1;
do until jjj > 9;
    www[.,jjj] = sortc(www[.,jjj],1);
    jjj = jjj + 1;
endo;

/* p-p plot of wald test (beta) */
xy(www[.,1]~www[.,5],www[.,1]);
/* p-p plot of wald test (phi) */
xy(www[.,1]~www[.,6],www[.,1]);
/* p-p plot of wald test (gamma) */
xy(www[.,1]~www[.,7],www[.,1]);

/* empirical and null distributions of wald test (beta) */
xy(www[.,2]~www[.,9],www[.,1]);
/* empirical and null distributions of wald test (phi) */
xy(www[.,3]~www[.,8],www[.,1]);
/* empirical and null distributions of wald test (gamma) */
xy(www[.,4]~www[.,8],www[.,1]);
