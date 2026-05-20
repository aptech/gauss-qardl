new;

/*
** Synthetic benchmark harness for the NARDL and CS-ARDL model families.
** TODO: Replace or supplement these synthetic cases with published-result
**       replications once redistribution-safe datasets and exact
**       specifications are available.
*/

#include ../src/qardl.sdf
#include ../src/qardl.src
#include ../src/nardl.src
#include ../src/csardl.src
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
        errorlog "benchmark_nardl_csardl.e failed: " $+ msg;
        end;
    endif;
endp;

proc (1) = make_nardl_benchmark_data(nnn);
    local x1, x2, y, ii;

    rndseed 260511;
    x1 = cumsumc(rndn(nnn, 1));
    x2 = cumsumc(rndn(nnn, 1));
    y = zeros(nnn, 1);

    ii = 2;
    do until ii > nnn;
        y[ii] = 0.42*y[ii-1] + 0.30*x1[ii] - 0.18*x2[ii] +
                0.10*(x1[ii] - x1[ii-1]) - 0.06*(x2[ii] - x2[ii-1]) +
                0.25*rndn(1, 1);
        ii = ii + 1;
    endo;

    retp(y~x1~x2);
endp;

proc (1) = make_csardl_benchmark_panel(nunits, tobs);
    local panel, rr, ii, tidx, x1_prev, x2_prev, y_prev;
    local common1, common2, x1v, x2v, yv;

    rndseed 260512;
    panel = zeros(nunits*tobs, 4);
    rr = 1;

    for ii(1, nunits, 1);
        x1_prev = 0;
        x2_prev = 0;
        y_prev = 0;
        for tidx(1, tobs, 1);
            common1 = sin(tidx/7);
            common2 = cos(tidx/11);
            x1v = 0.50*x1_prev + 0.15*common1 + 0.04*tidx + 0.10*ii + rndn(1, 1);
            x2v = 0.30*x2_prev - 0.10*common2 - 0.02*tidx + 0.07*ii + rndn(1, 1);
            yv = 0.40*y_prev + 0.28*x1v - 0.16*x2v + 0.08*common1 +
                 0.04*ii + 0.20*rndn(1, 1);
            panel[rr, .] = ii~yv~x1v~x2v;
            x1_prev = x1v;
            x2_prev = x2v;
            y_prev = yv;
            rr = rr + 1;
        endfor;
    endfor;

    retp(panel);
endp;

print "benchmark_nardl_csardl.e";

nardl_data = make_nardl_benchmark_data(300);
struct nardlOut naOut;
naOut = nardl(nardl_data, 2, 2, "", 0);

struct nardlECMOut nECMOut;
nECMOut = nardlECM(nardl_data, 2, 2, "", 0);

call assert_true(naOut.nobs > 250 and rows(naOut.beta_pos) == 2,
                 "NARDL benchmark output shape changed");
call assert_true(nECMOut.sigma2 > 0 and rows(nECMOut.bt) > 1,
                 "NARDL ECM benchmark output shape changed");

panel = make_csardl_benchmark_panel(12, 90);
struct csardlOut csaOut;
csaOut = csardl(panel, 2, 1, 1, "", 0);

struct csardlDiagOut diagOut;
diagOut = csardlDiagnostics(panel, 2, 1, 1, "", 0);

call assert_true(csaOut.nunits == 12 and csaOut.nobs > 900,
                 "CS-ARDL benchmark output shape changed");
call assert_true(rows(diagOut.mean_group_bigbt) == 2 and
                 diagOut.poolability_pv >= 0 and diagOut.poolability_pv <= 1 and
                 diagOut.slope_hetero_pv >= 0 and diagOut.slope_hetero_pv <= 1 and
                 diagOut.cd_pv >= 0 and diagOut.cd_pv <= 1,
                 "CS-ARDL diagnostics benchmark output shape changed");

print "NARDL beta_pos:";
print naOut.beta_pos';
print "NARDL beta_neg:";
print naOut.beta_neg';
print "CS-ARDL pooled long-run beta:";
print csaOut.bigbt';
print "CS-ARDL mean-group long-run beta:";
print diagOut.mean_group_bigbt';
print "CS-ARDL poolability Wald, df, p-value:";
print diagOut.poolability_wald~diagOut.poolability_df~diagOut.poolability_pv;
print "CS-ARDL slope heterogeneity Wald, df, p-value:";
print diagOut.slope_hetero_wald~diagOut.slope_hetero_df~diagOut.slope_hetero_pv;
print "CS-ARDL Pesaran CD, p-value, average residual correlation:";
print diagOut.cd_stat~diagOut.cd_pv~diagOut.cd_avg_corr;

print "benchmark_nardl_csardl.e: PASS";
