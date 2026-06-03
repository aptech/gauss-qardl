new;

/*
** GAUSS-side fixtures for optional validation against the CRAN ardl.nardl
** package. The PowerShell runner creates tests/r_package/actual before this
** script is called.
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

proc (0) = write_numeric_csv(mat, header, fpath);
    local fid, rr, cc, ii, jj, csv_line, ret;

    fid = fopen(fpath, "w");
    if fid == -1;
        errorlog "ardl_nardl_gauss_export: could not open " $+ fpath;
        end;
    endif;

    ret = fputs(fid, header $+ "\n");
    rr = rows(mat);
    cc = cols(mat);
    ii = 1;
    do until ii > rr;
        csv_line = "";
        jj = 1;
        do until jj > cc;
            if jj > 1;
                csv_line = csv_line $+ ",";
            endif;
            csv_line = csv_line $+ ftos(mat[ii, jj], "%*.*lf", 1, 15);
            jj = jj + 1;
        endo;
        ret = fputs(fid, csv_line $+ "\n");
        ii = ii + 1;
    endo;

    ret = close(fid);
endp;

proc (1) = make_ardl_r_package_data(n);
    local t, x1, x2, y, tt;

    t = seqa(1, 1, n);
    x1 = cumsumc(0.08 + 0.20*sin(t/7) - 0.03*cos(t/5));
    x2 = 0.35*cos(t/9) + 0.015*t + 0.05*sin(t/3);
    y = zeros(n, 1);
    y[1] = 0.45*x1[1] - 0.20*x2[1];

    for tt(2, n, 1);
        y[tt] = 0.48*y[tt-1] + 0.34*x1[tt] - 0.18*x2[tt] +
                0.07*sin(t[tt]/5) - 0.03*cos(t[tt]/4);
    endfor;

    retp(y~x1~x2);
endp;

proc (1) = make_nardl_r_package_data(n);
    local t, x1, x2, y, yy, x_pos, x_neg, tt;

    t = seqa(1, 1, n);
    x1 = cumsumc(0.22*sin(t/6) - 0.17*cos(t/10) + 0.03*sin(t/2));
    x2 = 0.25*cos(t/8) + 0.012*t + 0.03*sin(t/4);
    yy = zeros(n, 1);
    { x_pos, x_neg } = _nardlPartialSums(yy~x1);

    y = zeros(n, 1);
    y[1] = 0.40*x_pos[1] - 0.25*x_neg[1] + 0.15*x2[1];
    for tt(2, n, 1);
        y[tt] = 0.42*y[tt-1] + 0.52*x_pos[tt] - 0.31*x_neg[tt] +
                0.19*x2[tt] + 0.06*sin(t[tt]/5);
    endfor;

    retp(y~x1~x2);
endp;

proc (4) = estimate_validation_ols(Y, X, caller);
    local bt, fitted, resid, sigma2;

    call _qardlCheckFullColumnRank(X, caller, "validation design matrix");
    bt = _qardlSafeInv(X'*X, caller, "validation moment matrix")*X'*Y;
    fitted = X*bt;
    resid = Y - fitted;
    sigma2 = (resid'resid)/(rows(Y) - cols(X));

    retp(bt, fitted, resid, sigma2);
endp;

proc (2) = build_r_ardl_uecm_design(data);
    local nrows, yy, x1, x2, nobs, Y, X, ii, tt;

    nrows = rows(data);
    yy = data[., 1];
    x1 = data[., 2];
    x2 = data[., 3];
    nobs = nrows - 3;
    Y = zeros(nobs, 1);
    X = zeros(nobs, 12);

    for ii(1, nobs, 1);
        tt = ii + 3;
        Y[ii] = yy[tt] - yy[tt-1];
        X[ii, .] = 1~yy[tt-1]~x1[tt-1]~x2[tt-1]~
            (yy[tt-1] - yy[tt-2])~(yy[tt-2] - yy[tt-3])~
            (x1[tt] - x1[tt-1])~(x2[tt] - x2[tt-1])~
            (x1[tt-1] - x1[tt-2])~(x1[tt-2] - x1[tt-3])~
            (x2[tt-1] - x2[tt-2])~(x2[tt-2] - x2[tt-3]);
    endfor;

    retp(Y, X);
endp;

proc (2) = build_r_nardl_uecm_design(data);
    local nrows, yy, x1, x2, dx, dxp, dxn, xp, xn, nobs, Y, X, ii, tt;

    nrows = rows(data);
    yy = data[., 1];
    x1 = data[., 2];
    x2 = data[., 3];

    dx = x1[2:nrows] - x1[1:nrows-1];
    dxp = dx.*(dx .>= 0);
    dxn = dx.*(dx .< 0);
    xp = cumsumc(dxp);
    xn = cumsumc(dxn);

    nobs = nrows - 3;
    Y = zeros(nobs, 1);
    X = zeros(nobs, 12);

    for ii(1, nobs, 1);
        tt = ii + 3;
        Y[ii] = yy[tt] - yy[tt-1];
        X[ii, .] = 1~yy[tt-1]~xp[tt-2]~xn[tt-2]~x2[tt-1]~
            (yy[tt-1] - yy[tt-2])~(yy[tt-2] - yy[tt-3])~
            dxp[tt-2]~dxp[tt-3]~dxn[tt-2]~dxn[tt-3]~
            (x2[tt-1] - x2[tt-2]);
    endfor;

    retp(Y, X);
endp;

outdir = __FILE_DIR $+ "actual/";

ardl_data = make_ardl_r_package_data(180);
nardl_data = make_nardl_r_package_data(180);

call write_numeric_csv(ardl_data, "y,x1,x2", outdir $+ "ardl_input.csv");
call write_numeric_csv(nardl_data, "y,x1,x2", outdir $+ "nardl_input.csv");

struct ardlOut arOut;
arOut = ardl(ardl_data, 2, 2, "", 0);

call write_numeric_csv(arOut.bigbt, "value", outdir $+ "ardl_bigbt.csv");
call write_numeric_csv(arOut.fitted, "value", outdir $+ "ardl_fitted.csv");
call write_numeric_csv(arOut.resid, "value", outdir $+ "ardl_resid.csv");
call write_numeric_csv(arOut.sigma2, "value", outdir $+ "ardl_sigma2.csv");
call write_numeric_csv(arOut.nobs, "value", outdir $+ "ardl_nobs.csv");

{ Y_ardl_uecm, X_ardl_uecm } = build_r_ardl_uecm_design(ardl_data);
{ ar_uecm_bt, ar_uecm_fitted, ar_uecm_resid, ar_uecm_sigma2 } =
    estimate_validation_ols(Y_ardl_uecm, X_ardl_uecm, "ardl R-package UECM validation");

call write_numeric_csv(ar_uecm_bt, "value", outdir $+ "ardl_uecm_bt.csv");
call write_numeric_csv(ar_uecm_fitted, "value", outdir $+ "ardl_uecm_fitted.csv");
call write_numeric_csv(ar_uecm_resid, "value", outdir $+ "ardl_uecm_resid.csv");
call write_numeric_csv(ar_uecm_sigma2, "value", outdir $+ "ardl_uecm_sigma2.csv");
call write_numeric_csv(rows(Y_ardl_uecm), "value", outdir $+ "ardl_uecm_nobs.csv");

struct ardlSparseGETSOut arSPOut;
arSPOut = ardlSparseGETS(ardl_data, 2, 2, "", 0.1, 0);

call write_numeric_csv(arSPOut.keep_cols, "value", outdir $+ "ardl_sparse_gets_keep.csv");
call write_numeric_csv(arSPOut.bt, "value", outdir $+ "ardl_sparse_gets_bt.csv");
call write_numeric_csv(arSPOut.sigma2, "value", outdir $+ "ardl_sparse_gets_sigma2.csv");
call write_numeric_csv(arSPOut.nobs, "value", outdir $+ "ardl_sparse_gets_nobs.csv");
call write_numeric_csv(arSPOut.n_dropped, "value", outdir $+ "ardl_sparse_gets_n_dropped.csv");

struct nardlOut naOut;
naOut = nardl(nardl_data, 2, 2, "", 0, "x1", "x2", -1, 1);

call write_numeric_csv(naOut.bigbt, "value", outdir $+ "nardl_bigbt.csv");
call write_numeric_csv(naOut.fitted, "value", outdir $+ "nardl_fitted.csv");
call write_numeric_csv(naOut.resid, "value", outdir $+ "nardl_resid.csv");
call write_numeric_csv(naOut.sigma2, "value", outdir $+ "nardl_sigma2.csv");
call write_numeric_csv(naOut.nobs, "value", outdir $+ "nardl_nobs.csv");

struct nardlECMOut naECMOut;
naECMOut = nardlECM(nardl_data, 2, 2, "", 0, "x1", "x2", -1, 1);

call write_numeric_csv(naECMOut.bt, "value", outdir $+ "nardl_recm_bt.csv");
call write_numeric_csv(naECMOut.fitted, "value", outdir $+ "nardl_recm_fitted.csv");
call write_numeric_csv(naECMOut.resid, "value", outdir $+ "nardl_recm_resid.csv");
call write_numeric_csv(naECMOut.sigma2, "value", outdir $+ "nardl_recm_sigma2.csv");
call write_numeric_csv(naECMOut.nobs, "value", outdir $+ "nardl_recm_nobs.csv");

{ Y_nardl_uecm, X_nardl_uecm } = build_r_nardl_uecm_design(nardl_data);
{ na_uecm_bt, na_uecm_fitted, na_uecm_resid, na_uecm_sigma2 } =
    estimate_validation_ols(Y_nardl_uecm, X_nardl_uecm, "nardl R-package UECM validation");

call write_numeric_csv(na_uecm_bt, "value", outdir $+ "nardl_uecm_bt.csv");
call write_numeric_csv(na_uecm_fitted, "value", outdir $+ "nardl_uecm_fitted.csv");
call write_numeric_csv(na_uecm_resid, "value", outdir $+ "nardl_uecm_resid.csv");
call write_numeric_csv(na_uecm_sigma2, "value", outdir $+ "nardl_uecm_sigma2.csv");
call write_numeric_csv(rows(Y_nardl_uecm), "value", outdir $+ "nardl_uecm_nobs.csv");

struct ardlSparseGETSOut naSPOut;
naSPOut = nardlSparseGETS(nardl_data, 2, 2, "", "x1", "x2", 1, 0.1,
                          print_results = 0);

call write_numeric_csv(naSPOut.keep_cols, "value", outdir $+ "nardl_sparse_gets_keep.csv");
call write_numeric_csv(naSPOut.bt, "value", outdir $+ "nardl_sparse_gets_bt.csv");
call write_numeric_csv(naSPOut.sigma2, "value", outdir $+ "nardl_sparse_gets_sigma2.csv");
call write_numeric_csv(naSPOut.nobs, "value", outdir $+ "nardl_sparse_gets_nobs.csv");
call write_numeric_csv(naSPOut.n_dropped, "value", outdir $+ "nardl_sparse_gets_n_dropped.csv");

print "ardl_nardl_gauss_export.e: PASS";
