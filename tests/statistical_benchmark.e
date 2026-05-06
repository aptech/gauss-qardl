new;

/*
** Statistical benchmark checks for the source tree.
** These are still lightweight enough for the release gate, but they test
** method-level behavior beyond API shape.
*/

#include ../src/qardl.sdf
#include ../src/qardl.src
#include ../src/wtestlrb.src
#include ../src/wtestsrp.src
#include ../src/wtestsrg.src
#include ../src/icmean.src
#include ../src/p_values_qardl.src
#include ../src/wtestsym.src
#include ../src/wtestconst.src
#include ../src/ardlbounds.src
#include ../src/qirf.src

proc (0) = assert_true(ok, msg);
    if not ok;
        errorlog "statistical_benchmark.e failed: " $+ msg;
        end;
    endif;
endp;

proc (0) = assert_close(actual, expected, tol, msg);
    if maxc(abs(actual - expected)) > tol;
        errorlog "statistical_benchmark.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(maxc(abs(actual - expected)), "%g", 1, 0);
        end;
    endif;
endp;

proc (0) = assert_valid_covariance(mat, tol, msg);
    local dg;

    call assert_close(mat, mat', tol, msg $+ " is not symmetric");
    dg = diag(mat);
    call assert_true(not scalmiss(sumc(dg)) and minc(dg) > -tol,
                     msg $+ " has invalid covariance diagonal");
endp;

proc (1) = qr_cov_benchmark_q0(data, ppp, tau, cov_lags);
    local nn, yy, xx, k0, yyi, X, ONEX, Y, bt;
    local hb, za, jj, uu, fh, D, D_inv, full_cov;
    local theta_start, phi_start, ss, bigbt_cov, phi_cov, gamma_cov;

    nn = rows(data);
    yy = data[., 1];
    xx = data[., 2:cols(data)];
    k0 = cols(xx);
    ss = rows(tau);

    yyi = packr(lagn(yy, seqa(-ppp+1, 1, ppp)));
    yyi = yyi[1:rows(yyi)-1, .];
    X = xx[(rows(xx)+1-rows(yyi)):rows(xx), .]~yyi;
    ONEX = ones(rows(X), 1)~X;
    Y = yy[(nn-rows(X)+1):nn, 1];

    struct qfitControl qCtl;
    qCtl = qfitControlCreate();
    qCtl.const = 0;
    qCtl.verbose = 0;

    struct qfitOut qOut;
    qOut = quantileFit(Y, ONEX, tau, 0, qCtl);
    bt = qOut.beta;

    za = cdfni(0.975);
    hb = zeros(ss, 1);
    fh = zeros(ss, 1);
    jj = 1;
    do until jj > ss;
        hb[jj, 1] = (4.5*pdfn(cdfni(tau[jj,1]))^4/(rows(data)*(2*cdfni(tau[jj,1])^2+1)^2))^0.2;
        uu = Y - ONEX*bt[.,jj];
        fh[jj, 1] = meanc(pdfn(-uu/hb[jj, 1]))/hb[jj, 1];
        jj = jj + 1;
    endo;

    D = ONEX'ONEX / rows(Y);
    D_inv = inv(D);
    full_cov = _qardlQRCovSandwich(ONEX, Y, bt, tau, fh, D_inv, cov_lags);

    theta_start = 2;
    phi_start = 2 + k0;
    { bigbt_cov, phi_cov, gamma_cov } =
        _qardlLevelsCovFromFullPositions(full_cov, bt, theta_start, phi_start, k0, ppp, ss);

    retp(bigbt_cov);
endp;

proc (2) = q0_dgp(nnn, phi, theta, seed);
    local xxx, uuu, yyy, jjj, true_beta;

    rndseed seed;
    xxx = cumsumc(rndn(nnn, 1));
    uuu = rndn(nnn, 1);
    yyy = zeros(nnn, 1);

    jjj = 2;
    do until jjj > nnn;
        yyy[jjj] = 0.5 + phi*yyy[jjj-1] + theta*xxx[jjj] + uuu[jjj];
        jjj = jjj + 1;
    endo;

    true_beta = theta / (1 - phi);
    retp(yyy~xxx, true_beta);
endp;

proc (2) = hetero_q_dgp(nnn, phi, theta1, theta2, dx2_coef, seed);
    local x1, x2, dx2, uuu, yyy, jjj, beta_true;

    rndseed seed;
    x1 = cumsumc(rndn(nnn, 1));
    x2 = cumsumc(rndn(nnn, 1));
    dx2 = zeros(nnn, 1);
    dx2[2:nnn] = x2[2:nnn] - x2[1:nnn-1];
    uuu = rndn(nnn, 1);
    yyy = zeros(nnn, 1);

    jjj = 2;
    do until jjj > nnn;
        yyy[jjj] = 0.25 + phi*yyy[jjj-1]
                   + theta1*x1[jjj] + theta2*x2[jjj]
                   + dx2_coef*dx2[jjj] + uuu[jjj];
        jjj = jjj + 1;
    endo;

    beta_true = (theta1|theta2) / (1 - phi);
    retp(yyy~x1~x2, beta_true);
endp;

rndseed 260504;

nnn = 1200;
alp = 1;
phi = 0.25;
the0 = 2;
the1 = 3;
true_beta = (the0 + the1) / (1 - phi);

eee1 = rndn(nnn+1, 1);
eee2 = rndn(nnn, 1);
xxx = cumsumc(eee1[1:nnn])~cumsumc(eee2);
uuu = rndn(nnn, 1);
yyy = zeros(nnn, 1);

jjj = 2;
do until jjj > nnn;
    yyy[jjj] = alp + phi*yyy[jjj-1]
                    + the0*xxx[jjj, 1] + the1*xxx[jjj-1, 1]
                    + the0*xxx[jjj, 2] + the1*xxx[jjj-1, 2]
                    + uuu[jjj];
    jjj = jjj + 1;
endo;

data = yyy~xxx;
tau = { 0.25, 0.5, 0.75 };

struct qardlOut qa;
qa = qardl(data, 1, 1, tau, "robust", 0, 0);
call assert_close(meanc(qa.bigbt), true_beta, 0.15,
                  "seeded DGP mean long-run beta moved too far from truth");

struct qardlECMOut ecm;
ecm = qardlECM(data, 1, 1, tau, "robust", 0, 0);
call assert_true(maxc(abs(ecm.beta_lr - true_beta)) < 0.15,
                 "seeded DGP ECM OLS long-run beta moved too far from truth");
call assert_true(maxc(abs(ecm.rho_ols + 0.75)) < 0.08,
                 "seeded DGP ECM OLS rho moved too far from truth");

struct qardlOut qa_x;
qa_x = qardlX(data, 1, { 1, 1 }, tau, "robust", 0, 0);
call assert_close(qa_x.bigbt, qa.bigbt, 1e-10,
                  "qardlX uniform qvec no longer matches qardl robust estimates");

struct qardlECMOut ecm_x;
ecm_x = qardlECMX(data, 1, { 1, 1 }, tau, "robust", 0, 0);
call assert_close(ecm_x.beta_lr, ecm.beta_lr, 1e-10,
                  "qardlECMX uniform qvec no longer matches qardlECM long-run step");
call assert_close(ecm_x.rho, ecm.rho, 1e-10,
                  "qardlECMX uniform qvec no longer matches qardlECM rho estimates");

struct qardlOut qa_q0_robust;
struct qardlOut qa_q0_hac;
struct qardlOut qa_q0_hac_auto;
struct qardlOut qa_q0_hac_resolved;
{ data_q0, beta_q0 } = q0_dgp(1000, 0.35, 1.2, 260505);

qa_q0_robust = qardlRobust(data_q0, 1, 0, tau, 0);
call assert_true(maxc(abs(qa_q0_robust.bigbt - beta_q0)) < 0.20,
                 "q=0 robust DGP long-run beta moved too far from truth");
call assert_valid_covariance(qa_q0_robust.bigbt_cov, 1e-8,
                             "q=0 robust long-run covariance");
call assert_close(qa_q0_robust.bigbt_cov,
                  qr_cov_benchmark_q0(data_q0, 1, tau, 0), 1e-10,
                  "q=0 robust covariance no longer matches independent sandwich benchmark");

qa_q0_hac = qardlHAC(data_q0, 1, 0, tau, 3, 0);
call assert_valid_covariance(qa_q0_hac.bigbt_cov, 1e-8,
                             "q=0 HAC long-run covariance");
call assert_close(qa_q0_hac.bigbt_cov,
                  qr_cov_benchmark_q0(data_q0, 1, tau, 3), 1e-10,
                  "q=0 HAC covariance no longer matches independent Bartlett benchmark");
qa_q0_hac_auto = qardlHAC(data_q0, 1, 0, tau, 0, 0);
qa_q0_hac_resolved = qardlHAC(data_q0, 1, 0, tau, _qardlAutomaticHACLags(qa_q0_hac_auto.nobs), 0);
call assert_close(qa_q0_hac_auto.bigbt_cov, qa_q0_hac_resolved.bigbt_cov, 1e-12,
                  "automatic HAC bandwidth no longer matches resolved-bandwidth HAC covariance");

struct qardlOut qa_hetero;
struct qardlECMOut ecm_hetero;
{ data_hetero, beta_hetero } = hetero_q_dgp(1100, 0.20, 1.0, -0.8, 0.7, 260506);

qa_hetero = qardlX(data_hetero, 1, { 0, 1 }, tau, "hac", 2, 0);
call assert_true(maxc(abs(qa_hetero.bigbt - vec(beta_hetero*ones(1, rows(tau))))) < 0.22,
                 "heterogeneous qvec HAC DGP long-run beta moved too far from truth");
call assert_valid_covariance(qa_hetero.bigbt_cov, 1e-8,
                             "heterogeneous qvec HAC long-run covariance");

ecm_hetero = qardlECMX(data_hetero, 1, { 0, 1 }, tau, "hac", 2, 0);
call assert_true(maxc(abs(ecm_hetero.beta_lr - beta_hetero)) < 0.18,
                 "heterogeneous qvec ECM long-run beta moved too far from truth");
call assert_true(maxc(abs(ecm_hetero.rho_ols + 0.80)) < 0.08,
                 "heterogeneous qvec ECM rho moved too far from truth");
call assert_valid_covariance(ecm_hetero.rho_cov, 1e-8,
                             "heterogeneous qvec HAC ECM rho covariance");

cv_i = ardlboundsCaseCV(2, 1, 1000, 0, 0);
call assert_close(cv_i[2, .]', { 2.72, 3.83 }, 1e-12,
                  "Case I k=2 PSS critical values changed");
cv_ii = ardlboundsCaseCV(2, 2, 1000, 0, 0);
call assert_close(cv_ii[2, .]', { 3.10, 3.87 }, 1e-12,
                  "Case II k=2 PSS critical values changed");
cv_iv = ardlboundsCaseCV(2, 4, 1000, 0, 0);
call assert_close(cv_iv[2, .]', { 3.88, 4.61 }, 1e-12,
                  "Case IV k=2 PSS critical values changed");
cv_v = ardlboundsCaseCV(2, 5, 1000, 0, 0);
call assert_close(cv_v[2, .]', { 4.87, 5.85 }, 1e-12,
                  "Case V k=2 PSS critical values changed");

print "statistical_benchmark.e: PASS";
