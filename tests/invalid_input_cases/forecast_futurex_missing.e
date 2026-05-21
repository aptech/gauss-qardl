new;

/*
** Negative forecast future_x input test.
**
** Expected failure:
** forecastARDL: future_x contains missing values
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
data = data[1:80, 1:3];

struct ardlOut arOut;
arOut = ardl(data, 1, 1, "", 0);

bad_future_x = data[rows(data), 2:3] | data[rows(data), 2:3];
bad_future_x[2, 1] = error(0);
fcst = forecastARDL(arOut, data, 2, "", bad_future_x);
