function population = initializePopulation(problem, N)
%INITIALIZEPOPULATION Randomly sample and evaluate the initial population.

    D = numel(problem.lower);
    lower = repmat(problem.lower, N, 1);
    upper = repmat(problem.upper, N, 1);
    decs = lower + rand(N, D) .* (upper - lower);

    if ~isempty(problem.integer)
        decs(:, problem.integer) = round(decs(:, problem.integer));
    end

    population = evaluatePopulation(problem, decs);
end
