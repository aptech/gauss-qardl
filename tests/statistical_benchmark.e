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
qa = qardl(data, 1, 1, tau, "robust", 0);
call assert_close(meanc(qa.bigbt), true_beta, 0.15,
                  "seeded DGP mean long-run beta moved too far from truth");

struct qardlECMOut ecm;
ecm = qardlECM(data, 1, 1, tau, "robust", 0);
call assert_true(maxc(abs(ecm.beta_lr - true_beta)) < 0.15,
                 "seeded DGP ECM OLS long-run beta moved too far from truth");
call assert_true(maxc(abs(ecm.rho_ols + 0.75)) < 0.08,
                 "seeded DGP ECM OLS rho moved too far from truth");

struct qardlOut qa_x;
qa_x = qardlX(data, 1, { 1, 1 }, tau, "robust", 0);
call assert_close(qa_x.bigbt, qa.bigbt, 1e-10,
                  "qardlX uniform qvec no longer matches qardl robust estimates");

struct qardlECMOut ecm_x;
ecm_x = qardlECMX(data, 1, { 1, 1 }, tau, "robust", 0);
call assert_close(ecm_x.beta_lr, ecm.beta_lr, 1e-10,
                  "qardlECMX uniform qvec no longer matches qardlECM long-run step");
call assert_close(ecm_x.rho, ecm.rho, 1e-10,
                  "qardlECMX uniform qvec no longer matches qardlECM rho estimates");

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
