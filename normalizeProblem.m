function problem = normalizeProblem(problem)
%NORMALIZEPROBLEM Normalize benchmark problem aliases into one format.

    objAliases = {'objFcn', 'evaluate', 'evalFcn', 'CalObj', 'calObj', 'fun', 'fobj'};
    lowerAliases = {'lower', 'lb', 'xl', 'xmin', 'lower_bound'};
    upperAliases = {'upper', 'ub', 'xu', 'xmax', 'upper_bound'};
    integerAliases = {'integer', 'intVars', 'integer_index'};

    objFcn = pickFirstField(problem, objAliases);
    lower = pickFirstField(problem, lowerAliases);
    upper = pickFirstField(problem, upperAliases);
    integerIndex = pickFirstField(problem, integerAliases);

    if ~isempty(objFcn)
        problem.objFcn = objFcn;
    end
    if ~isempty(lower)
        problem.lower = lower;
    end
    if ~isempty(upper)
        problem.upper = upper;
    end
    if ~isempty(integerIndex)
        problem.integer = integerIndex;
    end

    if isfield(problem, 'D') && isscalar(problem.D)
        D = problem.D;
        if isfield(problem, 'lower') && isscalar(problem.lower)
            problem.lower = repmat(problem.lower, 1, D);
        end
        if isfield(problem, 'upper') && isscalar(problem.upper)
            problem.upper = repmat(problem.upper, 1, D);
        end
    end
end

function value = pickFirstField(data, candidates)
%PICKFIRSTFIELD Return the first existing non-empty field from candidates.

    value = [];
    for i = 1:numel(candidates)
        if isfield(data, candidates{i}) && ~isempty(data.(candidates{i}))
            value = data.(candidates{i});
            return;
        end
    end
end
