function [child1, child2] = simulatedBinaryCrossover(parent1, parent2, problem, proC, disC)
%SIMULATEDBINARYCROSSOVER Simulated binary crossover (SBX).

    D = numel(parent1);
    child1 = parent1;
    child2 = parent2;

    if rand > proC
        return;
    end

    mu = rand(1, D);
    beta = zeros(1, D);
    beta(mu <= 0.5) = (2 * mu(mu <= 0.5)).^(1 / (disC + 1));
    beta(mu > 0.5) = (2 - 2 * mu(mu > 0.5)).^(-1 / (disC + 1));
    beta = beta .* (-1) .^ randi([0, 1], 1, D);
    beta(rand(1, D) < 0.5) = 1;

    child1 = 0.5 * ((1 + beta) .* parent1 + (1 - beta) .* parent2);
    child2 = 0.5 * ((1 - beta) .* parent1 + (1 + beta) .* parent2);

    child1 = min(max(child1, problem.lower), problem.upper);
    child2 = min(max(child2, problem.lower), problem.upper);
end
