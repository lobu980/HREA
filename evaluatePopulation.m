function population = evaluatePopulation(problem, decs)
%EVALUATEPOPULATION Evaluate a batch of decision vectors.

    N = size(decs, 1);
    population = repmat(struct('decs', [], 'objs', []), 1, N);
    for i = 1:N
        dec = repairDecision(decs(i, :), problem);
        objs = problem.objFcn(dec);
        objs = objs(:)';
        if any(~isfinite(objs))
            error('HREA:InvalidObjectiveValue', 'Objective function returned non-finite value at solution %d.', i);
        end
        population(i).decs = dec;
        population(i).objs = objs;
    end
end
