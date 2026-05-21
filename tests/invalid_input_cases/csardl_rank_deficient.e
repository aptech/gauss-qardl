new;

/*
** Negative CS-ARDL estimator input test.
**
** Expected failure:
** csardl: levels design matrix is rank deficient
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

nunits = 3;
tt = 12;
panel = zeros(nunits*tt, 4);
rr = 1;
for ii(1, nunits, 1);
    for jj(1, tt, 1);
        x1 = jj + ii/10;
        x2 = x1;
        y = 0.3*x1 - 0.1*x2 + ii/20;
        panel[rr, .] = ii~y~x1~x2;
        rr = rr + 1;
    endfor;
endfor;

struct csardlOut csaOut;
csaOut = csardl(panel, 1, 0, 0, "", 0);
