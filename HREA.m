function [archive, history] = HREA(problem, options)
%HREA Standalone hierarchy-ranking evolutionary algorithm.
%   [archive, history] = HREA(problem, options) runs a standalone MATLAB
%   implementation of the hierarchy ranking based evolutionary algorithm
%   (HREA) for multimodal multi-objective optimization.
%
%   This version removes PlatEMO dependencies and keeps all helper logic in
%   complete form inside one file. The caller only needs to define the
%   optimization problem through function handles and variable bounds.
%
%   Required fields in problem:
%       problem.objFcn    : function handle, objs = objFcn(dec)
%       problem.lower     : 1-by-D lower bound vector
%       problem.upper     : 1-by-D upper bound vector
%
%   Optional fields in problem:
%       problem.integer   : indices of integer decision variables
%
%   Optional fields in options:
%       options.N         : population size (default 100)
%       options.maxFE     : maximum function evaluations (default 10000)
%       options.eps       : local Pareto front quality parameter (default 0.3)
%       options.p         : archive mating probability after half budget (0.5)
%       options.proC      : crossover probability (default 1)
%       options.disC      : SBX distribution index (default 20)
%       options.proM      : mutation probability per individual (default 1)
%       options.disM      : polynomial mutation index (default 20)
%       options.seed      : RNG seed, empty means keep current state
%       options.verbose   : print progress flag (default true)
%
%   Outputs:
%       archive           : final archive struct array with fields decs, objs
%       history           : struct storing run statistics
%
%   Example:
%       problem.objFcn = @(x) [x(1), (1 + x(2)) / x(1)];
%       problem.lower  = [0.1, 0];
%       problem.upper  = [1.0, 1];
%       options.N      = 80;
%       options.maxFE  = 4000;
%       archive = HREA(problem, options);
%
%   Reference:
%       W. Li, X. Yao, T. Zhang, R. Wang, and L. Wang, "Hierarchy ranking
%       method for multimodal multi-objective optimization with local
%       Pareto fronts," IEEE Transactions on Evolutionary Computation, 2022.

    problem = validateProblem(problem);
    options = defaultOptions(problem, options);

    if ~isempty(options.seed)
        rng(options.seed);
    end

    population = initializePopulation(problem, options.N);
    FE = numel(population);

    [population, crowdDisPopulation] = environmentalSelection(population, options.N);
    [archive, crowdDisArchive] = archiveUpdate(population, options.N, options.eps, 0);

    history.FE = FE;
    history.archiveSize = numel(archive);
    history.populationSize = numel(population);
    history.snapshots = cell(0, 1);

    generation = 0;
    while FE < options.maxFE
        generation = generation + 1;
        remaining = options.maxFE - FE;
        offspringCount = min(options.N, remaining);
        if offspringCount <= 0
            break;
        end

        if FE >= options.maxFE * 0.5 && rand < options.p
            matingPool = tournamentSelection(2, offspringCount, -crowdDisArchive);
            offspring = operatorGA(problem, archive(matingPool), options, offspringCount);
        else
            matingPool = tournamentSelection(2, offspringCount, -crowdDisPopulation);
            offspring = operatorGA(problem, population(matingPool), options, offspringCount);
        end
        FE = FE + numel(offspring);

        [population, crowdDisPopulation] = environmentalSelection([population, offspring], options.N);
        progress = FE / options.maxFE;
        [archive, crowdDisArchive] = archiveUpdate([archive, offspring], options.N, options.eps, progress);

        history.FE(end + 1, 1) = FE; %#ok<AGROW>
        history.archiveSize(end + 1, 1) = numel(archive); %#ok<AGROW>
        history.populationSize(end + 1, 1) = numel(population); %#ok<AGROW>
        history.snapshots{end + 1, 1} = archive; %#ok<AGROW>

        if options.verbose
            fprintf('Generation %4d | FE %6d / %6d | Pop %4d | Archive %4d\n', ...
                generation, FE, options.maxFE, numel(population), numel(archive));
        end
    end
end

