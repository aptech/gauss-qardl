proc (6) = qardl(data,ppp,qqq,tau);

/**************************************************************************************
This procedure file provides the following outputs:

1) long-run parameter and its covariance matrix;
2) short-run parameter (phi) and its covariance matrix;
3) short-run parameter (gamma) and its covariance matrix.

For these outputs, the following inputs are required:

1) data: (n *(1+k)) matrix, where the 1st column is the dependent variable, 
         and the last k columns are explanatory variables;
2) ppp: p value of QARDL(p,q) model;
3) qqq: q value of QARDL(p,q) model;
4) tau: (s * 1) vector of quantiles, which is sorted from the smallest to the largest.

October 10, 2013
Jin Seo Cho
***************************************************************************************/

    local za, nn, yy, xx, mm, ee, Y, X, ONEX, up, um, bigbt, psu, midbt,
    tw, bb, qq, eei, xxi, yyi, ii, yyj, xxj, wwj, kk, kkk, tilw, lll, 
    bbt, cc, bigpi, bigphi, midphi, jj, bigam, bilam, k0, ss, hb, hs, 
    bt, fh, uu, midgam, bt1, bigff, bigbtmm, barw;

    nn = rows(data);
    k0 = cols(data)-1;
    ss = rows(tau);
    tau = sortc(tau,1);

    za = cdfni(0.975);
    hb = zeros(ss,1);
    hs = zeros(ss,1);
    jj = 1;
    do until jj > ss;
        hb[jj,1] = (4.5*pdfn(cdfni(tau[jj,1]))^4/(nn*(2*cdfni(tau[jj,1])^2+1)^2))^0.2;
        hs[jj,1] = za^(2/3)*(1.5*pdfn(cdfni(tau[jj,1]))^2/(nn*(2*cdfni(tau[jj,1])^2+1)))^(1/3);
        jj = jj + 1;
    endo;

    yy = data[.,1];
    xx = data[.,2:cols(data)];
    ee = xx[2:nn,.] - xx[1:(nn-1),.];
    ee = zeros(1,k0)|ee;

    eei = zeros(nn-qqq,qqq*k0);
    xxi = xx[qqq+1:nn,.];
    yyi = zeros(nn-ppp,ppp);

    jj = 1;
    do until jj > k0;
        ii = 0;
        do until ii > qqq-1;
            eei[., ii+1+(jj-1)*qqq] = ee[(qqq+1-ii):(nn-ii),jj];
            ii = ii + 1;
        endo;
        jj = jj+1;
    endo;

    ii = 1;
    do until ii > ppp;
        yyi[.,ii] = yy[(1+ppp-ii):(nn-ii),1];
        ii = ii + 1;
    endo;

    if ppp .> qqq;
        X  = eei[(rows(eei)+1-rows(yyi)):rows(eei),.]~ xxi[(rows(xxi)+1-rows(yyi)):rows(xxi),.]~yyi;
    else;
        X  = eei~xxi~yyi[(rows(yyi)+1-rows(xxi)):rows(yyi),.];
    endif;

    /* parameter estimation */
    ONEX = ones(rows(X),1)~X;
    Y  = yy[(nn-rows(X)+1):nn,1];
    
    bt = zeros(cols(ONEX),ss);
    fh = zeros(ss,1);
    jj = 1;
    do until jj > ss;
        {bt1,up,um} = Qreg(Y,ONEX,tau[jj,1],0);
        uu = Y - ONEX*bt1;
        fh[jj,1] = meanc(pdfn(-uu/hb[jj,1]))/hb[jj,1];
        bt[.,jj] = bt1;
        jj = jj +1;
    endo;    

    /* testing long-run parameter: beta */

    barw = zeros(nn-1,qqq*k0);
    jj = 1;
    do until jj > qqq;
        barw[jj:(nn-1),(k0*(jj-1)+1):(k0*jj)] = ee[2:(nn-jj+1),.];
        jj = jj + 1;
    endo;

