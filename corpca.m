%% This function has written based on Programs from Matlab 
%     Copyright (c) 2017, Huynh Van Luong, version 01, Jan. 24, 2017
%     Multimedia Communications and Signal Processing, University of Erlangen-Nuremberg.
%     All rights reserved.
% 
%     Contributors: Huynh Van Luong, N. Deligiannis, J. Seiler, A. Kaup, and S. Forchhammer.
% 
%     Redistribution and use in source and binary forms, with or without 
%     modification, are permitted provided that the following conditions are
%     met:
% 
%         1. Redistributions of source code must retain the above copyright
%         notice, this list of conditions and the following disclaimer.
% 
%         2. Redistributions in binary form must reproduce the above copyright
%         notice, this list of conditions and the following disclaimer in the
%         documentation and/or other materials provided with the distribution.
% 
%         3. Redistributions in the hope that it will be useful, but WITHOUT ANY 
%         WARRANTY; without even the implied WARRANTY OF MERCHANTABILITY OR 
%         FITNESS FOR A PARTICULAR PURPOSE.
% 
% Please cite this publication
% 
%     PUBLICATION: Huynh Van Luong, N. Deligiannis, J. Seiler, S. Forchhammer, and A. Kaup, 
%             "Incorporating Prior Information in Compressive Online Robust Principal Component Analysis," 
%              in e-print, arXiv, Jan. 2017.

