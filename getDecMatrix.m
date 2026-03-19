function decs = getDecMatrix(population)
%GETDECMATRIX Convert a population struct array into a decision matrix.

    if isempty(population)
        decs = zeros(0, 0);
        return;
    end
    decs = reshape([population.decs], numel(population(1).decs), [])';
end
