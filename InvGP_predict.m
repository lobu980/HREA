function [Xpred, Xstd] = InvGP_predict(Fquery, model)
%InvGP_predict Predict decision vectors with a trained inverse GP model.
%   XPRED = InvGP_predict(FQUERY,MODEL) maps NQ-by-M objective vectors to
%   NQ-by-D decision vectors using the model returned by InvGP_train.
%
%   [XPRED,XSTD] additionally returns the marginal predictive standard
%   deviation for each decision coordinate.  Correlations between decision
%   coordinates are not represented because InvGP_train fits independent
%   scalar-output GPs.
%
%   Predictions are not clipped to decision bounds; bound repair belongs to
%   the caller because MODEL does not contain the optimization problem.

    narginchk(2, 2);
    validateattributes(Fquery, {'numeric'}, ...
        {'2d', 'real', 'finite'}, mfilename, 'Fquery', 1);
    if ~isstruct(model)
        error('InvGP_predict:InvalidModel', ...
            'MODEL must be a structure returned by InvGP_train.');
    end

    required = {'type', 'nObjective', 'nDecision', 'fMean', 'fScale', ...
                'activeObjective', 'xMean', 'xScale', 'gp'};
    missing = required(~isfield(model, required));
    if ~isempty(missing)
        error('InvGP_predict:InvalidModel', ...
            'MODEL is missing required field "%s".', missing{1});
    end
    if ~strcmp(model.type, 'independent-inverse-gp')
        error('InvGP_predict:UnsupportedModel', ...
            'Unsupported inverse model type "%s".', model.type);
    end
    if size(Fquery, 2) ~= model.nObjective
        error('InvGP_predict:ObjectiveDimensionMismatch', ...
            'Fquery has %d columns, but the model expects %d objectives.', ...
            size(Fquery, 2), model.nObjective);
    end
    if numel(model.gp) ~= model.nDecision || ...
            numel(model.activeObjective) ~= model.nObjective || ...
            numel(model.xMean) ~= model.nDecision || ...
            numel(model.xScale) ~= model.nDecision
        error('InvGP_predict:InvalidModelDimensions', ...
            'The stored inverse GP model has inconsistent dimensions.');
    end

    Fquery = double(Fquery);
    nQuery = size(Fquery, 1);
    Fscaled = (Fquery - model.fMean) ./ model.fScale;
    Ffit = Fscaled(:, model.activeObjective);
    Xscaled = zeros(nQuery, model.nDecision);
    XstdScaled = zeros(nQuery, model.nDecision);

    if nQuery == 0
        Xpred = zeros(0, model.nDecision);
        Xstd = zeros(0, model.nDecision);
        return;
    end

    for d = 1:model.nDecision
        component = model.gp{d};
        if isstruct(component) && isfield(component, 'isConstant') && ...
                component.isConstant
            Xscaled(:, d) = component.value;
            XstdScaled(:, d) = 0;
        else
            [Xscaled(:, d), XstdScaled(:, d)] = predict(component, Ffit);
        end
    end

    Xpred = Xscaled .* model.xScale + model.xMean;
    Xstd = XstdScaled .* abs(model.xScale);

    if any(~isfinite(Xpred(:))) || any(~isfinite(Xstd(:)))
        error('InvGP_predict:NonfinitePrediction', ...
            'The inverse GP produced NaN or Inf predictions.');
    end
end
