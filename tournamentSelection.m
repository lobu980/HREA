function matingPool = tournamentSelection(tournamentSize, poolSize, fitness)
%TOURNAMENTSELECTION Standard minimization-based tournament selection.

    populationSize = numel(fitness);
    matingPool = zeros(1, poolSize);
    for i = 1:poolSize
        candidates = randi(populationSize, 1, tournamentSize);
        [~, bestLocal] = min(fitness(candidates));
        matingPool(i) = candidates(bestLocal);
    end
end
