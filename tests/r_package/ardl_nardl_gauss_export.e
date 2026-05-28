new;

/*
** GAUSS-side fixtures for optional validation against the CRAN ardl.nardl
** package. The PowerShell runner creates tests/r_package/actual before this
** script is called.
*/

#include ../../src/qardl.sdf
#include ../../src/qardl.src
#include ../../src/nardl.src

proc (0) = write_numeric_csv(mat, header, fpath);
    local fid, rr, cc, ii, jj, line, ret;

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
        line = "";
        jj = 1;
        do until jj > cc;
            if jj > 1;
                line = line $+ ",";
            endif;
            line = line $+ ftos(mat[ii, jj], "%*.*lf", 1, 15);
            jj = jj + 1;
        endo;
        ret = fputs(fid, line $+ "\n");
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

struct nardlOut naOut;
naOut = nardl(nardl_data, 2, 2, "", 0, "x1", "x2", -1, 1);

call write_numeric_csv(naOut.bigbt, "value", outdir $+ "nardl_bigbt.csv");
call write_numeric_csv(naOut.fitted, "value", outdir $+ "nardl_fitted.csv");
call write_numeric_csv(naOut.resid, "value", outdir $+ "nardl_resid.csv");
call write_numeric_csv(naOut.sigma2, "value", outdir $+ "nardl_sigma2.csv");
call write_numeric_csv(naOut.nobs, "value", outdir $+ "nardl_nobs.csv");

print "ardl_nardl_gauss_export.e: PASS";
