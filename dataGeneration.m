function [M, trainData, L, S] = dataGeneration (n, numFrame, numTrain, d, s0, sj)

    % M, L and S are n-dimensioanl vectors
    % Length of training sequence: numTrain.
    % Sequence lenght: numFrame
    %%
    % Generating low-rank part
    % U: (numTrain + numFrame) * d, i.i.d. N(0, 1)
    % V: n * d, i.i.d. N(0, 1)
    % L = U * V';
    
    % Generating low-rank component
    mu = 0;
    sigmaU = 1;%/n;
    sigmaV = 1;%/(numTrain + numFrame);

    U = mu + sigmaU * randn(n, d);
    V = mu + sigmaV * randn(numTrain + numFrame, d);
    L_all = U * V';    
    L = L_all(:, numTrain + 1 : end); 
    
    % Generating sparse components
    S_all = zeros(n, numTrain + numFrame); 
    [S_all(:,1), xPerm] = generateX(n,s0);
    for t = 2 : numTrain + numFrame
        [S_all(:,t), xPerm] = generateZ(s0, sj, 0, S_all(:,t-1), xPerm);  
    end
    S_all = S_all * 1; 
    S = S_all(:, numTrain + 1 : end); 
    
    % Generating data sets
    M_all = L_all + S_all;
    
    trainData = M_all(:, 1 : numTrain);% Traning data
    M = M_all(:, numTrain + 1 : end);   % Testing data

end
%% Supported funtions to generate sparse component
function [z, zPerm] = generateZ(s, sZ, commRatio, x, xPerm)
    % =========================================================================
    % Parameters of the experiment

    n = numel(x);              % Dimension of the vector
    s0 = sum(x ~= 0);

    % Side information parameters
    card_comm_factor = (sZ/s0)*commRatio;
    card_rest_factor = (sZ/s0)*(1-commRatio); 
    % =========================================================================
    % Generate data
    permutation_x = xPerm;
    card_i_common = round(card_comm_factor*s0); 
    card_i_rest   = round(card_rest_factor*s0); 

    i_aux = [randn(card_i_rest,1); zeros(n-card_i_rest,1)];

    permutation_rest = randperm(n);
    i = i_aux(permutation_rest);

    iPerm = zeros(1, card_i_rest);

    for j = 1:card_i_rest
        iPerm (j) = find(permutation_rest==j);
    end;

    vec_aux = [(randn(card_i_common,1)); zeros(n-card_i_common,1)]; 

    vec_perm = zeros(n,1);
    vec_perm(permutation_x(1:card_i_common)) = vec_aux((1:card_i_common));


    i = i + vec_perm;
    z = x + i;
    card_z = sum(z~=0);
    zPerm = xPerm;

    for k = 1:size(iPerm,2)
        fRest = xPerm(xPerm == iPerm(k));
        if isempty(fRest);
            zPerm = [zPerm iPerm(k)];
        end
    end
    %% Regenerate z if card_z > s(2)

    if card_z > s(2)    
       iDel = randperm(size(zPerm,2));
       z(zPerm(iDel(1:card_z - s(1)))) = 0;
       zPerm(iDel(1:card_z - s(1))) = [];
    end
end
function [x,xPerm] = generateX(n, s)


    card_x = s(1); 

    % =========================================================================
    % Generate data

    % Generate x
    x_aux = [(randn(card_x,1)); zeros(n-card_x,1)];


    permutation_x = randperm(n);

    x = x_aux(permutation_x);
    xPerm = zeros(1, s(1));

    for j = 1:s(1)
        xPerm (j) = find(permutation_x==j);
    end;
end
