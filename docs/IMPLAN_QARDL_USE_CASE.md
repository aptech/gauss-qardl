# IMPLAN QARDL Use-Case Outline

## Working Title

Asymmetric Regional Adjustment to Industry Demand Shocks: A QARDL Analysis with
IMPLAN Industry Data

## Core Question

Do employment, labor income, or value-added responses to industry output changes
differ across the lower, middle, and upper parts of a regional outcome
distribution?

QARDL is attractive here because an input-output system implies persistent
long-run linkages among output, employment, labor income, and value added, while
regional adjustment may be asymmetric during weak versus strong local economic
conditions.

## Recommended Empirical Design

Use IMPLAN industry-year data to construct region-industry panels, then present
QARDL as a repeated time-series workflow over carefully selected region/industry
series. Because a single annual IMPLAN series generally begins in 2001 and may
have only about two dozen observations, avoid overselling one-region annual
QARDL as a high-power standalone estimate.

Best options:

- Blog/demo version: choose one state and one industry group with strong
  regional relevance, then frame results as a transparent workflow example.
- Paper version: estimate comparable QARDL models across many regions or
  industries, summarize the distribution of quantile-specific long-run
  responses, and use bootstrap/robustness checks.
- Strongest version: combine IMPLAN annual structural variables with longer
  public time series where appropriate, such as BEA regional GDP, QCEW
  employment/wages, or industry production indicators.

## Candidate Outcomes And Regressors

Possible dependent variables:

- `log_employment`: total employment or wage-and-salary employment.
- `log_labor_income`: labor income.
- `log_value_added`: total value added.
- `log_output_per_worker`: productivity-oriented outcome.

Possible regressors:

- `log_output`: industry output.
- `log_intermediate_inputs`: intermediate inputs.
- `va_share_output`: value added as a share of output.
- `labor_income_share_output`: labor income divided by output.
- `shock_or_policy`: event indicator or measured demand shock if the blog/paper
  studies a specific intervention.

## Minimum CSV Schema

For a single-series blog example:

```text
year,region,industry,employment,labor_income,value_added,output,intermediate_inputs
2001,State Name,Industry Name,...
```

Create a GAUSS analysis dataset with numeric columns ordered as:

```text
log_employment,log_output,log_intermediate_inputs,va_share_output
```

For a paper-style multi-region workflow, keep the long panel CSV and loop over
`region`/`industry` groups after filtering for complete years.

## Suggested GAUSS Workflow

```gauss
new;
library qardl;

implan = loadd("implan_industry_panel.csv",
               "year + region + industry + log_employment + log_output"
               $+ " + log_intermediate_inputs + va_share_output");

/*
** For a blog example, filter to one complete region/industry series before
** calling qardlFull. Replace this placeholder with the selected rows.
*/
data = implan[., "log_employment" "log_output" "log_intermediate_inputs"];
tau = { 0.10, 0.25, 0.50, 0.75, 0.90 };

qf = qardlFull(data, 2, 2, tau, "", 0, "bic", "hac", 0);
printQARDL(qf.qa, tau);
printQARDLECM(qf.ecm, tau);

{ wt_beta, pv_beta, wt_gamma, pv_gamma, wt_phi, pv_phi } =
    wtestconst(qf.qa, tau, data);
```

## Storyline For A Blog Or Applied Paper

1. Motivate asymmetric adjustment: a region may shed jobs quickly in downturns
   but add jobs slowly in expansions, or labor income may respond differently
   when the local industry is already under stress.
2. Explain IMPLAN measures: output is production value, labor income captures
   worker/proprietor income, and value added is the contribution to GDP-like
   regional production.
3. Estimate ARDL bounds tests first to document level relationships.
4. Estimate QARDL across quantiles and compare long-run output elasticities.
5. Use constancy and symmetry Wald tests to ask whether lower-tail and
   upper-tail responses are statistically different.
6. Use QIRFs to visualize dynamic adjustment after an output shock.
7. Discuss limitations: annual sample length, proprietary data constraints,
   aggregation choices, and input-output accounting assumptions.

## Publication-Quality Robustness Checks

- Vary lag grids and information criteria (`bic`, `aic`, `hq`, `hqc`).
- Compare iid, robust, and HAC covariance paths.
- Re-estimate using `qardlECM` and compare speed-of-adjustment patterns.
- Re-run at alternative industry aggregation levels.
- Drop crisis years or add crisis indicators where theoretically justified.
- Use block bootstrap intervals for selected estimates.

## Sources

- IMPLAN explains its modeling system as input-output analysis based on
  buy-sell relationships and annual regional data:
  https://support.implan.com/hc/en-us/articles/360038285254-How-IMPLAN-Works
- IMPLAN Data Library industry data include annual industry measures such as
  output, employment, labor income, intermediate inputs, value added, and output
  per worker:
  https://support.implan.com/hc/en-us/articles/360061668473-Industry-Data-in-Data-Library
- IMPLAN describes annual datasets as balanced Social Accounting Matrices for
  U.S. zip-code, county, and state geographies:
  https://support.implan.com/hc/en-us/articles/115009674688-Introduction-to-IMPLAN-Data-and-Data-Sources
