new;

library pgraph;
#include pgraph.ext;
#include qardl.prc;
#include wtestlrb.prc;
#include wtestsrp.prc;
#include wtestsrg.prc;
#include icmean.prc;

_pgrid = {1,1};
_plwidth = 10;


cls;


__output = 0;         

nnn = 10000;           /* sampel size */

pend = 7;             /* maximum value of p orders selected by the researcher */
qend = 7;             /* maximum value of q orders selected by the researcher */

tau1= 0.25;           /* quantile level 1 selected by the researcher */
tau2= 0.5;            /* quantile level 2 selected by the researcher */
tau3= 0.75;           /* quantile level 3 selected by the researcher */

tau = zeros(3,1);
tau[1,1] = tau1;
tau[2,1] = tau2;
tau[3,1] = tau3;

/* dgp parameters */
alp = 1;
phi = 0.25;
rho = 0.5;
the0= 2;
the1= 3;
gam = the0+the1;
bes = gam/(1-phi);

/* dgp */
eee1= rndn(nnn+1,1);
eee2 = rndn(nnn,1);
eee = eee1[1:nnn];
xxx = cumsumc(eee)~cumsumc(eee2);
uuu = rndn(nnn,1);
yyy = zeros(nnn,1);
jjj = 2;
do until jjj > nnn;
    yyy[jjj] = alp + phi*yyy[jjj-1] + the0*xxx[jjj,1] + the1*xxx[jjj-1,1] 
                   + the0*xxx[jjj,2] + the1*xxx[jjj-1,2] + uuu[jjj];
    jjj = jjj + 1;
endo;

/* data construction */
data = yyy~xxx;

{pst, qst} = pqorder(data,pend,qend);
/* qardl parameter estimation */
{bigbt, cv, bigphi, bigpi, biggam, biglam} = qardl(data,pst,qst,tau);

/* constructing hypotheses */
ca1 = zeros(2,cols(xxx)*rows(tau));
ca1[1,1] = 1; ca1[1,cols(xxx)+1] = -1;
ca1[2,cols(xxx)+1] = 1; ca1[2,2*cols(xxx)+1] = -1;
sm1 = zeros(2,1);

ca2 = zeros(2,pst*rows(tau));
ca2[1,1] = 1; ca2[1,pst+1] = -1;
ca2[2,pst+1] = 1; ca2[2,2*pst+1] = -1;
sm2 = sm1;

ca3 = ca1;
sm3 = sm1;

/* long-run parameter (beta) testing */
{wtlrb1, pvlrb1} = wtestlrb(bigbt,cv,ca1,sm1,data);

/* short-run parameter (phi) testing */
{wtsrp1, pvsrp1} = wtestsrp(bigphi,bigpi,ca2,sm2,data);

/* short-run parameter (gamma) testing */
{wtsrg1, pvsrg1} = wtestsrg(biggam,biglam,ca3,sm3,data);
    
print "=========================================================";    
print "Estimated p order ";
print "=========================================================";    
print pst;
print "=========================================================";    
print "Estimated q order ";
print "=========================================================";    
print qst;
print "=========================================================";    
print "Long-run parameter estimate (Beta)";
print "=========================================================";    
print bigbt;
print "=========================================================";    
print "Covariance matrix estimate of long-run parameter (Beta)";
print "=========================================================";    
print cv;
print "=========================================================";    
print "Short-run parameter estimate (Phi)";
print "=========================================================";    
print bigphi;
print "=========================================================";    
print "Covariance matrix estimate of short-run parameter (Phi)";
print "=========================================================";    
print bigpi;
print "=========================================================";    
print "Short-run parameter estimate (Gamma)";
print "=========================================================";    
print biggam;
print "=========================================================";    
print "Covariance matrix estimate of short-run parameter (Gamma)";
print "=========================================================";    
print biglam;
print "=========================================================";    
print " Wald test (Beta) and its p-value";
print "=========================================================";    
print wtlrb1~pvlrb1;
print "=========================================================";    
print " Wald test (Phi) and its p-value";
print "=========================================================";    
print wtsrp1~pvsrp1;
print "=========================================================";    
print " Wald test (Gamma) and its p-value";
print "=========================================================";    
print wtsrg1~pvsrg1;
print "=========================================================";    
