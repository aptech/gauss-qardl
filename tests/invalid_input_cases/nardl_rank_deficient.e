new;

/*
** Negative NARDL estimator input test.
**
** Expected failure:
** nardl: levels design matrix is rank deficient
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

t = seqa(1, 1, 60);
x1 = cumsumc(sin(t/6));
x2 = x1;
y = 0.5 + 0.3*x1 - 0.1*x2 + 0.05*rndn(60, 1);

struct nardlOut naOut;
naOut = nardl(y~x1~x2, 1, 0, "", 0);
