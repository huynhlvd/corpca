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
%% Initialization 
% A  - m x n measurement matrix 
n = 1000;
m = 370;
A = randn(m,n);
% Supports of ||x - zj||_0 = sj
s0 = 128;
s1 = 256; 
s2 = 256;
s3 = 256;
S = [s1 s2 s2]; 
J = size(S,2);
[M, batchTrain, L, S] = dataCORPCA (n, seqLength, trainLength, d, s0, sj, commRatio);
%% Generating x
ranDat = [randn(s0,1); zeros(n - s0,1)];
perm = randperm(n);
x = ranDat(perm);
%% Generating zj = Z(:,j)
Z = zeros(n,J);
for j = 1:J
    ran = [randn(S(j),1); zeros(n - S(j),1)];
    ran = ran(perm);
    Z(:,j) = x + ran; % Positions of non-zeros of x and zj are coincided 
end

%% Running one CORPCA demo
% Input: observation b with m measurements, projection matrix A, side information Z
% Output: recovered source x_hat

b = A*x;
x_hat = corpca(A, b, Z);
fprintf('Recovered error: %4.8f \n', norm(x_hat - x,2)/(norm(x,2)));


