function Population = Initialization(Problem, N)
%INITIALIZATION Generate a uniformly random initial population.
%   POPULATION = INITIALIZATION(PROBLEM, N) returns a structure with fields:
%       decs - N-by-D decision matrix
%       objs - N-by-M objective matrix

    if nargin < 2
        error('Initialization:NotEnoughInputs', 'Problem and population size N are required.');
    end

    lower = reshape(Problem.lower, 1, []);
    upper = reshape(Problem.upper, 1, []);
    D = Problem.D;

    decs = rand(N, D) .* repmat(upper - lower, N, 1) + repmat(lower, N, 1);
    objs = Problem.evaluate(decs);
    if size(objs, 1) ~= N
        error('Initialization:InvalidEvaluation', 'Problem.evaluate must return an N-by-M objective matrix.');
    end

    Population = struct('decs', decs, 'objs', objs);
end
