function mutant = polynomialMutation(individual, problem, mutationRate, disM)
%POLYNOMIALMUTATION Polynomial mutation for bounded variables.

    mutant = individual;
    D = numel(individual);
    lower = problem.lower;
    upper = problem.upper;

    for j = 1:D
        if rand <= mutationRate
            if lower(j) == upper(j)
                mutant(j) = lower(j);
                continue;
            end
            delta1 = (mutant(j) - lower(j)) / (upper(j) - lower(j));
            delta2 = (upper(j) - mutant(j)) / (upper(j) - lower(j));
            rnd = rand;
            mutPow = 1 / (disM + 1);
            if rnd <= 0.5
                xy = 1 - delta1;
                val = 2 * rnd + (1 - 2 * rnd) * (xy^(disM + 1));
                deltaq = val^mutPow - 1;
            else
                xy = 1 - delta2;
                val = 2 * (1 - rnd) + 2 * (rnd - 0.5) * (xy^(disM + 1));
                deltaq = 1 - val^mutPow;
            end
            mutant(j) = mutant(j) + deltaq * (upper(j) - lower(j));
        end
    end

    mutant = min(max(mutant, lower), upper);
end
