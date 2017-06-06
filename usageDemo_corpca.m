% Demo of using corpca.m for CORPCA
% This function has written based on Programs from Matlab 
%     Copyright (c) 2017, Huynh Van Luong, version 01, Jan. 24, 2017
%     Multimedia Communications and Signal Processing, University of Erlangen-Nuremberg.
%     All rights reserved.
%
%     PUBLICATION: Huynh Van Luong, N. Deligiannis, J. Seiler, S. Forchhammer, and A. Kaup, 
%             "Incorporating Prior Information in Compressive Online Robust Principal Component Analysis," 
%              in e-print, arXiv, Jan. 2017.
%
% 
%% Initialization 
s0(1) = 40; % sparse degree
s0(2) = s0(1) + 15; % sparse constraint of sparse components
nSI = 3; % Size of number of foreground prior information 
m = 250; % a number of measurements of reduced data  
sj = max(round(mean(s0)/2),1); % s_j = || x_t - x_t-1||_0
n = 500; % Dimension of data vectors
r = 5; % rank of low-rank components
q = 100; % the number of testing vectors
d = 100; % the number of training vectors

%% Generating numerical example data for CORPCA
%     trainData: Traning data
%     M= L + S: Testing data
%     L: Testing low-rank components
%     S: Testing sparse components
[M, trainData, L, S] = dataGeneration (n, q, d, r, s0, sj);
%% ***********************************************************************************
% Foreground-background separation by CORPCA
% ************************************************************************************
% Initializing background and foreground prior information via an offline rpca
addpath(genpath('inexact_alm_rpca'));
RPCA_lambda     = 1/sqrt(size(trainData,1));
[B0, Z0, ~] = inexact_alm_rpca(trainData, RPCA_lambda, -1, 20); 

%% Running one CORPCA demo
%--------------------------------------------------------------------------------------------------
%--- Input: observation yt with m measurements, projection matrix Phi, prior information Btm1, Ztm1
%--- Output: recovered foreground xt, background vt, the prior information updates, Bt, Zt
%--------------------------------------------------------------------------------------------------
  
rpMat = randn(m, n);
Phi = rpMat; % Input the measurement matrix     
Btm1 = B0; % Input background prior
Ztm1 = Z0(:, end - nSI + 1 : end); % Input foreground prior
for t = 1 : q;
%t = 1; % Testing fame i = 1  
    fprintf('Testing fame %d at a measurement rate %2.2f \n', t, m/n);

    yt = Phi*M (:,t); % Input observation    
    [xt, vt, Zt, Bt] = corpca(yt, Phi, Ztm1, Btm1); % Performing CORPCA for separation
    % update prior information
    Ztm1 = Zt;
    Btm1 = Bt;

    fprintf('Recovered foreground error: %4.8f \n', norm(xt - S(:,t),2)/(norm(S(:,t),2)));
    fprintf('Recovered background error: %4.8f \n\n', norm(vt - L(:,t),2)/(norm(L(:,t),2)));
end
