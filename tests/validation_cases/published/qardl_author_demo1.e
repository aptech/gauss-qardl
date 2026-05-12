new;

/*
** Published-reference validation for the author-provided QARDL GAUSS demo.
**
** Source reference:
** Jin Seo Cho's QARDL program archive for Cho, Kim, and Shin (2015).
** The exact empirical dividend-policy replication remains pending; this case
** validates the documented demo outputs distributed with the author code.
*/

#include qardl.sdf
#include qardl.src
#include nardl.src
#include csardl.src
#include ardl_dispatch.src
#include wtestlrb.src
#include wtestsrp.src
#include wtestsrg.src
#include icmean.src
#include p_values_qardl.src
#include wtestsym.src
#include wtestconst.src
#include ardlbounds.src
#include qirf.src

proc (0) = assert_close(actual, expected, tol, msg);
    local diff;

    if rows(actual) /= rows(expected) or cols(actual) /= cols(expected);
        errorlog "qardl_author_demo1.e failed: " $+ msg;
        errorlog "  actual shape   = " $+ ftos(rows(actual), "%g", 1, 0) $+ " x " $+ ftos(cols(actual), "%g", 1, 0);
        errorlog "  expected shape = " $+ ftos(rows(expected), "%g", 1, 0) $+ " x " $+ ftos(cols(expected), "%g", 1, 0);
        end;
    endif;

    diff = maxc(abs(vec(actual - expected)));
    if scalmiss(diff) or diff > tol;
        errorlog "qardl_author_demo1.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(diff, "%g", 1, 0);
        errorlog "  tolerance    = " $+ ftos(tol, "%g", 1, 0);
        end;
    endif;
endp;

proc (1) = read_expected(fname);
    retp(csvReadM(__FILE_DIR $+ "../../fixtures/expected/published/" $+ fname));
endp;

data = loadd(__FILE_DIR $+ "../../../examples/qardl_data.dat");
data = data[., 1:3];
tau = { 0.25, 0.5, 0.75 };
tol = 1e-5;
table_tol = 5e-4;

{ pst, qst } = pqorder(data, 7, 7);
call assert_close(pst~qst, read_expected("qardl_author_demo1_order.csv"),
                  1e-12, "author demo selected lag order changed");

struct qardlOut qaOut;
qaOut = qardl(data, pst, qst, tau, "iid", 0, 0);

call assert_close(qaOut.bigbt, read_expected("qardl_author_demo1_bigbt.csv"),
                  tol, "author demo long-run beta changed");
call assert_close(qaOut.bigbt_cov, read_expected("qardl_author_demo1_bigbt_cov.csv"),
                  tol, "author demo beta covariance changed");
call assert_close(qaOut.phi, read_expected("qardl_author_demo1_phi.csv"),
                  tol, "author demo phi changed");
call assert_close(qaOut.phi_cov, read_expected("qardl_author_demo1_phi_cov.csv"),
                  tol, "author demo phi covariance changed");
call assert_close(qaOut.gamma, read_expected("qardl_author_demo1_gamma.csv"),
                  tol, "author demo gamma changed");
call assert_close(qaOut.gamma_cov, read_expected("qardl_author_demo1_gamma_cov.csv"),
                  tol, "author demo gamma covariance changed");

ca1 = zeros(2, 2*rows(tau));
ca1[1, 1] = 1;
ca1[1, 3] = -1;
ca1[2, 3] = 1;
ca1[2, 5] = -1;
sm1 = zeros(2, 1);

ca2 = zeros(2, pst*rows(tau));
ca2[1, 1] = 1;
ca2[1, pst+1] = -1;
ca2[2, pst+1] = 1;
ca2[2, 2*pst+1] = -1;

{ wt_beta, pv_beta } = wtestlrb(qaOut.bigbt, qaOut.bigbt_cov, ca1, sm1, data);
{ wt_phi, pv_phi } = wtestsrp(qaOut.phi, qaOut.phi_cov, ca2, sm1, data);
{ wt_gamma, pv_gamma } = wtestsrg(qaOut.gamma, qaOut.gamma_cov, ca1, sm1, data);
call assert_close(wt_beta~pv_beta|wt_phi~pv_phi|wt_gamma~pv_gamma,
                  read_expected("qardl_author_demo1_wald.csv"),
                  tol, "author demo Wald tests changed");

struct qardlOut qaMedian;
qaMedian = qardl(data, pst, qst, 0.5, "iid", 0, 0);
nnn = rows(data);

se_beta = sqrt(diag(qaMedian.bigbt_cov/(nnn-1)^2));
t_beta = qaMedian.bigbt ./ se_beta;
pv_beta = 2*cdfnc(abs(t_beta));
call assert_close(qaMedian.bigbt~se_beta~t_beta~pv_beta,
                  read_expected("qardl_author_demo2_beta_table.csv"),
                  table_tol, "author demo median beta table changed");

se_phi = sqrt(diag(qaMedian.phi_cov/(nnn-1)));
t_phi = qaMedian.phi ./ se_phi;
pv_phi = 2*cdfnc(abs(t_phi));
call assert_close(qaMedian.phi~se_phi~t_phi~pv_phi,
                  read_expected("qardl_author_demo2_phi_table.csv"),
                  table_tol, "author demo median phi table changed");

se_gamma = sqrt(diag(qaMedian.gamma_cov/(nnn-1)));
t_gamma = qaMedian.gamma ./ se_gamma;
pv_gamma = 2*cdfnc(abs(t_gamma));
call assert_close(qaMedian.gamma~se_gamma~t_gamma~pv_gamma,
                  read_expected("qardl_author_demo2_gamma_table.csv"),
                  table_tol, "author demo median gamma table changed");

print "published/qardl_author_demo1.e: PASS";
