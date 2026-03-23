function Result = MMOEADC(Problem, Options)
%MMOEADC Standalone MATLAB implementation of the MMOEA-DC algorithm.
%   RESULT = MMOEADC(PROBLEM, OPTIONS) runs the decision-space crowding based
%   multi-objective evolutionary algorithm MMOEA-DC without depending on the
%   PlatEMO platform.
%
%   Required fields of PROBLEM:
%       Problem.D         - Number of decision variables.
%       Problem.M         - Number of objectives.
%       Problem.lower     - 1-by-D lower bounds.
%       Problem.upper     - 1-by-D upper bounds.
%       Problem.evaluate  - Function handle, objs = f(decs), where decs is
%                           N-by-D and objs is N-by-M.
%
%   Optional fields of OPTIONS:
%       N                 - Population size. Default: 100.
%       MaxGen            - Maximum number of generations. Default: 200.
%       FEmax             - Maximum number of function evaluations. If set,
%                           it is converted to MaxGen for compatibility.
%       delta             - Local-cluster size threshold. Default: 5.
%       proC              - SBX crossover probability. Default: 1.
%       disC              - SBX distribution index. Default: 20.
%       proM              - Polynomial mutation probability. Default: 1.
%       disM              - Polynomial mutation distribution index. Default: 20.
%       seed              - Random seed. Default: [].
%       saveHistory       - Whether to save population history. Default: true.
%       PlotFcn           - Optional iteration callback: PlotFcn(state).
%       plotInterval      - Plot/update frequency in generations. Default: 1.
%
%   Return fields of RESULT:
%       population        - Final population structure with fields decs/objs.
%       FrontNo           - Nondominated rank of the final population.
%       history           - Per-generation population snapshots (optional).
%       FE_hist           - Function-evaluation history.
%       gen_hist          - Generation history.
%       options           - Resolved option structure.
%       problem           - Echoed problem structure.

    if nargin < 1
        error('MMOEADC:NotEnoughInputs', 'Problem structure must be provided.');
    end
    if nargin < 2 || isempty(Options)
        Options = struct();
    end

    ValidateProblem(Problem);
    Options = FillDefaultOptions(Options);

    if ~isempty(Options.seed)
        rng(Options.seed, 'twister');
    end

    Population = Initialization(Problem, Options.N);
    FE_hist = zeros(Options.MaxGen + 1, 1);
    gen_hist = (0:Options.MaxGen).';
    FE_hist(1) = size(Population.decs, 1);

    if Options.saveHistory
        History = cell(Options.MaxGen + 1, 1);
        History{1} = Population;
    else
        History = {};
    end

    InvokePlotFcn(Options, Population, FE_hist(1), Options.FEmax, 0);

    for gen = 1:Options.MaxGen
        CrowdDis  = Crowding(Population.decs);
        MatingPool = TournamentSelection(2, Options.N, -CrowdDis);
        Offspring  = Variation(Problem, Population.decs(MatingPool, :), Options);
        Union.decs = [Population.decs; Offspring.decs];
        Union.objs = [Population.objs; Offspring.objs];
        Population = Environmental_Selection_C(Union, Options.N, Options.delta, gen);

        FE_hist(gen + 1) = FE_hist(gen) + size(Offspring.decs, 1);
        if Options.saveHistory
            History{gen + 1} = Population;
        end

        if mod(gen, Options.plotInterval) == 0 || gen == Options.MaxGen
            InvokePlotFcn(Options, Population, FE_hist(gen + 1), Options.FEmax, gen);
        end
    end

    FrontNo = NDSort(Population.objs, size(Population.objs, 1));

    Result = struct();
    Result.population = Population;
    Result.FrontNo    = FrontNo;
    Result.history    = History;
    Result.FE_hist    = FE_hist;
    Result.gen_hist   = gen_hist;
    Result.options    = Options;
    Result.problem    = Problem;
end

function ValidateProblem(Problem)
    requiredFields = {'D', 'M', 'lower', 'upper', 'evaluate'};
    for i = 1:numel(requiredFields)
        if ~isfield(Problem, requiredFields{i})
            error('MMOEADC:InvalidProblem', 'Problem.%s is required.', requiredFields{i});
        end
    end
    if ~isa(Problem.evaluate, 'function_handle')
        error('MMOEADC:InvalidProblem', 'Problem.evaluate must be a function handle.');
    end
    if numel(Problem.lower) ~= Problem.D || numel(Problem.upper) ~= Problem.D
        error('MMOEADC:InvalidProblem', 'Problem.lower and Problem.upper must both have length Problem.D.');
    end
    if any(Problem.upper <= Problem.lower)
        error('MMOEADC:InvalidProblem', 'Every upper bound must be greater than the corresponding lower bound.');
    end
end

function Options = FillDefaultOptions(Options)
    defaults = struct(...
        'N', 100, ...
        'MaxGen', 200, ...
        'FEmax', [], ...
        'delta', 5, ...
        'proC', 1, ...
        'disC', 20, ...
        'proM', 1, ...
        'disM', 20, ...
        'seed', [], ...
        'saveHistory', true, ...
        'PlotFcn', [], ...
        'plotInterval', 1);

    fields = fieldnames(defaults);
    for i = 1:numel(fields)
        if ~isfield(Options, fields{i}) || isempty(Options.(fields{i}))
            Options.(fields{i}) = defaults.(fields{i});
        end
    end

    if ~isempty(Options.FEmax)
        if Options.FEmax < Options.N
            error('MMOEADC:InvalidOptions', 'Options.FEmax must be greater than or equal to Options.N.');
        end
        Options.MaxGen = max(1, ceil((Options.FEmax - Options.N) / Options.N));
    end
end

function InvokePlotFcn(Options, Population, currentFE, maxFE, generation)
    if isempty(Options.PlotFcn)
        return;
    end

    if isempty(maxFE)
        maxFE = currentFE;
    end

    state = struct();
    state.population = Population;
    state.currentFE = currentFE;
    state.maxFE = maxFE;
    state.generation = generation;
    state.frontNo = NDSort(Population.objs, size(Population.objs, 1));
    state.archive.decs = Population.decs(state.frontNo == 1, :);
    state.archive.objs = Population.objs(state.frontNo == 1, :);
    Options.PlotFcn(state);
end
