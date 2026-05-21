new;

/*
** Negative ARDL estimator input test.
**
** Expected failure:
** ardl: data contains missing values; clean or align the sample before estimation
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

data = loadd("examples/qardl_data.dat");
data = data[1:40, 1:3];
data[12, 2] = error(0);

struct ardlOut arOut;
arOut = ardl(data, 1, 1, "", 0);
