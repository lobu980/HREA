function offspring = operatorGA(problem, parents, options, offspringCount)
%OPERATORGA Generate offspring using SBX crossover and polynomial mutation.

    parentDecs = reshape([parents.decs], numel(parents(1).decs), [])';
    nParents = size(parentDecs, 1);
    D = size(parentDecs, 2);

    if mod(nParents, 2) == 1
        parentDecs(end + 1, :) = parentDecs(randi(nParents), :);
        nParents = nParents + 1;
    end

    matingOrder = randperm(nParents);
    parentDecs = parentDecs(matingOrder, :);
    offspringDecs = zeros(nParents, D);

    for i = 1:2:nParents
        p1 = parentDecs(i, :);
        p2 = parentDecs(i + 1, :);
        [c1, c2] = simulatedBinaryCrossover(p1, p2, problem, options.proC, options.disC);
        c1 = polynomialMutation(c1, problem, options.proM / D, options.disM);
        c2 = polynomialMutation(c2, problem, options.proM / D, options.disM);
        offspringDecs(i, :) = repairDecision(c1, problem);
        offspringDecs(i + 1, :) = repairDecision(c2, problem);
    end

    offspringDecs = offspringDecs(1:offspringCount, :);
    offspring = evaluatePopulation(problem, offspringDecs);
end
