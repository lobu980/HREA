function [DifPop, TraPop, out] = MMEA_BDC(problem, opts, name)
%MMEA_BDC Adapter that runs the standalone MMOEA-DC implementation.
%   [DIFPOP, TRAPOP, OUT] = MMEA_BDC(PROBLEM, OPTS, NAME) converts an
%   external benchmark/problem structure to the internal MMOEADC interface,
%   executes the algorithm, and exports results in the workflow-friendly
%   structure expected by the supplied experiment script.

    if nargin < 2 || isempty(opts)
        opts = struct();
    end
    if nargin < 3
        name = '';
    end

    internalProblem = ConvertProblem(problem, name);
    internalOptions = ConvertOptions(opts);
    result = MMOEADC(internalProblem, internalOptions);

    finalPop = result.population;
    ndMask = result.FrontNo == 1;

    DifPop = struct();
    DifPop.X = finalPop.decs(ndMask, :);
    DifPop.F = finalPop.objs(ndMask, :);

    TraPop = struct();
    TraPop.X = finalPop.decs;
    TraPop.F = finalPop.objs;

    out = struct();
    out.result = result;
    out.problem_name = name;
    out.FE_hist = result.FE_hist;
    out.gen_hist = result.gen_hist;
    out.population_history = result.history;
end

function internalOptions = ConvertOptions(opts)
    internalOptions = struct();
    internalOptions.N = GetOption(opts, {'N', 'popsize', 'populationSize'}, 100);
    internalOptions.FEmax = GetOption(opts, {'FEmax', 'maxFE'}, []);
    internalOptions.MaxGen = GetOption(opts, {'MaxGen', 'maxGen'}, 200);
    internalOptions.delta = GetOption(opts, {'delta'}, 5);
    internalOptions.proC = GetOption(opts, {'proC'}, 1);
    internalOptions.disC = GetOption(opts, {'disC'}, 20);
    internalOptions.proM = GetOption(opts, {'proM'}, 1);
    internalOptions.disM = GetOption(opts, {'disM', 'etaM_local'}, 20);
    internalOptions.seed = GetOption(opts, {'seed'}, []);
    internalOptions.saveHistory = true;
end

function value = GetOption(opts, names, defaultValue)
    value = defaultValue;
    for i = 1:numel(names)
        if isfield(opts, names{i}) && ~isempty(opts.(names{i}))
            value = opts.(names{i});
            return;
        end
    end
end

function internalProblem = ConvertProblem(problem, name)
    if isfield(problem, 'D') && isfield(problem, 'M') && isfield(problem, 'lower') && ...
            isfield(problem, 'upper') && isfield(problem, 'evaluate')
        internalProblem = problem;
        return;
    end

    internalProblem = struct();
    internalProblem.D = FindNumericField(problem, {'D', 'dim', 'dims', 'n_var', 'nvars', 'nx', 'numVar', 'num_var'});
    internalProblem.M = FindNumericField(problem, {'M', 'n_obj', 'nobjs', 'numObj', 'num_obj', 'nf'});
    internalProblem.lower = FindVectorField(problem, {'lower', 'lb', 'Lower', 'xmin', 'lbound', 'lower_bound'}, internalProblem.D);
    internalProblem.upper = FindVectorField(problem, {'upper', 'ub', 'Upper', 'xmax', 'ubound', 'upper_bound'}, internalProblem.D);
    internalProblem.evaluate = BuildEvaluationHandle(problem, internalProblem, name);
end

function value = FindNumericField(problem, candidateFields)
    value = [];
    for i = 1:numel(candidateFields)
        if isfield(problem, candidateFields{i}) && ~isempty(problem.(candidateFields{i}))
            value = double(problem.(candidateFields{i}));
            if isscalar(value)
                return;
            end
        end
    end
    error('MMEA_BDC:MissingProblemField', 'Unable to infer a scalar problem field from: %s.', strjoin(candidateFields, ', '));
end

function value = FindVectorField(problem, candidateFields, dimension)
    value = [];
    for i = 1:numel(candidateFields)
        if isfield(problem, candidateFields{i}) && ~isempty(problem.(candidateFields{i}))
            candidate = reshape(double(problem.(candidateFields{i})), 1, []);
            if numel(candidate) == 1
                value = repmat(candidate, 1, dimension);
            elseif numel(candidate) == dimension
                value = candidate;
            else
                error('MMEA_BDC:InvalidBounds', 'Field %s does not match inferred dimension %d.', candidateFields{i}, dimension);
            end
            return;
        end
    end
    error('MMEA_BDC:MissingProblemField', 'Unable to infer bounds from fields: %s.', strjoin(candidateFields, ', '));
end

function handleOut = BuildEvaluationHandle(problem, internalProblem, name)
    if isfield(problem, 'evaluate') && isa(problem.evaluate, 'function_handle')
        rawHandle = problem.evaluate;
    elseif isfield(problem, 'objFcn') && isa(problem.objFcn, 'function_handle')
        rawHandle = problem.objFcn;
    elseif isfield(problem, 'fun') && isa(problem.fun, 'function_handle')
        rawHandle = problem.fun;
    elseif isfield(problem, 'objective') && isa(problem.objective, 'function_handle')
        rawHandle = problem.objective;
    elseif isfield(problem, 'CalObj') && isa(problem.CalObj, 'function_handle')
        rawHandle = problem.CalObj;
    else
        error('MMEA_BDC:MissingProblemField', ...
            'Problem %s does not expose a supported objective function handle.', name);
    end

    handleOut = @(decs) EvaluateWrapper(rawHandle, decs, internalProblem.M);
end

function objs = EvaluateWrapper(rawHandle, decs, M)
    try
        objs = rawHandle(decs);
    catch
        N = size(decs, 1);
        objs = zeros(N, M);
        for i = 1:N
            value = rawHandle(decs(i, :));
            objs(i, :) = reshape(value, 1, []);
        end
    end

    if isstruct(objs)
        if isfield(objs, 'objs')
            objs = objs.objs;
        elseif isfield(objs, 'F')
            objs = objs.F;
        else
            error('MMEA_BDC:InvalidEvaluation', 'Objective handle returned an unsupported struct result.');
        end
    end

    if size(objs, 2) ~= M
        if size(objs, 1) == M && size(objs, 2) == size(decs, 1)
            objs = objs.';
        else
            error('MMEA_BDC:InvalidEvaluation', 'Objective function output dimension does not match problem.M.');
        end
    end
end
