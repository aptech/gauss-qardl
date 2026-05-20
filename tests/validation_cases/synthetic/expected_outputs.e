new;

/*
** Deterministic expected-output validation for bundled and seeded synthetic
** ARDL-family fixtures.
**
** TODO: Add published-result validation cases under tests/validation_cases/
**       published once exact datasets and specifications are available.
*/

#include src/qardl.sdf
#include src/qardl.src
#include src/nardl.src
#include src/csardl.src
#include src/ardl_dispatch.src
#include src/wtestlrb.src
#include src/wtestsrp.src
#include src/wtestsrg.src
#include src/icmean.src
#include src/p_values_qardl.src
#include src/wtestsym.src
#include src/wtestconst.src
#include src/ardlbounds.src
#include src/qirf.src
#include src/diagnostics.src

proc (0) = assert_close(actual, expected, tol, msg);
    local diff;

    if rows(actual) /= rows(expected) or cols(actual) /= cols(expected);
        errorlog "expected_outputs.e failed: " $+ msg;
        errorlog "  actual shape   = " $+ ftos(rows(actual), "%g", 1, 0) $+ " x " $+ ftos(cols(actual), "%g", 1, 0);
        errorlog "  expected shape = " $+ ftos(rows(expected), "%g", 1, 0) $+ " x " $+ ftos(cols(expected), "%g", 1, 0);
        end;
    endif;

    diff = maxc(abs(vec(actual - expected)));
    if scalmiss(diff) or diff > tol;
        errorlog "expected_outputs.e failed: " $+ msg;
        errorlog "  max abs diff = " $+ ftos(diff, "%g", 1, 0);
        errorlog "  tolerance    = " $+ ftos(tol, "%g", 1, 0);
        end;
    endif;
endp;

proc (1) = read_expected(relpath);
    retp(csvReadM(__FILE_DIR $+ "../../fixtures/expected/" $+ relpath));
endp;

proc (1) = make_nardl_validation_data(nnn);
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

proc (1) = make_csardl_validation_panel(nunits, tobs);
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

tol = 1e-8;
tau = { 0.25, 0.5, 0.75 };

data = loadd("examples/qardl_data.dat");
data = data[., 1:3];

struct ardlOut arOut;
arOut = ardl(data, 2, 1, "", 0);
call assert_close(arOut.bigbt,
                  read_expected("synthetic/coefficients/ardl_qardl_data_bigbt.csv"),
                  tol, "ARDL long-run coefficient fixture changed");
call assert_close(forecastARDL(arOut, data, 3),
                  read_expected("synthetic/forecasts/ardl_qardl_data_h3.csv"),
                  tol, "ARDL forecast fixture changed");

struct ardlResidualDiagOut rdOut;
rdOut = ardlResidualDiagnostics(arOut, 4);
call assert_close(rdOut.serial_stat~rdOut.serial_df~rdOut.serial_pv~
                  rdOut.hetero_stat~rdOut.hetero_df~rdOut.hetero_pv~
                  rdOut.normality_stat~rdOut.normality_df~rdOut.normality_pv,
                  read_expected("synthetic/diagnostics/ardl_residual_diag.csv"),
                  tol, "ARDL residual diagnostic fixture changed");
call assert_close(rdOut.cusum_stat~rdOut.cusum_pv~rdOut.cusum_crit5~
                  rdOut.cusumsq_stat~rdOut.cusumsq_pv~rdOut.cusumsq_crit5,
                  read_expected("synthetic/diagnostics/ardl_stability_diag.csv"),
                  tol, "ARDL stability diagnostic fixture changed");

{ fstat, cv } = ardlbounds(data, 2, 1);
call assert_close(fstat|vec(cv),
                  read_expected("synthetic/diagnostics/ardl_bounds_case3.csv"),
                  tol, "ARDL bounds diagnostic fixture changed");

struct qardlOut qaOut;
qaOut = qardl(data, 2, 1, tau, "iid", 0, 0);
call assert_close(qaOut.bigbt,
                  read_expected("synthetic/coefficients/qardl_qardl_data_bigbt.csv"),
                  tol, "QARDL long-run coefficient fixture changed");
call assert_close(forecastARDL(qaOut, data, 3),
                  read_expected("synthetic/forecasts/qardl_qardl_data_h3.csv"),
                  tol, "QARDL forecast fixture changed");
rdOut = ardlResidualDiagnostics(qaOut, 4);
call assert_close(rdOut.serial_stat~rdOut.serial_df~rdOut.serial_pv~
                  rdOut.hetero_stat~rdOut.hetero_df~rdOut.hetero_pv~
                  rdOut.normality_stat~rdOut.normality_df~rdOut.normality_pv,
                  read_expected("synthetic/diagnostics/qardl_residual_diag.csv"),
                  tol, "QARDL residual diagnostic fixture changed");
