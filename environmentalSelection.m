function [population, crowdDis] = environmentalSelection(population, N)
%ENVIRONMENTALSELECTION Select the next population using local convergence.

    n = numel(population);
    decs = getDecMatrix(population);
    objs = getObjMatrix(population);
    dist = pairwiseDistance(decs, decs);
    V = neighborhoodRadius(population);

    dominationX = zeros(n);
    for i = 1:n
        for j = i + 1:n
            if dist(i, j) > V
                continue;
            end
            isILess = objs(i, :) < objs(j, :);
            isIGreater = objs(i, :) > objs(j, :);
            if all(isILess | (~isIGreater))
                dominationX(i, j) = 0;
                dominationX(j, i) = 1;
            elseif all(isIGreater | (~isILess))
                dominationX(i, j) = 1;
                dominationX(j, i) = 0;
            end
        end
    end

    localC = zeros(1, n);
    for i = 1:n
        index = dist(i, :) < V;
        denominator = sum(index);
        if denominator == 0
            localC(i) = 0;
        else
            localC(i) = sum(dominationX(i, index)) / denominator;
        end
    end

    sortedDist = sort(pairwiseDistance(decs, decs), 1, 'ascend');
    crowdDisRaw = sum(sortedDist(1:min(3, size(sortedDist, 1)), :), 1);
    [~, order] = sortrows([localC(:), -crowdDisRaw(:)]);
    population = population(order);

    if numel(population) > N
        population = population(1:N);
    end

    crowdDis = crowding(getDecMatrix(population));
end
