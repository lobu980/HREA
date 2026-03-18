function objs = getObjMatrix(population)
%GETOBJMATRIX Convert a population struct array into an objective matrix.

    if isempty(population)
        objs = zeros(0, 0);
        return;
    end
    objs = reshape([population.objs], numel(population(1).objs), [])';
end
