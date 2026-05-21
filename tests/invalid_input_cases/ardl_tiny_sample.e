new;

/*
** Negative ARDL estimator input test.
**
** Expected failure:
** ardl: not enough observations for the requested lag orders
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

data = {
    1.0 0.2 0.4,
    1.1 0.3 0.5,
    1.2 0.4 0.6,
    1.3 0.5 0.7,
    1.4 0.6 0.8
};

struct ardlOut arOut;
arOut = ardl(data, 3, 1, "", 0);
