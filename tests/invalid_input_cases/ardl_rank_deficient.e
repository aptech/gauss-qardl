new;

/*
** Negative ARDL estimator input test.
**
** Expected failure:
** ardl: levels design matrix is rank deficient
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

t = seqa(1, 1, 40);
y = 1 + 0.2*t + rndn(40, 1);
x1 = t;
x2 = x1;

struct ardlOut arOut;
arOut = ardl(y~x1~x2, 1, 0, "", 0);