function [xt, vt, Zt, Bt] = corpca(yt, Phi, Ztm1, Btm1, varargin)
%
% Solving the problem
%   min{H(xt,vt|Ztm1,Btm1) = 1/2 ||Phi*(xt + vt) - yt||_2^2 + lambda*mu*sum(betaj*||Wj(xt-zj)||_1) + mu*||[Btm1 vt]||_*}
% 
% Inputs:
%   yt - m x 1 vector of observations/data (required input)
%   Phi - m x n measurement matrix (required input)
%   Ztm1 - n x J the foreground prior: initialized by J previous foregrounds 
%   Btm1 - n x d the background prior: could be initialized by d previous backgrounds
% 
% 
% Outputs:
%   xt, vt - n x 1 estimates of foreground and background
%   Zt - n x J the updated foreground prior
%   Bt - n x d the updated background prior
%
%----------- Parameters-------------------------------------------------------
% tol - tolerance for stopping criterion.
%     - DEFAULT 1e-7 if omitted or -1.
% maxIter - maxilambdam number of iterations
%         - DEFAULT 10000, if omitted or -1.
% lineSearchFlag - 1 if line search is to be done every iteration
%                - DEFAULT 0, if omitted or -1.
% continuationFlag - 1 if a continuation is to be done on the parameter lambda
%                  - DEFAULT 1, if omitted or -1.
% eta - line search parameter, should be in (0,1)
%     - ignored if lineSearchFlag is 0.
%     - DEFAULT 0.9, if omitted or -1.
% lambda - relaxation parameter
%    - ignored if continuationFlag is 1.
%    - DEFAULT 1e-3, if omitted or -1.
% mu - relaxation parameter
%    - ignored if continuationFlag is 1.
%    - DEFAULT 1e-3, if omitted or -1.
% numIter - number of iterations until convergence
%---------------------------------------------------------------------------
%% Input:
    [m,n] = size(Phi);
    lambda = 1/sqrt(n);

    if (m==n)
        c = yt;
    else
        G = pinv(Phi);%   G - n x m pseudo-inverse matrix of Phi
        c = G*yt;
        G = G*Phi;
    end

    if nargin < 4
        error('Too few arguments');
    end

    if nargin < 5
        maxIter = 1000;
    elseif maxIter == -1
        maxIter = 1000;
    end

    if nargin < 6
        tol = 1e-10;
    elseif tol == -1
        tol = 1e-10;
    end

    if nargin < 7
        lineSearchFlag = 0;
    elseif lineSearchFlag == -1
        lineSearchFlag = 0;
    end

    if nargin < 8
        continuationFlag = 1;
    elseif continuationFlag == -1;
        continuationFlag = 1;
    end

    if lineSearchFlag
        if nargin < 9
            eta = 0.9;
        elseif eta == -1
            eta = 0.9;
        end

        if ( nargin > 8 && ( eta <= 0 || eta >= 1 ) )
            disp('Line search parameter out of bounds, switching to default 0.9') ;
            eta = 0.9;
        end
    end

    if ~continuationFlag
        if nargin < 11
            mu = 1e-3;
        elseif mu == -1
            mu = 1e-3;
        end
    end

    if nargin > 10
        fid = fopen(outputFileName,'w');
    end

    DISPLAY_EVERY = 50;
    DISPLAY = 0;

    maxLineSearchIter = 200; % maximum number of iterations in line search per outer iteration

    %% Initializing optimization variables

    [m, n] = size(Phi);
    sai_k = 1; % t^k
    sai_km1 = 1; % t^{k-1}
    tau_0 = 2; % square of Lipschitz constant for the RPCA problem

    vt_km1 = mean(Btm1,2); %zeros(n,1);
    vt_k = mean(Btm1,2);

    xt_km1 = zeros(n,1); % X^{k-1} = (A^{k-1},E^{k-1})     
    xt_k = zeros(n,1); % X^{k} = (A^{k},E^{k})

    % Input SIs
    J = size(Ztm1,2) + 1;
    % z0 = zeros(n,1); % Adding z0 as SI of conventional norm-1 term
    Z = zeros(n,J);
    Z(:,2:J) = Ztm1;
    Wk = zeros(n,J); % Weights on source
    beta = zeros(J,1);
    beta(1) = 1;
    Wk(:,1) = 1; 


    %
    if continuationFlag
        if lineSearchFlag
            mu_0 = eta * norm(c);
        else
            mu_0 = norm(c);
        end    
        mu_k = 0.99*mu_0;    
        mu_bar = 1e-9 * mu_0; %1e-9 * mu_0;
    else
        mu_k = mu;    
    end

    tau_k = tau_0;

    converged = 0;
    numIter = 0;
    epsi = 0.1; %0.8
    epsiBeta = 1e-20;
    bigN = n;
    Wkp1 = Wk;
    %% Start main loop

    [U0, S0, V0] = svd(Btm1,'econ');
    % c = G*vt_k ;
    while ~converged

        tvt_k = vt_k + ((sai_km1 - 1)/sai_k) * (vt_k - vt_km1);
        txt_k = xt_k + ((sai_km1 - 1)/sai_k) * (xt_k - xt_km1);

        if ~lineSearchFlag      
            thvt_k = tvt_k - (1/tau_k) * (G*(tvt_k + txt_k) - c);
            thxt_k = txt_k - (1/tau_k) * (G*(tvt_k + txt_k) - c);
    %         tic
            [U1,S1,V1] = incSVD(thvt_k, U0, S0, V0);
            diagS = diag(S1);
            proxS = diag(pos(diagS - mu_k/tau_k));

            Tht = U1 * proxS * V1';
            vt_kp1 = Tht(:,end);
    %         part1 = toc
    %         tic
            xt_kp1 = softMSI(thxt_k, mu_k*lambda, tau_k, Wk, Z);
    %         part2 = toc
    %         tic
            %% Updating weights of RAMSIA
            for j = 1:J   
                denom = (epsi+abs(xt_kp1-Z(:,j)));
                Wkp1(:,j) = 1./(denom);
                Wkp1(:,j) = Wkp1(:,j)*(bigN/sum(Wkp1(:,j)));
            end        
            for j = 1:J   
                denom = 0;     
                for i = 1:J
                    denom = denom + (epsiBeta + norm(Wkp1(:,j).*(xt_kp1 - Z(:,j)),1))/(epsiBeta + norm(Wkp1(:,i).*(xt_kp1 - Z(:,i)),1));
                end
                beta(j) = 1/(denom);
            end 

            for j = 1:J  
                Wkp1(:,j) = beta(j)*Wkp1(:,j);
            end   
    %         part3 = toc
            rankL  = sum(diagS>mu_k/tau_k);
            cardX = sum(sum(double(abs(xt_kp1)>0)));

        else

            convergedLineSearch = 0 ;
            numLineSearchIter = 0 ;

            tau_hat = eta * tau_k ;

            while ~convergedLineSearch

                gradf = (1/tau_hat)*(G*(tvt_k + txt_k) - c) ;
                thvt = tvt_k - gradf;            
                thxt = txt_k - gradf;

                [U1,S1,V1] = incSVD(thvt, U0, S0, V0);

                diagS = diag(S1) ;
                proxS = diag(pos(diagS - mu_k/tau_hat));

                STht = U1 * proxS * V1';
                Sthvt = STht(:,end);

                Sthxt = softMSI(thxt, mu_k*lambda, tau_hat, Wk, Z);
                F_SG = 0.5*norm(c - G*(Sthvt + Sthxt),'fro')^2 ;
                Q_SG_Y = 0.5*tau_hat*norm([G*Sthvt, G*Sthxt]-[G*thvt,G*thxt],'fro')^2 + ...
                    (0.5-1/tau_hat)*norm(c - G*(tvt_k + txt_k),'fro')^2    ;

                if F_SG <= Q_SG_Y
                    tau_k = tau_hat ;
                    convergedLineSearch = 1 ;
                else
                    tau_hat = min(tau_hat/eta,tau_0) ;
                end

                numLineSearchIter = numLineSearchIter + 1 ;

                if ~convergedLineSearch && numLineSearchIter >= maxLineSearchIter
                    disp('Stuck in line search') ;
                    convergedLineSearch = 1 ;
                end

            end

            vt_kp1 = Sthvt ;
            xt_kp1 = Sthxt ;

            rankL  = sum(diagS>mu_k/tau_hat);
            cardX = sum(sum(double(abs(xt_kp1)>0)));

        end


        sai_kp1 = 0.5*(1+sqrt(1+4*sai_k*sai_k)) ;

        temp = vt_kp1 + xt_kp1 - tvt_k - txt_k;
        S_kp1_vt = tau_k*(tvt_k - vt_kp1) + temp ;
        S_kp1_xt = tau_k*(txt_k - xt_kp1) + temp;


        stoppingCriterion = norm([S_kp1_vt,S_kp1_xt],'fro')/(tau_k*max(1,norm([vt_kp1,xt_kp1],'fro'))) ;

        if stoppingCriterion <= 5*tol
            converged = 1 ;
        end

        if continuationFlag
            mu_k = max(0.9*mu_k,mu_bar) ;        
        end

        sai_km1 = sai_k ;
        sai_k = sai_kp1 ;

        vt_km1 = vt_k ; 

        xt_km1 = xt_k ;


        vt_k = vt_kp1 ; 

        xt_k = xt_kp1 ;
        Wk = Wkp1;

        numIter = numIter + 1; 

        if DISPLAY && mod(numIter,DISPLAY_EVERY) == 0
            disp(['Iteration ' num2str(numIter) '  rank(L) ' num2str(rankL) ...
                ' ||S||_0 ' num2str(cardX)]) ;         
        end

        if nargin > 8
            fprintf(fid, '%s\n', ['Iteration ' num2str(numIter) '  rank(L)  ' num2str(rankL) ...
                '  ||S||_0  ' num2str(cardX) '  Stopping Criterion   ' ...
                num2str(stoppingCriterion)]) ;
        end


        if ~converged && numIter >= maxIter
            disp('Maximum iterations reached') ;
            converged = 1 ;
        end

    end

    vt = vt_kp1;
    xt = xt_kp1;
    %% Updating prior information for the next instance
    Zt = Ztm1;
    Zt(:,1:J-2) = Ztm1(:,2:J-1);
    Zt(:,J-1) = xt;
    Bt = U1(:,1:size(Btm1,2))*proxS(1:size(Btm1,2),1:size(Btm1,2))*V1(1:size(Btm1,2),1:size(Btm1,2))';
