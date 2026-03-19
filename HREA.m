function [DifPop, TraPop, out] = HREA(problem, opts, name)
%HREA Standalone hierarchy-ranking evolutionary algorithm.
%   [DifPop, TraPop, out] = HREA(problem, opts, name) runs a standalone
%   MATLAB implementation of the hierarchy ranking based evolutionary
%   algorithm (HREA) for multimodal multi-objective optimization.
%
%   This version removes PlatEMO dependencies and can be called directly by
%   experiment scripts. The output format is aligned with the common
%   benchmark-driver style where TraPop/F and TraPop/X are used for metric
%   calculation after the optimization ends.
%
%   Supported problem fields (aliases are accepted by normalizeProblem):
%       objFcn / evaluate / CalObj : function handle, objs = f(dec)
%       lower / lb / xl            : 1-by-D lower bounds
%       upper / ub / xu            : 1-by-D upper bounds
%       integer                    : integer variable indices (optional)
%
%   Supported options:
%       N, maxFE/FEmax, eps, p, proC, disC, proM, disM, seed, verbose
%
%   Outputs:
%       DifPop : final decision-space population struct with fields X and F
%       TraPop : final archive struct with fields X and F
%       out    : run record containing FE/gen histories and raw populations
%
%   Reference:
%       W. Li, X. Yao, T. Zhang, R. Wang, and L. Wang, "Hierarchy ranking
%       method for multimodal multi-objective optimization with local
%       Pareto fronts," IEEE Transactions on Evolutionary Computation, 2022.

    if nargin < 2 || isempty(opts)
        opts = struct();
    end
    if nargin < 3
        name = '';
    end

    problem = normalizeProblem(problem);
    problem = validateProblem(problem);
    opts = defaultOptions(problem, opts);
    refs = prepareReferenceData(problem, name);

    if ~isempty(opts.seed)
        rng(opts.seed);
    end

    population = initializePopulation(problem, opts.N);
    FE = numel(population);

    [population, crowdDisPopulation] = environmentalSelection(population, opts.N);
    [archive, crowdDisArchive] = archiveUpdate(population, opts.N, opts.eps, 0);

    out = initializeRunOutput(name, FE, population, archive, refs);
    if opts.enablePlot
        PlotPopulations(populationToResult(population), populationToResult(archive), FE, opts.maxFE, name, opts.nvar);
    end
    generation = 0;

    while FE < opts.maxFE
        generation = generation + 1;
        remaining = opts.maxFE - FE;
        offspringCount = min(opts.N, remaining);
        if offspringCount <= 0
            break;
        end

        if FE >= opts.maxFE * 0.5 && rand < opts.p
            matingPool = tournamentSelection(2, offspringCount, -crowdDisArchive);
            offspring = operatorGA(problem, archive(matingPool), opts, offspringCount);
        else
            matingPool = tournamentSelection(2, offspringCount, -crowdDisPopulation);
            offspring = operatorGA(problem, population(matingPool), opts, offspringCount);
        end
        FE = FE + numel(offspring);

        [population, crowdDisPopulation] = environmentalSelection([population, offspring], opts.N);
        progress = FE / opts.maxFE;
        [archive, crowdDisArchive] = archiveUpdate([archive, offspring], opts.N, opts.eps, progress);
        out = appendRunOutput(out, FE, generation, population, archive, refs);
        if opts.enablePlot && mod(generation, opts.plotInterval) == 0
            PlotPopulations(populationToResult(population), populationToResult(archive), FE, opts.maxFE, name, opts.nvar);
        end

        if opts.verbose
            label = name;
            if isempty(label)
                label = 'HREA';
            end
            fprintf('[%s] Generation %4d | FE %6d / %6d | Pop %4d | Archive %4d\n', ...
                label, generation, FE, opts.maxFE, numel(population), numel(archive));
        end
    end

    DifPop = populationToResult(population);
    TraPop = populationToResult(archive);
    out.finalPopulation = population;
    out.finalArchive = archive;
    out.options = opts;
    out.problem = problem;
    out.name = name;
end
