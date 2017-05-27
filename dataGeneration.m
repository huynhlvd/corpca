function [M, trainData, L, S] = dataGeneration (n, numFrame, numTrain, d, s0, sj)

    % M, L and S are n-dimensioanl vectors
    % Length of training sequence: numTrain.
    % Sequence lenght: numFrame
    %%
    % Generating low-rank part
    % U: (numTrain + numFrame) * d, i.i.d. N(0, 1)
    % V: n * d, i.i.d. N(0, 1)
    % L = U * V';
    
    % Generating low-rank components

    % Generating sparse components

end
%% Supported funtions to generate sparse components