call assert_close(rdOut.cusum_stat~rdOut.cusum_pv~rdOut.cusum_crit5~
                  rdOut.cusumsq_stat~rdOut.cusumsq_pv~rdOut.cusumsq_crit5,
                  read_expected("synthetic/diagnostics/qardl_stability_diag.csv"),
                  tol, "QARDL stability diagnostic fixture changed");

boot_data = data[1:250, .];
{ ci_beta, ci_gamma, ci_phi, boot_diag } =
    blockBootstrapQARDLDiag(boot_data, 1, 1, tau, 2, 10, 0.10, 12345);
call assert_close(ci_beta,
                  read_expected("synthetic/intervals/qardl_bootstrap_ci_beta.csv"),
                  tol, "QARDL bootstrap beta interval fixture changed");
call assert_close(ci_gamma,
                  read_expected("synthetic/intervals/qardl_bootstrap_ci_gamma.csv"),
                  tol, "QARDL bootstrap gamma interval fixture changed");
call assert_close(ci_phi,
                  read_expected("synthetic/intervals/qardl_bootstrap_ci_phi.csv"),
                  tol, "QARDL bootstrap phi interval fixture changed");
call assert_close(boot_diag,
                  read_expected("synthetic/intervals/qardl_bootstrap_diag.csv"),
                  tol, "QARDL bootstrap diagnostic fixture changed");

struct qirfOut qiOut;
qiOut = blockBootstrapQIRF(boot_data, 1, 1, 4, tau, 1, 1, 10, 10, 0.10, 12345);
call assert_close(qiOut.irf,
                  read_expected("synthetic/intervals/qirf_bootstrap_irf.csv"),
                  tol, "QIRF bootstrap point estimate fixture changed");
call assert_close(qiOut.irf_lb,
                  read_expected("synthetic/intervals/qirf_bootstrap_lb.csv"),
                  tol, "QIRF bootstrap lower-band fixture changed");
call assert_close(qiOut.irf_ub,
                  read_expected("synthetic/intervals/qirf_bootstrap_ub.csv"),
                  tol, "QIRF bootstrap upper-band fixture changed");
call assert_close(qiOut.boot_diag,
                  read_expected("synthetic/intervals/qirf_bootstrap_diag.csv"),
                  tol, "QIRF bootstrap diagnostic fixture changed");

nardl_data = make_nardl_validation_data(300);
struct nardlOut naOut;
naOut = nardl(nardl_data, 2, 2, "", 0);
call assert_close(naOut.bigbt,
                  read_expected("synthetic/coefficients/nardl_seeded_bigbt.csv"),
                  tol, "NARDL long-run coefficient fixture changed");
call assert_close(forecastARDL(naOut, nardl_data, 3),
                  read_expected("synthetic/forecasts/nardl_seeded_h3.csv"),
                  tol, "NARDL forecast fixture changed");

panel = make_csardl_validation_panel(12, 90);
struct csardlOut csaOut;
csaOut = csardl(panel, 2, 1, 1, "", 0);
struct csardlDiagOut diagOut;
diagOut = csardlDiagnostics(panel, 2, 1, 1, "", 0);

call assert_close(csaOut.bigbt,
                  read_expected("synthetic/coefficients/csardl_seeded_bigbt.csv"),
                  tol, "CS-ARDL long-run coefficient fixture changed");
call assert_close(forecastARDL(csaOut, panel, 3),
                  read_expected("synthetic/forecasts/csardl_seeded_h3.csv"),
                  tol, "CS-ARDL forecast fixture changed");
call assert_close(diagOut.mean_group_bigbt,
                  read_expected("synthetic/coefficients/csardl_seeded_mean_group_bigbt.csv"),
                  tol, "CS-ARDL mean-group coefficient fixture changed");
call assert_close(diagOut.poolability_wald~diagOut.poolability_df~diagOut.poolability_pv,
                  read_expected("synthetic/diagnostics/csardl_poolability.csv"),
                  tol, "CS-ARDL poolability diagnostic fixture changed");
call assert_close(diagOut.slope_hetero_wald~diagOut.slope_hetero_df~diagOut.slope_hetero_pv,
                  read_expected("synthetic/diagnostics/csardl_slope_heterogeneity.csv"),
                  tol, "CS-ARDL slope heterogeneity diagnostic fixture changed");
call assert_close(diagOut.cd_stat~diagOut.cd_pv~diagOut.cd_pairs~diagOut.cd_avg_corr,
                  read_expected("synthetic/diagnostics/csardl_cd.csv"),
                  tol, "CS-ARDL cross-sectional dependence diagnostic fixture changed");

print "synthetic/expected_outputs.e: PASS";
