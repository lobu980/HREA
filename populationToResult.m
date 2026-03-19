function result = populationToResult(population)
%POPULATIONTORESULT Convert internal population structs into X/F matrices.

    result = struct('X', [], 'F', []);
    if isempty(population)
        return;
    end
    result.X = getDecMatrix(population);
    result.F = getObjMatrix(population);
end
