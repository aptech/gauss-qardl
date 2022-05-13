new;
library qardl;
cls;

// Maximum value of p orders
pend = 7; 

// Maximum value of q orders
qend = 7;                   

// Quantile levels
tau = { 0.25, 0.5, 0.7 }; 

// Load data
data = loadd(__FILE_DIR $+ "qardl_data.dat");

/*
** This is for demonstration. This step needs 
** to be done to:
** 1) Make sure the data is the correct order, with
**    the dependent variable first.
** 2) Extract the subsets of independent variables
*/

// Specify dependent variable here
yyy = data[., 1];

// Specify independent variables here
xxx = data[., 2:3];  

// Data used in qardl should have
// dependent variable in first column
// independent variable in remaining k 
// cols
data_test = yyy~xxx;                         

// The pqorder procedure estimates the
// optimal order to be used in the 
// the qardl procedure
{ pst, qst } = pqorder(data_test, pend, qend);   

/*
** Parameter estimations
*/

/*
** The output structure qardlOut
** contains the following members:
**
** q_out.bigbt          Matrix, long-run parameter.
** q_out.bigbt_cov      Matrix, covariance of the long-run parameter.
** q_out.phi            Matrix, short-run parameter for the autoregressive 
**                      terms of the dependent variable.
** q_out.phi_cov        Matrix, covariance of the short-run parameter for 
**                      the autoregressive terms of the dependent variable.
** q_out.gamma          Matrix, short-run parameter for the distributed lag 
**                      terms of the independent variables.
** q_out.gamma_cov      Matrix, covariance of the short-run parameter for 
**                      the distributed lag terms of the independent variables.
*/

// Declare output structure
struct qardlOut qaOut;

// Call QARDL procedure
qaOut = qardl(data_test, pst, qst, tau); 

/*
** The hypotheses tests must be
** constructed before calling the 
** Wald tests procedures.
**
**   The Wald statistics test the following hypotheses:
**
**                 i)    Wald test (beta) : ca1 * beta  = sm1;
**                ii)    Wald test (phi)  : ca2 * phi   = sm2;
**               iii)    Wald test (gamma): ca3 * gamma = sm3.
*/

/* Construct test matrices for beta
** We set
**
** ca1 = { 1  0 -1  0  0  0,
**         0  0  1  0 -1  0 }
** and
**
** sm1 = { 0,
**         0 }
**
** To test the hypothesis that
**  Beta_1(tau = 0.25) - Beta_1(tau = 0.5) = 0
**  Beta_1(tau = 0.5)  - Beta_1(tau = 0.75) = 0
*/
            
ca1 = { 1 0 -1 0 0 0,
        0 0 1 0 -1 0 };

sm1 = {0,
       0};

/*  Construct test matrices for phi 
** ( the autoregressive term for the independent variable)
**
** We set
**
** ca2 = { 1  0 -1  0  0  0,
**         0  0  1  0 -1  0 }
** and
**
** sm2 = { 0,
**         0 }
**
** To test the hypothesis that
**  phi_{t-1}(tau = 0.25) - phi_{t-1}(tau = 0.50) = 0
**  phi_{t-1}(tau = 0.50) - phi_{t-1}(tau = 0.75) = 0
** 
*/
ca2 = { 1 0 -1 0 0 0,
        0 0 1 0 -1 0 };
        
sm2 = {0,
       0};

/*  Construct test matrices for gamma
** ( the autoregressive term for the dependent variable)
**
** We set
**
** ca3 = { 1  0 -1  0  0  0,
**         0  0  1  0 -1  0 }
** and
**
** sm3= { 0,
**        0 }
**
** To test the hypothesis that
**  gamma1_{t-1}(tau = 0.25) - gamma1_{t-1}(tau = 0.50) = 0
**  gamma1_{t-1}(tau = 0.50) - gamma1_{t-1}(tau = 0.75) = 0
** 
*/
ca3 = { 1 0 -1 0 0 0,
        0 0 1 0 -1 0 };
        
sm3 = {0,
       0};

// Long-run parameter (beta) testing 
{ wtlrb1, pvlrb1 } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, ca1, sm1, data_test);

// Short-run parameter (phi) testing 
{ wtsrp1, pvsrp1 } = wtestsrp(qaOut.phi, qaOut.phi_cov, ca2, sm2, data_test);

// Short-run parameter (gamma) testing 
{ wtsrg1, pvsrg1 } = wtestsrg(qaOut.gamma, qaOut.gamma_cov, ca3, sm3, data_test);
    
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
print qaOut.bigbt;
print "=========================================================";    
print "Covariance matrix estimate of long-run parameter (Beta)";
print "=========================================================";    
print qaOut.bigbt_cov;
print "=========================================================";    
print "Short-run parameter estimate (Phi)";
print "=========================================================";    
print qaOut.phi;
print "=========================================================";    
print "Covariance matrix estimate of short-run parameter (Phi)";
print "=========================================================";    
print qaOut.phi_cov;
print "=========================================================";    
print "Short-run parameter estimate (Gamma)";
print "=========================================================";    
print qaOut.gamma;
print "=========================================================";    
print "Covariance matrix estimate of short-run parameter (Gamma)";
print "=========================================================";    
print qaOut.gamma_cov;
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

plotQARDl(qaOut, tau);
