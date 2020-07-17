new;
library qardl;
cls;

// Maximum value of p orders
pend = 7; 

// Maximum value of q orders
qend = 7;                   

// Quantile levels
tau = seqa(.1, 0.1, 9); 

// Load data
data = loadd(__FILE_DIR $+ "qardl_data.dat");

// Specify dependent variable here
// This is for demonstration 
yyy = data[., 1];

// Specify independent variables here
xxx = data[., 2:3];  

// Data used in qardl should have
// dependent variable in first column
// independent variable in remaining k 
// cols
data = yyy~xxx;                         

// Set up controls for Wald Testing
// this is done using a waldTestRestrictions
// structure
struct waldTestRestrictions waldR;

// Beta Wald tests
// bigR_beta must have k*rows(tau) columns
waldR.bigR_beta = zeros(2, cols(xxx)*rows(tau));

// Each separate row represents a different test
// restriction for Beta
waldR.bigR_beta[1, 1] = 1;
waldR.bigR_beta[1, 3] = -1;
waldR.bigR_beta[2, 3] = 1;
waldR.bigR_beta[2, 5] = -1;

waldR.smlr_beta =  {0, 0};

// bigR_phi must have pend*rows(tau) columns
waldR.bigR_phi = zeros(1, pend*rows(tau));
waldR.bigR_phi[1, 1] = 1;
waldR.bigR_phi[1, 3] = -1;
waldR.smlr_phi = 0;

// bigR_beta must have k*rows(tau) columns
waldR.bigR_gamma =  zeros(1, cols(xxx)*rows(tau));
waldR.bigR_gamma[1, 1] = 1;
waldR.bigR_gamma[1, 3] = -1; 
waldR.smlr_gamma = 0;

// Parameter estimation
/*
** The rollingqardlOut structure has 6 elements. In each element, the estimates for
** separate tau's are stored in individual columns, while each row corresponds to 
** the separate estimation window. 
** 
** bigbt         An array of beta estimates which contains the estimates for
**               each of the independent variables on a separate plane. 
**                
** bigbt_se      An array of standard error estimates which contains the se estimates
**               for each of the independent variables on a separate plane. 
**
** phi           An array of phi estimates which contains the estimates for 
**               each lagged independent variable on a separate plane. 
**                
** phi_se        An array of standard error estimates which contains the se estimates
**               for each lagged independent variable on a separate plane. 
**                
** gamma         An array of gamma estimates which contains the estimates for
**               each of the independent variables on a separate plane. 
**                
** gamma_se      An array of standard error estimates which contains the se estimates
**               for each of the independent variables on a separate plane. 
*/
struct rollingqardlOut rqaOut;
rqaOut = rollingQardl(data[1:1000, .], pend, qend, tau, waldR); 

/*
** Example of plotting the results
** of Beta1(tau=0.5)
*/
// This extracts the first beta for 
// the 50% quantile 
// It is in the first plane, 
// 5th column
beta1_05 = arraytomat(rqaOut.bigbt[1, ., 5]);

// Set up x-axis counter for
// number of observations
obs = seqa(1, 1, rows(beta1_05));

// Control struct 
struct plotControl myPlot;
myPlot = plotGetDefaults("xy");
plotSetTextInterpreter(&myPlot, "LaTex");

plotSetTitle(&myPlot, "\\beta_1(0.5)", "Arial", 20);

plotXY(myPlot, obs, beta1_05);

// This extracts the second beta for 
// the 50% quantile 
// It is in the first plane, 
// 5th column
beta2_05 = arraytomat(rqaOut.bigbt[2, ., 5]);

plotOpenWindow();

plotSetTitle(&myPlot, "\\beta_2(0.5)", "Arial", 20);

plotXY(myPlot, obs, beta2_05);

/*
** Example of plotting the wald
** statistics
*/
plotOpenWindow();

plotSetTitle(&myPlot, "\\text{Wald Statistic}\\ \\beta_1", "Arial", 20);

plotXY(myPlot, obs, rqaOut.rWaldOut.wald_beta);
