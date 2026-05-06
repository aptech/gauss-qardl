new;

/*
** Smoke tests for CSV export helpers. These include local source files instead
** of loading `library qardl`.
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
endp;

outdir = __FILE_DIR;
call clean_exports(outdir);

data = loadd(__FILE_DIR $+ "../examples/qardl_data.dat");
data = data[1:350, 1:3];
tau = { 0.25, 0.5, 0.75 };

qaOut = qardl(data, 1, 1, tau, "iid", 0, 0);
qECMOut = qardlECM(data, 1, 1, tau, "iid", 0, 0);

saveQARDLResults(qaOut, tau, outdir);
saveQARDLECMResults(qECMOut, tau, outdir);

call assert_true(filesa(outdir $+ "qardl_beta.csv") $/= "", "qardl_beta.csv was not written");
call assert_true(filesa(outdir $+ "qardl_gamma.csv") $/= "", "qardl_gamma.csv was not written");
call assert_true(filesa(outdir $+ "qardl_phi.csv") $/= "", "qardl_phi.csv was not written");
call assert_true(filesa(outdir $+ "qardl_ecm.csv") $/= "", "qardl_ecm.csv was not written");
call assert_true(filesa(outdir $+ "qardl_ecm_lr.csv") $/= "", "qardl_ecm_lr.csv was not written");
call assert_true(filesa(outdir $+ "qardl_ecm_qr.csv") $/= "", "qardl_ecm_qr.csv was not written");

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