//    tw = ones(nn-1,1)~ee[2:nn,.];
    tw = ones(nn-1,1)~barw;
    mm = (xx[(qqq+1):nn,.]'*xx[(qqq+1):nn,.] - xx[(qqq+1):nn,.]'*tw[qqq:(nn-1),.]*inv(tw[qqq:(nn-1),.]'*tw[qqq:(nn-1),.])*tw[qqq:(nn-1),.]'*xx[(qqq+1):nn,.])/(nn-qqq)^2;

    bb = zeros(ss,1);

    jj = 1;
    do until jj > ss;
        bb[jj,1] = 1/((1-sumc(bt[2+(qqq+1)*k0:1+(qqq+1)*k0+ppp,jj]))*fh[jj,1]);
        jj = jj + 1;
    endo;

    qq = zeros(ss,ss);
    jj = 1;
    do until jj > ss;
        ii = 1;
        do until ii > ss;
            psu = zeros(2,1);
            psu[1,1] = tau[jj,1];
            psu[2,1] = tau[ii,1];
            qq[jj,ii] = (minc(psu) - tau[jj,1]*tau[ii,1])*bb[jj,1]*bb[ii,1];
            ii = ii + 1;
        endo;
        jj = jj + 1;
    endo;

    midbt = zeros(k0,ss);
    jj = 1;
    do until jj > ss;
          midbt[.,jj] = bt[2+qqq*k0:1+(qqq+1)*k0,jj]/(1-sumc(bt[2+(qqq+1)*k0:1+(qqq+1)*k0+ppp,jj]));
        jj = jj + 1;
    endo;
    bigbt = vec(midbt);
    bigbtmm = (qq.*. inv(mm));

    /* testing short-run parameters: phi */

    if ppp .> qqq; 
        yyj = zeros(nn-ppp,ppp);
        xxj = zeros(nn-ppp,k0);
        wwj = zeros(nn-ppp,qqq*k0);
        jj = 1;
        do until jj > ppp;
            yyj[.,jj] = yy[(ppp+1-jj):(nn-jj),1];
            jj = jj + 1;
        endo;
        ii = 1;
        do until ii > k0;
            jj = 1;
            do until jj > qqq;
                wwj[.,jj+(ii-1)*qqq] = ee[(ppp-jj+2):(nn-jj+1),ii];
                jj = jj + 1;
            endo;
            ii = ii + 1;
        endo;
        xxj = xx[(ppp+1):nn,.];
        kk = zeros(nn-ppp,ss*ppp);
        jj = 1;
        do until jj > ppp;
            Y = yyj[.,jj];
            ONEX = ones(nn-ppp,1)~xxj~wwj;
            ii = 1;
            do until ii > ss;
                {bbt,up,um} = Qreg(Y,ONEX,tau[ii,1],0);
                kkk = Y - ONEX*bbt;
                kk[.,jj+(ii-1)*ppp] = kkk;
                ii = ii + 1;
            endo;
            jj = jj + 1;
        endo;
        tilw = tw[ppp:(nn-1),.];
        lll = (kk'*kk - kk'*tilw*inv(tilw'*tilw)*tilw'*kk)/(nn-ppp);
    else;
        yyj = zeros(nn-qqq,ppp);
        xxj = zeros(nn-qqq,k0);
        wwj = zeros(nn-qqq,qqq*k0);
        jj = 1;
        do until jj > ppp;
            yyj[.,jj] = yy[(qqq+1-jj):(nn-jj),1];
            jj = jj + 1;
        endo;
        ii = 1;
        do until ii > k0;
            jj = 1;
            do until jj > qqq;
                wwj[.,jj+(ii-1)*qqq] = ee[(qqq-jj+2):(nn-jj+1),ii];
                jj = jj + 1;
            endo;
            ii = ii + 1;
        endo;
        xxj = xx[(qqq+1):nn,.];
        kk = zeros(nn-qqq,ss*ppp);
        jj = 1;
        do until jj > ppp;
            Y = yyj[.,jj];
            ONEX = ones(nn-qqq,1)~xxj~wwj;
            ii = 1;
            do until ii > ss;
                {bbt,up,um} = Qreg(Y,ONEX,tau[ii,1],0);
                kkk = Y - ONEX*bbt;
                kk[.,jj+(ii-1)*ppp] = kkk;
                ii = ii + 1;
            endo;
            jj = jj + 1;
        endo;
        tilw = tw[qqq:(nn-1),.];
        lll = (kk'*kk - kk'*tilw*inv(tilw'*tilw)*tilw'*kk)/(nn-qqq);
    endif;

    cc = zeros(ss,ss);
    jj = 1;
    do until jj > ss;
        ii = 1;
        do until ii > ss;
            psu = zeros(2,1);
            psu[1,1] = tau[jj,1];
            psu[2,1] = tau[ii,1];
            cc[jj,ii] = (minc(psu) - tau[jj,1]*tau[ii,1])/(fh[ii,1]*fh[jj,1]);
            ii = ii + 1;
        endo;
        jj = jj + 1;
    endo;

    bigpi = zeros(ss*ppp,ss*ppp);
    jj = 1;
    do until jj > ss;
        ii = 1;
        do until ii > ss;
            psu = inv(lll[(jj-1)*ppp+1:jj*ppp,(jj-1)*ppp+1:jj*ppp])*lll[(jj-1)*ppp+1:jj*ppp,(ii-1)*ppp+1:ii*ppp]*inv(lll[(ii-1)*ppp+1:ii*ppp,(ii-1)*ppp+1:ii*ppp]); 
            bigpi[(jj-1)*ppp+1:jj*ppp,(ii-1)*ppp+1:ii*ppp] = cc[jj,ii]*psu; 
            ii = ii + 1;
        endo;
        jj = jj + 1;
    endo;

    midphi = zeros(ppp,ss);
    jj = 1;
    do until jj > ss;
        midphi[.,jj] = bt[2+(qqq+1)*k0:1+(qqq+1)*k0+ppp,jj];
        jj = jj + 1;
    endo;
    bigphi = vec(midphi);

    /* testing short-run parameters: gamma */

    midgam = zeros(k0,ss);
    jj = 1;
    do until jj > ss;
          midgam[.,jj] = bt[2+qqq*k0:1+(qqq+1)*k0,jj];
        jj = jj + 1;
    endo;
    bigam = vec(midgam);
    bilam = zeros(k0*ss,ss*ppp);

    jj = 1;
    do until jj > ss;
        bilam[((jj-1)*k0+1):(jj*k0),(jj-1)*ppp+1:(jj*ppp)] = midbt[.,jj]*ones(1,ppp);
        jj = jj + 1;
    endo;

    bigff = bilam*bigpi*bilam';
    retp(bigbt, bigbtmm, bigphi, bigpi, bigam, bigff);
endp;