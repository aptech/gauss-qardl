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


__output = 0;         /* Print the statistics        */

nnn = 5000;    /***************/
kkk = 2000;

tau1 = 0.25;
tau2 = 0.50;
tau3 = 0.75;

tau = zeros(3,1);
tau[1,1] = tau1;
tau[2,1] = tau2;
tau[3,1] = tau3;

alp = 1;
phi = 0.25;
rho = 0.5;
the0= 2;
the1= 3;
gam = the0+the1;
bes = gam/(1-phi);

ca1 = zeros(2,6);
ca1[1,1] = 1; 
ca1[2,2] = 1;
sm1 = zeros(2,1);
sm1[1,1] = 6+2/3;
sm1[2,1] = 6+2/3;

ca2 = zeros(1,3);
ca2[1,1] = 1; 
ca2[1,2] = -1; 
sm2 = 0.0;

ca3 = zeros(1,6);
ca3[1,1] = 1; 
ca3[1,3] = -1;
sm3 = zeros(1,1);

www = zeros(kkk,14);
iii = 1;
do until iii > kkk;

    eee1 = rndn(nnn+1,1);
    eee  = rho*eee1[1:nnn] + (1-rho^2)* eee1[2:(nnn+1)];
    eee2 = rndn(nnn,1);
    eee3 = rndn(nnn,1);
    xxx  = cumsumc(eee)~cumsumc(eee2);
//    xxx = cumsumc(eee);
    uuu  = rndn(nnn,1);
    yyy  = zeros(nnn,1);
    jjj  = 2;
    do until jjj > nnn;
        yyy[jjj] = alp + phi*yyy[jjj-1] + the0*xxx[jjj,1] + the1*xxx[jjj-1,1] 
                       + the0*xxx[jjj,2] + the1*xxx[jjj-1,2] + uuu[jjj-1];
        jjj = jjj + 1;
    endo;

    data = yyy~xxx;

    {bigbt, cv, bigphi, bigpi, biggam, biglam} = qardl(data,1,2,tau);

    {wtlrb1, pvlrb1} = wtestlrb(bigbt,cv,ca1,sm1,data);

    {wtsrp1, pvsrp1} = wtestsrp(bigphi,bigpi,ca2,sm2,data);

    {wtsrg1, pvsrg1} = wtestsrg(biggam,biglam,ca3,sm3,data);

    www[iii,1] = pvlrb1;
    www[iii,2] = pvsrp1;
    www[iii,3] = pvsrg1;
    www[iii,4] = iii/kkk;
    www[iii,5] = rndu(1,1);
    www[iii,6] = wtlrb1;
    www[iii,7] = wtsrp1;
    www[iii,8] = wtsrg1;
    www[iii,9] = iii/kkk;
    www[iii,10]= rndn(1,1)^2;
    www[iii,11]= rndn(1,1)^2 + rndn(1,1)^2;

    print /flush iii;

    iii = iii + 1;
endo;

jjj = 1;
do until jjj > 11;
    www[.,jjj] = sortc(www[.,jjj],1);
    jjj = jjj + 1;
endo;

xy(www[.,1]~www[.,4],www[.,4]);
xy(www[.,2]~www[.,4],www[.,4]);
xy(www[.,3]~www[.,4],www[.,4]);

xy(www[.,6]~www[.,11],www[.,9]);
xy(www[.,7]~www[.,10],www[.,9]);
xy(www[.,8]~www[.,10],www[.,9]);



/*
print "================================================";    
print "Long-run parameter estimates";
print "================================================";    
print bigbt;
print "=================================================";    
print " Covariance Matrix estimate of Long-run parameter";
print "=================================================";    
print cv;
print "=================================================";    
print "Short-run parameter estimates (Phi)";
print "=================================================";    
print bigphi;
print "=================================================";    
print " Covariance Matrix estimate of Long-run parameter";
print "=================================================";    
print bigpi;
print "=================================================";    
print "Short-run parameter estimates (Gamma)";
print "=================================================";    
print biggam;
print "=================================================";    
print " Covariance Matrix estimate of Long-run parameter";
print "=================================================";    
print biglam;
print "=================================================";    
*/