function problem = validateProblem(problem)
    requiredFields = {'objFcn', 'lower', 'upper'};
    for i = 1:numel(requiredFields)
        if ~isfield(problem, requiredFields{i})
            error('HREA:MissingProblemField', 'Missing problem field "%s".', requiredFields{i});
        end
    end

    if ~isa(problem.objFcn, 'function_handle')
        error('HREA:InvalidObjective', 'problem.objFcn must be a function handle.');
    end

    problem.lower = problem.lower(:)';
    problem.upper = problem.upper(:)';
    if numel(problem.lower) ~= numel(problem.upper)
        error('HREA:BoundSizeMismatch', 'problem.lower and problem.upper must have the same length.');
    end
    if any(problem.lower > problem.upper)
        error('HREA:InvalidBounds', 'Each lower bound must be <= the corresponding upper bound.');
    end

    if ~isfield(problem, 'integer') || isempty(problem.integer)
        problem.integer = [];
    else
        problem.integer = unique(problem.integer(:)');
        if any(problem.integer < 1) || any(problem.integer > numel(problem.lower))
            error('HREA:InvalidIntegerIndex', 'problem.integer contains out-of-range indices.');
        end
    end
end

function options = defaultOptions(problem, options)
    if nargin < 2 || isempty(options)
        options = struct();
    end

    options = setDefault(options, 'N', 100);
    options = setDefault(options, 'maxFE', 10000);
    options = setDefault(options, 'eps', 0.3);
    options = setDefault(options, 'p', 0.5);
    options = setDefault(options, 'proC', 1.0);
    options = setDefault(options, 'disC', 20);
    options = setDefault(options, 'proM', 1.0);
    options = setDefault(options, 'disM', 20);
    options = setDefault(options, 'seed', []);
    options = setDefault(options, 'verbose', true);
    options.D = numel(problem.lower);

    validateattributes(options.N, {'numeric'}, {'scalar', 'integer', '>=', 2}, mfilename, 'options.N');
    validateattributes(options.maxFE, {'numeric'}, {'scalar', 'integer', '>=', options.N}, mfilename, 'options.maxFE');
    validateattributes(options.eps, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, mfilename, 'options.eps');
    validateattributes(options.p, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, mfilename, 'options.p');
end

function options = setDefault(options, name, value)
    if ~isfield(options, name) || isempty(options.(name))
        options.(name) = value;
    end
end

function population = initializePopulation(problem, N)
    D = numel(problem.lower);
    lower = repmat(problem.lower, N, 1);
    upper = repmat(problem.upper, N, 1);
    decs = lower + rand(N, D) .* (upper - lower);

    if ~isempty(problem.integer)
        decs(:, problem.integer) = round(decs(:, problem.integer));
    end

    population = evaluatePopulation(problem, decs);
end

function population = evaluatePopulation(problem, decs)
    N = size(decs, 1);
    population = repmat(struct('decs', [], 'objs', []), 1, N);
    for i = 1:N
        dec = repairDecision(decs(i, :), problem);
        objs = problem.objFcn(dec);
        objs = objs(:)';
        if any(~isfinite(objs))
            error('HREA:InvalidObjectiveValue', 'Objective function returned non-finite value at solution %d.', i);
        end
        population(i).decs = dec;
        population(i).objs = objs;
    end
end

function dec = repairDecision(dec, problem)
    dec = min(max(dec, problem.lower), problem.upper);
    if ~isempty(problem.integer)
        dec(problem.integer) = round(dec(problem.integer));
        dec = min(max(dec, problem.lower), problem.upper);
    end
end

function offspring = operatorGA(problem, parents, options, offspringCount)
    parentDecs = reshape([parents.decs], numel(parents(1).decs), [])';
    nParents = size(parentDecs, 1);
    D = size(parentDecs, 2);

    if mod(nParents, 2) == 1
        parentDecs(end + 1, :) = parentDecs(randi(nParents), :);
        nParents = nParents + 1;
    end

    matingOrder = randperm(nParents);
    parentDecs = parentDecs(matingOrder, :);
    offspringDecs = zeros(nParents, D);

    for i = 1:2:nParents
        p1 = parentDecs(i, :);
        p2 = parentDecs(i + 1, :);
        [c1, c2] = simulatedBinaryCrossover(p1, p2, problem, options.proC, options.disC);
        c1 = polynomialMutation(c1, problem, options.proM / D, options.disM);
        c2 = polynomialMutation(c2, problem, options.proM / D, options.disM);
        offspringDecs(i, :) = repairDecision(c1, problem);
        offspringDecs(i + 1, :) = repairDecision(c2, problem);
    end

    offspringDecs = offspringDecs(1:offspringCount, :);
    offspring = evaluatePopulation(problem, offspringDecs);
end

function [child1, child2] = simulatedBinaryCrossover(parent1, parent2, problem, proC, disC)
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

function mutant = polynomialMutation(individual, problem, mutationRate, disM)
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

function matingPool = tournamentSelection(tournamentSize, poolSize, fitness)
    populationSize = numel(fitness);
    matingPool = zeros(1, poolSize);
    for i = 1:poolSize
        candidates = randi(populationSize, 1, tournamentSize);
        [~, bestLocal] = min(fitness(candidates));
        matingPool(i) = candidates(bestLocal);
    end
end

function [population, crowdDis] = archiveUpdate(population, N, epsValue, stage)
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

function [population, crowdDis] = environmentalSelection(population, N)
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

function crowdDis = crowding(pop)
    [N, D] = size(pop);
    if N == 0
        crowdDis = [];
        return;
    elseif N == 1
        crowdDis = inf;
        return;
    end

    K = N - 1;
    Z = min(pop, [], 1);
    Zmax = max(pop, [], 1);
    range = Zmax - Z;
    range(range == 0) = 1;

    normalized = (pop - repmat(Z, N, 1)) ./ repmat(range, N, 1);
    distance = pairwiseDistance(normalized, normalized);
    [value, ~] = sort(distance, 2, 'ascend');
    harmonicTerms = 1 ./ max(value(:, 2:N), eps);
    crowdDis = K ./ sum(harmonicTerms, 2);

    if D == 0
        crowdDis = zeros(N, 1);
    end
end

function frontNo = ndSort(objs, nSort)
    N = size(objs, 1);
    dominateMe = zeros(1, N);
    iDominate = cell(1, N);
    frontNo = inf(1, N);
    front{1} = []; %#ok<AGROW>

    for p = 1:N
        for q = p + 1:N
            relation = dominationRelation(objs(p, :), objs(q, :));
            if relation == 1
                iDominate{p}(end + 1) = q; %#ok<AGROW>
                dominateMe(q) = dominateMe(q) + 1;
            elseif relation == -1
                iDominate{q}(end + 1) = p; %#ok<AGROW>
                dominateMe(p) = dominateMe(p) + 1;
            end
        end
        if dominateMe(p) == 0
            frontNo(p) = 1;
            front{1}(end + 1) = p; %#ok<AGROW>
        end
    end

    assigned = numel(front{1});
    currentFront = 1;
    while assigned < min(nSort, N) && ~isempty(front{currentFront})
        nextFront = [];
        for p = front{currentFront}
            dominatedSet = iDominate{p};
            for q = dominatedSet
                dominateMe(q) = dominateMe(q) - 1;
                if dominateMe(q) == 0
                    frontNo(q) = currentFront + 1;
                    nextFront(end + 1) = q; %#ok<AGROW>
                    assigned = assigned + 1;
                end
            end
        end
        currentFront = currentFront + 1;
        front{currentFront} = nextFront; %#ok<AGROW>
    end
end

function relation = dominationRelation(obj1, obj2)
    less = any(obj1 < obj2);
    greater = any(obj1 > obj2);
    if ~greater && less
        relation = 1;
    elseif ~less && greater
        relation = -1;
    else
        relation = 0;
    end
end

function V = neighborhoodRadius(population)
    decs = getDecMatrix(population);
    width = max(decs, [], 1) - min(decs, [], 1);
    width(width == 0) = 1;
    V = 0.2 * prod(width)^(1 / size(decs, 2));
end

function decs = getDecMatrix(population)
    if isempty(population)
        decs = zeros(0, 0);
        return;
    end
    decs = reshape([population.decs], numel(population(1).decs), [])';
end

function objs = getObjMatrix(population)
    if isempty(population)
        objs = zeros(0, 0);
        return;
    end
    objs = reshape([population.objs], numel(population(1).objs), [])';
end

function dist = pairwiseDistance(A, B)
    if isempty(A) || isempty(B)
        dist = zeros(size(A, 1), size(B, 1));
        return;
    end
    AA = sum(A.^2, 2);
    BB = sum(B.^2, 2)';
    dist = sqrt(max(AA + BB - 2 * (A * B'), 0));
end