end
%% Supported functions from here
function[U1, S1, V1] = incSVD(v, U0, S0, V0)  
    [~, Ncols] = size(U0);

    r = U0'*v;
    z = v - U0*r;
    rho = sqrt( sum( z.*z ) );

    if( rho > 1e-8 ) 
      p = z/rho;
    else
      p = zeros(size(z));
    end


    St = [S0 r; zeros(1,Ncols) rho ];

    [Gu, S1, Gv] = svd(St,'econ');    
    U1  = [ U0 p ]*Gu;
    V1  = [ V0 zeros(max(size(V0)),1);  zeros(1,Ncols) 1 ]*Gv;
end
function P = pos(A)
    P = A .* double( A > 0 );
end
function y = softMSI(x,lambda,L,Wk,Z)
    A0 = -1e+20 + zeros(size(x,1),1);
    A0 = [A0,Z,A0 + 2e+20];
    [A,I] = sort(A0,2);
    W0 = [zeros(size(x,1),1),Wk,zeros(size(x,1),1)];
    W = W0;
    for i = 1:size(x,1)
        w = W0(i,:);
        W(i,:) = w(I(i,:));
    end
    y = proxMat(x, A, W, lambda, L);
end
  
function [u] = proxMat(x, A, W, lambda, L)
    J = size(A,2) - 3;
    S = zeros(size(x,1),size(A,2)-1);
    P = zeros(size(x,1),2*size(A,2)-2);
    
    for m = 1:size(A,2)-1
       for j = 2:J+2
           S(:,m) = S(:,m) + W(:,j)*((-1)^(m-2<j-2));       
       end
       S(:,m) = S(:,m)*(lambda/L);
       P(:,2*m-1) = A(:,m) + S(:,m);
       P(:,2*m) = A(:,m+1) + S(:,m);
    end
    XX = 0*P;
    
    for j = 1:2*(size(A,2)-1)
        XX(:,j) = XX(:,j) + x;
    end
    NN = sign(P - XX);
    SNN = NN; %zeros(size(x,1),2*(size(A,2)-1)-1);
    UM = SNN;
 
    for j = 2:2*(size(A,2)-1)
        SNN(:,j) = NN(:,j-1) + NN(:,j);
    end    
    II = (SNN >= 0) .* (SNN <= 1);
    
    for j = 1:2*(size(A,2)-1)
        if (mod(j,2) == 0)
            UM(:,j) = x - S(:,(j/2));
        else
            UM(:,j) = A(:,floor(j/2)+1);
        end
    end      
    UM = II .* UM;
    u = sum(UM,2);
end