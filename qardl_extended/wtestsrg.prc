/************************************************************
This procedure file provides the following outputs:

1) wald test for testing short-run parameter (gamma);
2) p-value of the wald test computed in 1).

The hypotheses tested by the wald test is as follows:

H0: R * b = r   vs.  H0: R * b \neq r

For these outputs, the following inputs are required:

1) beta (b): the estimated short-run parameter by qardl.prc;
2) cov: estimated covariance matrix of beta; 
3) bigR: R matrix in the null hypothesis;
4) smlr: r matrix in the null hypothesis;
5) data: the same data set used for qardl.prc. 

October 10, 2013
Jin Seo Cho
************************************************************/

proc (2) = wtestsrg(beta,cov,bigR,smr,data);
    local nn, wt, rnk, pv;
    nn = rows(data);
    wt = (nn-1)*(bigR*beta-smr)'*inv(bigR*cov*bigR')*(bigR*beta-smr);
    rnk= rows(bigR);
    pv = cdfchic(wt,rnk);
    retp(wt, pv);
endp;