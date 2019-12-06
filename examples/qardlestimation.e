new;
library qardl;
cls;

// Number of iterations
nnn = 5000;    
kkk = 2000;

// Quantile levels
tau = { 0.25, 0.5, 0.7 }; 

// DGP parameters
alp = 1;
phi = 0.25;
rho = 0.5;
the0= 2;
the1= 3;
gam = the0+the1;
bes = gam/(1-phi);

// Restriction matrices
ca1 = zeros(2, 6);
ca1[1, 1] = 1; 
ca1[2, 2] = 1;
sm1 = zeros(2, 1);
sm1[1, 1] = 6+2/3;
sm1[2, 1] = 6+2/3;

ca2 = zeros(1, 3);
ca2[1, 1] = 1; 
ca2[1, 2] = -1; 
sm2 = 0.0;

ca3 = zeros(1,6);
ca3[1, 1] = 1; 
ca3[1, 3] = -1;
sm3 = zeros(1, 1);

// Storage matrix
www = zeros(kkk, 14);
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

    data = yyy~xxx;

    // Parameter estimation
    struct qardlOut qaOut;
    qaOut = qardl(data, 1, 2, tau); 

    // Long-run parameter (beta) testing 
    { wtlrb1, pvlrb1 } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, ca1, sm1, data);

    // Short-run parameter (phi) testing 
    { wtsrp1, pvsrp1 } = wtestsrp(qaOut.phi, qaOut.phi_cov, ca2, sm2, data);

    // Short-run parameter (gamma) testing 
    { wtsrg1, pvsrg1 } = wtestsrg(qaOut.gamma, qaOut.gamma_cov, ca3, sm3, data);

    www[iii, 1] = pvlrb1;
    www[iii, 2] = pvsrp1;
    www[iii, 3] = pvsrg1;
    www[iii, 4] = iii/kkk;
    www[iii, 5] = rndu(1, 1);
    www[iii, 6] = wtlrb1;
    www[iii, 7] = wtsrp1;
    www[iii, 8] = wtsrg1;
    www[iii, 9] = iii/kkk;
    www[iii, 10]= rndn(1, 1)^2;
    www[iii, 11]= rndn(1, 1)^2 + rndn(1, 1)^2;

    print /flush iii;

    iii = iii + 1;
endo;

jjj = 1;
do until jjj > 11;
    www[., jjj] = sortc(www[., jjj],1);
    jjj = jjj + 1;
endo;

plotOpenWindow();
plotXY(www[., 1]~www[., 4],www[., 4]);

plotOpenWindow();
plotXY(www[., 2]~www[., 4],www[., 4]);

plotOpenWindow();
plotXY(www[., 3]~www[., 4],www[., 4]);

plotOpenWindow();
plotXY(www[., 6]~www[., 11],www[., 9]);

plotOpenWindow();
plotXY(www[., 7]~www[., 10],www[., 9]);

plotOpenWindow();
plotXY(www[., 8]~www[., 10],www[., 9]);



