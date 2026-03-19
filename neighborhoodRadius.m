function V = neighborhoodRadius(population)
%NEIGHBORHOODRADIUS Compute the decision-space local neighborhood radius.

    decs = getDecMatrix(population);
    width = max(decs, [], 1) - min(decs, [], 1);
    width(width == 0) = 1;
    V = 0.2 * prod(width)^(1 / size(decs, 2));
end
