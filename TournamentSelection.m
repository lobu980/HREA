function MatingPool = TournamentSelection(TourSize, N, Fitness)
%TOURNAMENTSELECTION Tournament selection for minimization fitness values.
%   MATINGPOOL = TOURNAMENTSELECTION(TOURSIZE, N, FITNESS) returns N selected
%   indices. Smaller FITNESS values are preferred.

    if nargin < 3
        error('TournamentSelection:NotEnoughInputs', 'TourSize, N and Fitness are required.');
    end

    Fitness = Fitness(:);
    L = numel(Fitness);
    MatingPool = zeros(N, 1);

    for i = 1:N
        candidates = randi(L, TourSize, 1);
        values = Fitness(candidates);
        bestValue = min(values);
        bestIndices = candidates(values == bestValue);
        MatingPool(i) = bestIndices(randi(numel(bestIndices)));
    end
end
