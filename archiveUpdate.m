function [population, crowdDis] = archiveUpdate(population, N, epsValue, stage)
%ARCHIVEUPDATE Update the HREA archive of hierarchical local Pareto fronts.

    if isempty(population)
        crowdDis = [];
        return;
    end

    n = numel(population);
    if epsValue ~= 1 && stage < 0.5
        epsValue = 2 * (1 - epsValue) / (2 * stage + 1) + 2 * epsValue - 1;
    end

    allObjs = reshape([population.objs], numel(population(1).objs), [])';
    frontNo = ndSort(allObjs, n);
    firstFrontIndex = (frontNo == 1);
    firstPF = population(firstFrontIndex);
    newPop = firstPF;
    remainPop = population(~firstFrontIndex);

    V = neighborhoodRadius(population);

    while ~isempty(remainPop)
        dist = min(pairwiseDistance(getDecMatrix(newPop), getDecMatrix(remainPop)), [], 1);
        removeIndex = dist < V;
        remainPop(removeIndex) = [];
        if isempty(remainPop)
            break;
        end

        remainObjs = getObjMatrix(remainPop);
        remainFrontNo = ndSort(remainObjs, numel(remainPop));
        pickPop = remainPop(remainFrontNo == 1);
        adjustedObjs = [getObjMatrix(pickPop) .* (1 - epsValue); getObjMatrix(firstPF)];
        nF = ndSort(adjustedObjs, size(adjustedObjs, 1));
        nF = nF(1:numel(pickPop));

        if max(nF) > 1
            newPop = [newPop, pickPop(nF == 1)]; %#ok<AGROW>
            remainPop = remainPop(remainFrontNo ~= 1);
            break;
        else
            newPop = [newPop, pickPop]; %#ok<AGROW>
            remainPop = remainPop(remainFrontNo ~= 1);
        end
    end
    population = newPop;

    if numel(population) > N
        awardIndex = [];
        objs = getObjMatrix(population);
        frontNo = ndSort(objs, numel(population));
        maxFront = max(frontNo);
        selectedPop = struct('decs', {}, 'objs', {});
        tmpPop = struct('decs', {}, 'objs', {});
        nSubPop = ceil(N / maxFront);

        for i = 1:maxFront
            pop = population(frontNo == i);
            if numel(pop) < nSubPop
                selectedPop = [selectedPop, pop]; %#ok<AGROW>
                awardIndex = [awardIndex, (nSubPop - numel(pop)) * ones(1, numel(pop))]; %#ok<AGROW>
            else
                tmpPop = [tmpPop, pop]; %#ok<AGROW>
            end
        end

        while numel(tmpPop) > N - numel(selectedPop)
            dist = pairwiseDistance(getDecMatrix(tmpPop), getDecMatrix(tmpPop));
            dist = sort(dist, 1, 'ascend');
            density = sum(dist(1:min(3, size(dist, 1)), :), 1);
            [~, remove] = min(density);
            tmpPop(remove) = [];
        end

        awardIndex = [awardIndex, zeros(1, numel(tmpPop))] + 1;
        population = [selectedPop, tmpPop];
        crowdDis = crowding(getDecMatrix(population));
        crowdDis = crowdDis .* awardIndex(:);
    else
        crowdDis = crowding(getDecMatrix(population));
    end
end
