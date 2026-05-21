new;

/*
** Negative CS-ARDL forecast future_x input test.
**
** Expected failure:
** forecastCSARDL: future_x paths are not yet supported for panel forecasts
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

panel = {
    1 1.00 0.10 0.20,
    1 1.10 0.15 0.25,
    1 1.20 0.20 0.28,
    1 1.30 0.22 0.30,
    1 1.40 0.24 0.33,
    1 1.50 0.27 0.35,
    2 0.90 0.05 0.12,
    2 1.00 0.08 0.16,
    2 1.08 0.12 0.19,
    2 1.15 0.16 0.24,
    2 1.23 0.19 0.27,
    2 1.30 0.23 0.31
};

struct csardlOut csaOut;
csaOut = csardl(panel, 1, 0, 0, "", 0);

future_x = { 0.5 0.6 };
fcst = forecastARDL(csaOut, panel, 1, "", future_x);
