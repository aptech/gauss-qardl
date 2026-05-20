new;

/*
** Negative CS-ARDL formula diagnostic input test.
**
** Expected failure:
** csardlDiagnostics: panel must be balanced and stacked by unit
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
    1 1 1.00 0.10 0.20,
    1 2 1.10 0.15 0.25,
    1 3 1.20 0.20 0.28,
    1 4 1.30 0.22 0.30,
    2 1 0.90 0.05 0.12,
    2 2 1.00 0.08 0.16,
    2 3 1.08 0.12 0.19
};

df = asDF(panel, "unit", "time", "y", "x1", "x2");
df = dftype(df, META_TYPE_CATEGORY, "unit");
df = dftype(df, META_TYPE_DATE, "time");

struct csardlDiagOut diagOut;
diagOut = csardlDiagnostics(df, 1, 0, 0, "y ~ x1 + x2", 0);
