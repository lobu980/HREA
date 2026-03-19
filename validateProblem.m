function problem = validateProblem(problem)
%VALIDATEPROBLEM Validate the user-supplied problem definition.

    requiredFields = {'objFcn', 'lower', 'upper'};
    for i = 1:numel(requiredFields)
        if ~isfield(problem, requiredFields{i})
            error('HREA:MissingProblemField', 'Missing problem field "%s".', requiredFields{i});
        end
    end

    if ~isa(problem.objFcn, 'function_handle')
        error('HREA:InvalidObjective', 'problem.objFcn must be a function handle.');
    end

    problem.lower = problem.lower(:)';
    problem.upper = problem.upper(:)';
    if numel(problem.lower) ~= numel(problem.upper)
        error('HREA:BoundSizeMismatch', 'problem.lower and problem.upper must have the same length.');
    end
    if any(problem.lower > problem.upper)
        error('HREA:InvalidBounds', 'Each lower bound must be <= the corresponding upper bound.');
    end

    if ~isfield(problem, 'integer') || isempty(problem.integer)
        problem.integer = [];
    else
        problem.integer = unique(problem.integer(:)');
        if any(problem.integer < 1) || any(problem.integer > numel(problem.lower))
            error('HREA:InvalidIntegerIndex', 'problem.integer contains out-of-range indices.');
        end
    end
end
