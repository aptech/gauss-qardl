new;

/*
** Smoke tests for CSV export helpers. These include local source files instead
** of loading `library qardl`.
*/

#include ../src/qardl.sdf
#include ../src/qardl.src
#include ../src/nardl.src
#include ../src/csardl.src
#include ../src/ardl_dispatch.src
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
        errorlog "smoke_export_api.e failed: " $+ msg;
        end;
    endif;
endp;

proc (1) = count_file_rows(fpath);
    local csv_data;

    if filesa(fpath) $== "";
        retp(-1);
    endif;

    csv_data = loadd(fpath);
    retp(rows(csv_data));
endp;

proc (0) = clean_exports(outdir);
    local ret;

    ret = deleteFile(outdir $+ "qardl_beta.csv");
    ret = deleteFile(outdir $+ "qardl_gamma.csv");
    ret = deleteFile(outdir $+ "qardl_phi.csv");
    ret = deleteFile(outdir $+ "qardl_ecm.csv");
    ret = deleteFile(outdir $+ "qardl_ecm_lr.csv");
    ret = deleteFile(outdir $+ "qardl_ecm_qr.csv");
    ret = deleteFile(outdir $+ "ardl_table.md");
    ret = deleteFile(outdir $+ "qardl_table.tex");
    ret = deleteFile(outdir $+ "nardl_table.csv");
    ret = deleteFile(outdir $+ "csardl_table.md");
    ret = deleteFile(outdir $+ "qardl_ecm_table.tex");
endp;

proc (1) = make_csardl_export_panel(nunits, tobs);
    local panel, rr, ii, tidx, x1_prev, x2_prev, y_prev;
    local common1, common2, x1v, x2v, yv;

    rndseed 260611;
    panel = zeros(nunits*tobs, 4);
    rr = 1;

    for ii(1, nunits, 1);
        x1_prev = 0;
        x2_prev = 0;
        y_prev = 0;
        for tidx(1, tobs, 1);
            common1 = sin(tidx/8);
            common2 = cos(tidx/10);
            x1v = 0.45*x1_prev + 0.10*common1 + 0.02*tidx + 0.05*ii + rndn(1, 1);
            x2v = 0.30*x2_prev - 0.08*common2 - 0.01*tidx + 0.04*ii + rndn(1, 1);
            yv = 0.35*y_prev + 0.24*x1v - 0.12*x2v + 0.05*common1 +
                 0.03*ii + 0.20*rndn(1, 1);
            panel[rr, .] = ii~yv~x1v~x2v;
            x1_prev = x1v;
            x2_prev = x2v;
            y_prev = yv;
            rr = rr + 1;
        endfor;
    endfor;

    retp(panel);
endp;

outdir = __FILE_DIR;
call clean_exports(outdir);

data = loadd(__FILE_DIR $+ "../examples/qardl_data.dat");
data = data[1:350, 1:3];
tau = { 0.25, 0.5, 0.75 };

qaOut = qardl(data, 1, 1, tau, "iid", 0, 0);
qECMOut = qardlECM(data, 1, 1, tau, "iid", 0, 0);
arOut = ardl(data, 1, 1, "", 0);
naOut = nardl(data, 1, 1, "", 0);
panel = make_csardl_export_panel(5, 45);
csaOut = csardl(panel, 1, 1, 1, "", 0);

saveQARDLResults(qaOut, tau, outdir);
saveQARDLECMResults(qECMOut, tau, outdir);
saveARDLMarkdown(arOut, outdir $+ "ardl_table.md", 4, 0, 0);
saveARDLLaTeX(qaOut, outdir $+ "qardl_table.tex", 4, 1, 0.90);
saveARDLTable(naOut, outdir $+ "nardl_table.csv", "csv", 5, 1, 0);
saveARDLTable(csaOut, outdir $+ "csardl_table.md", "markdown", 4, 1, 0.95);
saveARDLLaTeX(qECMOut, outdir $+ "qardl_ecm_table.tex", 4, 1, 0.95);

call assert_true(filesa(outdir $+ "qardl_beta.csv") $/= "", "qardl_beta.csv was not written");
call assert_true(filesa(outdir $+ "qardl_gamma.csv") $/= "", "qardl_gamma.csv was not written");
call assert_true(filesa(outdir $+ "qardl_phi.csv") $/= "", "qardl_phi.csv was not written");
call assert_true(filesa(outdir $+ "qardl_ecm.csv") $/= "", "qardl_ecm.csv was not written");
call assert_true(filesa(outdir $+ "qardl_ecm_lr.csv") $/= "", "qardl_ecm_lr.csv was not written");
call assert_true(filesa(outdir $+ "qardl_ecm_qr.csv") $/= "", "qardl_ecm_qr.csv was not written");
call assert_true(filesa(outdir $+ "ardl_table.md") $/= "", "ardl_table.md was not written");
call assert_true(filesa(outdir $+ "qardl_table.tex") $/= "", "qardl_table.tex was not written");
call assert_true(filesa(outdir $+ "nardl_table.csv") $/= "", "nardl_table.csv was not written");
call assert_true(filesa(outdir $+ "csardl_table.md") $/= "", "csardl_table.md was not written");
call assert_true(filesa(outdir $+ "qardl_ecm_table.tex") $/= "", "qardl_ecm_table.tex was not written");

call assert_true(count_file_rows(outdir $+ "qardl_beta.csv") == rows(tau)*qaOut.k,
                 "qardl_beta.csv row count changed");
call assert_true(count_file_rows(outdir $+ "qardl_gamma.csv") == rows(tau)*qaOut.k,
                 "qardl_gamma.csv row count changed");
call assert_true(count_file_rows(outdir $+ "qardl_phi.csv") == rows(tau)*qaOut.p,
                 "qardl_phi.csv row count changed");
call assert_true(count_file_rows(outdir $+ "qardl_ecm.csv") == rows(tau),
                 "qardl_ecm.csv row count changed");
call assert_true(count_file_rows(outdir $+ "qardl_ecm_lr.csv") == qECMOut.k,
                 "qardl_ecm_lr.csv row count changed");
call assert_true(count_file_rows(outdir $+ "qardl_ecm_qr.csv") == rows(tau),
                 "qardl_ecm_qr.csv row count changed");

call clean_exports(outdir);

print "smoke_export_api.e: PASS";
