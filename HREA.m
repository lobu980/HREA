function [archive, history] = HREA(problem, options)
%HREA Standalone hierarchy-ranking evolutionary algorithm.
%   [archive, history] = HREA(problem, options) runs a standalone MATLAB
%   implementation of the hierarchy ranking based evolutionary algorithm
%   (HREA) for multimodal multi-objective optimization.
%
%   This version removes PlatEMO dependencies and uses plain MATLAB
%   function files. The caller only needs to define the optimization
%   problem through function handles and variable bounds.
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

    if nargin < 2
        options = struct();
    end

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
    history.snapshots = {archive};

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
