function model = InvGP_train(F, X, gen)
%InvGP_train Train independent inverse Gaussian-process regression models.
%   MODEL = InvGP_train(F,X,GEN) learns the inverse mapping F -> X from
%   true objective values F (N-by-M) and their corresponding true decision
%   vectors X (N-by-D).  One scalar-output GP is fitted for every decision
%   variable.  MODEL is consumed by InvGP_predict.
%
%   This implementation deliberately does not repair decision bounds.  The
%   caller owns the problem bounds and must repair the predictions, as done
%   by RBF_four after its call to InvGP_predict.
%
%   Requirements: Statistics and Machine Learning Toolbox (fitrgp).

    narginchk(2, 3);
    if nargin < 3 || isempty(gen)
        gen = 0;
    end

    validateattributes(F, {'numeric'}, ...
        {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'F', 1);
    validateattributes(X, {'numeric'}, ...
        {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'X', 2);
    validateattributes(gen, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnegative'}, mfilename, 'gen', 3);

    if size(F, 1) ~= size(X, 1)
        error('InvGP_train:RowCountMismatch', ...
            'F and X must contain the same number of observations.');
    end
    if size(F, 1) < 2
        error('InvGP_train:TooFewObservations', ...
            'At least two F/X observations are required to train an inverse GP.');
    end
    if exist('fitrgp', 'file') ~= 2
        error('InvGP_train:MissingFitrgp', ...
            ['fitrgp was not found. InvGP_train requires the Statistics ' ...
             'and Machine Learning Toolbox.']);
    end

    % Work in double precision even if the population was stored as single.
    F = double(F);
    X = double(X);
    [nTrain, nObjective] = size(F);
    nDecision = size(X, 2);

    % Explicit scaling makes the transformation available during prediction
    % and avoids relying on fitrgp's private standardization state.  A
    % constant column receives scale one and is therefore mapped to zero.
    [fMean, fScale, fConstant] = local_scaling(F);
    [xMean, xScale] = local_scaling(X);
    Fscaled = (F - fMean) ./ fScale;
    Xscaled = (X - xMean) ./ xScale;
    activeObjective = ~fConstant;
    Ffit = Fscaled(:, activeObjective);

    gp = cell(1, nDecision);
    trainPredScaled = zeros(nTrain, nDecision);

    for d = 1:nDecision
        response = Xscaled(:, d);

        % A constant decision coordinate needs no optimizer and can make the
        % GP likelihood ill-conditioned.  Store it explicitly instead.
        responseTol = 100 * eps(max(1, max(abs(response))));
        if max(response) - min(response) <= responseTol || isempty(Ffit)
            gp{d} = struct('isConstant', true, 'value', mean(response));
            trainPredScaled(:, d) = gp{d}.value;
            continue;
        end

        % ARD length scales allow objectives with different local relevance.
        % A small, nonzero noise floor improves conditioning for duplicate or
        % nearly duplicate objective vectors.
        gp{d} = fitrgp(Ffit, response, ...
            'BasisFunction', 'constant', ...
            'KernelFunction', 'ardsquaredexponential', ...
            'Standardize', false, ...
            'FitMethod', 'exact', ...
            'PredictMethod', 'exact', ...
            'Sigma', 1e-3, ...
            'SigmaLowerBound', 1e-6);
        trainPredScaled(:, d) = predict(gp{d}, Ffit);
    end

    trainPrediction = trainPredScaled .* xScale + xMean;
    residual = trainPrediction - X;

    model = struct();
    model.type = 'independent-inverse-gp';
    model.version = 1;
    model.gen = gen;
    model.nTrain = nTrain;
    model.nObjective = nObjective;
    model.nDecision = nDecision;
    model.fMean = fMean;
    model.fScale = fScale;
    model.activeObjective = activeObjective;
    model.xMean = xMean;
    model.xScale = xScale;
    model.gp = gp;
    model.rmse_train = sqrt(mean(residual.^2, 1))';
    model.mae_train = mean(abs(residual), 1)';
    model.bias_train = mean(residual, 1)';
end

function [center, scale, isConstant] = local_scaling(values)
%LOCAL_SCALING Return stable column-wise centering and scaling parameters.
    center = mean(values, 1);
    scale = std(values, 0, 1);
    tolerance = sqrt(eps) .* max(1, abs(center));
    isConstant = ~isfinite(scale) | scale <= tolerance;
    scale(isConstant) = 1;
end
