function results = run_HREA_experiment(name, num_of_runs, suite)
%RUN_HREA_EXPERIMENT HREA-style benchmark driver for MMOEA-DC.
%   RESULTS = RUN_HREA_EXPERIMENT(NAME, NUM_OF_RUNS, SUITE) runs the
%   standalone MMOEA-DC code in the same benchmark-experiment style used by
%   HREA. Supported suites are:
%       'CEC2020'
%       'IDMP'
%       'IDMP_e'
%       'auto'    - infer the suite from NAME
%
%   Example:
%       results = run_HREA_experiment('IDMPM2T4_e', 1, 'IDMP_e');
%       results = run_HREA_experiment('CEC2020_F01', 5, 'CEC2020');

    if nargin < 1 || isempty(name)
        name = 'IDMPM2T4_e';
    end
    if nargin < 2 || isempty(num_of_runs)
        num_of_runs = 1;
    end
    if nargin < 3 || isempty(suite)
        suite = InferBenchmarkSuite(name);
    end
    suite = NormalizeSuiteName(suite);

    SetupBenchmarkPaths(suite);

    clc;
    close all;

    problem = ResolveBenchmarkProblem(name, suite);
    fprintf('Running %s test function: %s\n', suite, name);

    opts = BuildDefaultOptions(problem);
    if opts.enablePlot && exist('PlotPopulations', 'file') == 2
        opts.plotFcn = @(state) IterationPlotCallback(state, name);
        opts.plotInterval = 1;
    end
    [pfture, psture] = ResolveReferenceSets(name, suite, problem);

    IGDX_all = nan(num_of_runs, 1);
    IGD_all = nan(num_of_runs, 1);
    HV_all = nan(num_of_runs, 1);
    rPSP_all = nan(num_of_runs, 1);

    static_metric(num_of_runs, 1) = struct('IGD', nan, 'HV', nan, 'IGDx', nan, 'rPSP', nan);
    IGD_hist_all = cell(num_of_runs, 1);
    IGDX_hist_all = cell(num_of_runs, 1);
    FE_hist_all = cell(num_of_runs, 1);
    gen_hist_all = cell(num_of_runs, 1);

    for runs = 1:num_of_runs
        fprintf('总循环次数: %d / %d\n', runs, num_of_runs);

        [DifPop, TraPop, out] = MMEA_BDC(problem, opts, name); %#ok<ASGLU>

        if isfield(out, 'IGD_hist')
            IGD_hist_all{runs} = out.IGD_hist(:);
        else
            IGD_hist_all{runs} = [];
        end

        if isfield(out, 'IGDX_hist')
            IGDX_hist_all{runs} = out.IGDX_hist(:);
        else
            IGDX_hist_all{runs} = [];
        end

        if isfield(out, 'FE_hist')
            FE_hist_all{runs} = out.FE_hist(:);
        else
            FE_hist_all{runs} = [];
        end

        if isfield(out, 'gen_hist')
            gen_hist_all{runs} = out.gen_hist(:);
        else
            gen_hist_all{runs} = [];
        end

        metric = ComputeMetrics(TraPop, pfture, psture);

        IGDX_all(runs) = metric.IGDx;
        IGD_all(runs) = metric.IGD;
        HV_all(runs) = metric.HV;
        rPSP_all(runs) = metric.rPSP;
        static_metric(runs, 1) = metric;
    end

    results = struct();
    results.suite = suite;
    results.problem_name = name;
    results.options = opts;
    results.IGDX_all = IGDX_all;
    results.IGD_all = IGD_all;
    results.HV_all = HV_all;
    results.rPSP_all = rPSP_all;
    results.static_metric = static_metric;
    results.IGD_hist_all = IGD_hist_all;
    results.IGDX_hist_all = IGDX_hist_all;
    results.FE_hist_all = FE_hist_all;
    results.gen_hist_all = gen_hist_all;

    results.IGDX_mean = LocalNanMean(IGDX_all);
    results.IGDX_std = LocalNanStd(IGDX_all);
    results.IGD_mean = LocalNanMean(IGD_all);
    results.IGD_std = LocalNanStd(IGD_all);
    results.HV_mean = LocalNanMean(HV_all);
    results.HV_std = LocalNanStd(HV_all);
    results.rPSP_mean = LocalNanMean(rPSP_all);
    results.rPSP_std = LocalNanStd(rPSP_all);

    fprintf('\n==================== %s / %d 次运行结果汇总 ====================\n', suite, num_of_runs);
    fprintf('IGDX 平均值: %.6e (标准差: %.4e)\n', results.IGDX_mean, results.IGDX_std);
    fprintf('IGD  平均值: %.6e (标准差: %.6e)\n', results.IGD_mean, results.IGD_std);
    fprintf('HV   平均值: %.6e (标准差: %.6e)\n', results.HV_mean, results.HV_std);
    fprintf('DPSP 平均值: %.6e (标准差: %.6e)\n', results.rPSP_mean, results.rPSP_std);

    algTag = 'MMOEADC';
    resultDir = fullfile(pwd, 'compare_results', suite);
    if ~exist(resultDir, 'dir')
        mkdir(resultDir);
    end

    save_filename = sprintf('%s_%s_metrics_all_runs.mat', algTag, name);
    save_path = fullfile(resultDir, save_filename);
    IGDX_mean = results.IGDX_mean;
    IGDX_std = results.IGDX_std;
    IGD_mean = results.IGD_mean;
    IGD_std = results.IGD_std;
    HV_mean = results.HV_mean;
    HV_std = results.HV_std;
    rPSP_mean = results.rPSP_mean;
    rPSP_std = results.rPSP_std;

    save(save_path, ...
        'suite', 'name', 'IGDX_all', 'IGD_all', 'HV_all', 'rPSP_all', ...
        'IGDX_mean', 'IGD_mean', 'HV_mean', 'rPSP_mean', ...
        'IGDX_std', 'IGD_std', 'HV_std', 'rPSP_std', ...
        'static_metric', 'IGD_hist_all', 'IGDX_hist_all', 'FE_hist_all', 'gen_hist_all');

    fprintf('\n所有结果已保存至: %s\n', save_path);

    if exist('bdc_plot_convergence', 'file') == 2
        bdc_plot_convergence(name, num_of_runs, ...
            IGD_hist_all, IGDX_hist_all, FE_hist_all, gen_hist_all, resultDir);
    end
    if exist('bdc_plot_boxplots', 'file') == 2
        bdc_plot_boxplots(name, resultDir, algTag, IGDX_all, IGD_all);
    end

    disp('Optimization Finished.');
end

function suite = InferBenchmarkSuite(name)
    upperName = upper(name);
    if contains(upperName, 'CEC2020')
        suite = 'CEC2020';
    elseif endsWith(lower(name), '_e')
        suite = 'IDMP_e';
    elseif contains(upperName, 'IDMP')
        suite = 'IDMP';
    else
        suite = 'auto';
    end
end

function suite = NormalizeSuiteName(suite)
    switch lower(strtrim(suite))
        case 'cec2020'
            suite = 'CEC2020';
        case 'idmp'
            suite = 'IDMP';
        case {'idmp_e', 'idmpe'}
            suite = 'IDMP_e';
        case 'auto'
            suite = 'auto';
        otherwise
            error('run_HREA_experiment:InvalidSuite', ...
                'Unsupported suite "%s". Use CEC2020, IDMP, IDMP_e, or auto.', suite);
    end
end

function SetupBenchmarkPaths(suite)
    AddExistingPath('.');
    AddExistingPath('MM_testfunctions');
    AddExistingPath('IDMP_testfunctions');
    AddExistingPath('Indicator_calculation');
    AddExistingPath('fun_plot');

    switch suite
        case 'CEC2020'
            AddExistingPath(fullfile('MM_testfunctions', 'CEC2020'));
            AddExistingPath('CEC2020');
            AddExistingPath('CEC2020_testfunctions');
        case 'IDMP'
            AddExistingPath(fullfile('IDMP_testfunctions', 'IDMP'));
            AddExistingPath('IDMP');
        case 'IDMP_e'
            AddExistingPath(fullfile('IDMP_testfunctions', 'IDMP_e'));
            AddExistingPath('IDMP_e');
        otherwise
            AddExistingPath(fullfile('MM_testfunctions', 'CEC2020'));
            AddExistingPath(fullfile('IDMP_testfunctions', 'IDMP'));
            AddExistingPath(fullfile('IDMP_testfunctions', 'IDMP_e'));
    end
end

function AddExistingPath(folderName)
    if exist(folderName, 'dir') == 7
        addpath(genpath(folderName));
    end
end

function problem = ResolveBenchmarkProblem(name, suite)
    if exist('objective_description_function', 'file') == 2
        try
            problem = objective_description_function(name);
            return;
        catch ME
            if ~strcmp(suite, 'auto')
                rethrow(ME);
            end
        end
    end

    error('run_HREA_experiment:MissingDependency', ...
        ['Failed to construct benchmark problem "%s" for suite "%s". ', ...
         'Please ensure objective_description_function.m and the corresponding test suite paths are available.'], ...
         name, suite);
end

function opts = BuildDefaultOptions(problem)
    ops = GetProblemScalar(problem, {'N_ops', 'n_ops'}, 1);

    opts = struct();
    opts.N = 200 * ops;
    opts.FEmax = 10000 * ops;
    opts.eta = 0.8;
    opts.delta = 5;
    opts.eLCI = 0.99;
    opts.lambda = 1;
    opts.K = max(2, round(sqrt(opts.N)));
    opts.useCDdualInM2 = true;
    opts.localOnlyMating = true;
    opts.pM_local = 0.3;
    opts.etaM_local = 50;
    opts.useCCO = true;
    opts.ccoInnerIter = 3;
    opts.ccoAlphaDec = 0.05;
    opts.ccoGuideMax = 30;
    opts.KMetric = max(1, min(opts.N - 1, round(sqrt(opts.N))));
    opts.delLambda = 0.65;
    opts.fdknObjW = 0.4;
    opts.fdknDecW = 0.6;
    opts.enablePlot = true;
end

function value = GetProblemScalar(problem, names, defaultValue)
    value = defaultValue;
    for i = 1:numel(names)
        if isfield(problem, names{i}) && ~isempty(problem.(names{i}))
            value = double(problem.(names{i}));
            if isscalar(value)
                return;
            end
        end
    end
end

function [pfture, psture] = ResolveReferenceSets(name, suite, problem)
    pfture = [];
    psture = [];
    decisionDim = GetProblemScalar(problem, {'D', 'dim', 'dims', 'n_var', 'nvars', 'nx', 'numVar', 'num_var'}, []);
    objectiveDim = GetProblemScalar(problem, {'M', 'n_obj', 'nobjs', 'numObj', 'num_obj', 'nf'}, []);

    referenceData = LocalLoadReferenceData(name, suite);

    if ~isempty(referenceData)
        psture = mergeReferenceBlocks(...
            NormalizeReferenceBlock(GetStructField(referenceData, 'PS_global1', []), decisionDim), ...
            NormalizeReferenceBlock(GetStructField(referenceData, 'PS_global2', []), decisionDim), ...
            NormalizeReferenceBlock(GetStructField(referenceData, 'PS_local', []), decisionDim));
        pfture = mergeReferenceBlocks(...
            NormalizeReferenceBlock(GetStructField(referenceData, 'PF_global', []), objectiveDim), ...
            NormalizeReferenceBlock(GetStructField(referenceData, 'PF_local', []), objectiveDim));
    end

    if (isempty(pfture) || isempty(psture)) && exist('get_local_fun', 'file') == 2
        try
            [PS_global1, PS_global2, PS_local, PF_global, PF_local] = get_local_fun(name);
            if isempty(psture)
                psture = mergeReferenceBlocks(...
                    NormalizeReferenceBlock(PS_global1, decisionDim), ...
                    NormalizeReferenceBlock(PS_global2, decisionDim), ...
                    NormalizeReferenceBlock(PS_local, decisionDim));
            end
            if isempty(pfture)
                pfture = mergeReferenceBlocks(...
                    NormalizeReferenceBlock(PF_global, objectiveDim), ...
                    NormalizeReferenceBlock(PF_local, objectiveDim));
            end
        catch
        end
    end
end

function referenceData = LocalLoadReferenceData(name, suite)
    if nargin < 2 || isempty(suite)
        suite = 'auto';
    end

    candidateDirs = { ...
        fullfile(pwd, 'reference_data'), ...
        fullfile(pwd, 'ReferenceData'), ...
        fullfile(pwd, 'compare_results'), ...
        fullfile(pwd, 'MM_testfunctions'), ...
        fullfile(pwd, 'IDMP_testfunctions')};

    switch lower(suite)
        case 'cec2020'
            candidateDirs = [candidateDirs, { ...
                fullfile(pwd, 'MM_testfunctions', 'CEC2020'), ...
                fullfile(pwd, 'CEC2020')}]; %#ok<AGROW>
        case 'idmp'
            candidateDirs = [candidateDirs, { ...
                fullfile(pwd, 'IDMP_testfunctions', 'IDMP'), ...
                fullfile(pwd, 'IDMP')}]; %#ok<AGROW>
        case 'idmp_e'
            candidateDirs = [candidateDirs, { ...
                fullfile(pwd, 'IDMP_testfunctions', 'IDMP_e'), ...
                fullfile(pwd, 'IDMP_e')}]; %#ok<AGROW>
    end

    candidateFiles = {};
    for i = 1:numel(candidateDirs)
        candidateFiles{end + 1} = fullfile(candidateDirs{i}, [name, '.mat']); %#ok<AGROW>
        candidateFiles{end + 1} = fullfile(candidateDirs{i}, 'PF_PS', [name, '.mat']); %#ok<AGROW>
        candidateFiles{end + 1} = fullfile(candidateDirs{i}, 'truePF', [name, '.mat']); %#ok<AGROW>
        candidateFiles{end + 1} = fullfile(candidateDirs{i}, suite, [name, '.mat']); %#ok<AGROW>
    end

    loaded = [];
    for i = 1:numel(candidateFiles)
        if exist(candidateFiles{i}, 'file') == 2
            loaded = load(candidateFiles{i});
            break;
        end
    end

    referenceData = struct( ...
        'PF_global', [], ...
        'PF_local', [], ...
        'PS_global1', [], ...
        'PS_global2', [], ...
        'PS_local', []);

    if isempty(loaded)
        return;
    end

    standardFields = fieldnames(referenceData);
    for i = 1:numel(standardFields)
        if isfield(loaded, standardFields{i})
            referenceData.(standardFields{i}) = loaded.(standardFields{i});
        end
    end

    if isfield(loaded, 'referenceData') && isstruct(loaded.referenceData)
        nestedFields = fieldnames(referenceData);
        for i = 1:numel(nestedFields)
            if isfield(loaded.referenceData, nestedFields{i})
                referenceData.(nestedFields{i}) = loaded.referenceData.(nestedFields{i});
            end
        end
    end
end

function metric = ComputeMetrics(TraPop, pfture, psture)
    metric = struct('IGD', nan, 'HV', nan, 'IGDx', nan, 'rPSP', nan);

    if ~isempty(pfture)
        if exist('IGD_calculation', 'file') == 2
            metric.IGD = IGD_calculation(TraPop.F, pfture);
        else
            metric.IGD = LocalIGD(TraPop.F, pfture);
        end

        if exist('HV_calculation', 'file') == 2
            try
                [metric.HV, ~] = HV_calculation(TraPop.F, pfture);
            catch
                hvResult = HV_calculation(TraPop.F, pfture);
                if iscell(hvResult)
                    metric.HV = hvResult{1};
                else
                    metric.HV = hvResult(1);
                end
            end
        else
            metric.HV = LocalHV(TraPop.F, pfture);
        end
    end

    if ~isempty(psture)
        if exist('IGDX_calculation', 'file') == 2
            metric.IGDx = IGDX_calculation(TraPop.X, psture);
        else
            metric.IGDx = LocalIGD(TraPop.X, psture);
        end

        if exist('CR_calculation', 'file') == 2
            CR = CR_calculation(TraPop.X, psture);
        else
            CR = LocalCR(TraPop.X, psture);
        end

        if ~isnan(metric.IGDx) && metric.IGDx ~= 0 && ~isnan(CR)
            PSP = CR / metric.IGDx;
            if PSP ~= 0
                metric.rPSP = 1 / PSP;
            end
        end
    end
end

function value = GetStructField(s, fieldName, defaultValue)
    if isstruct(s) && isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end

function value = LocalNanMean(x)
    x = x(~isnan(x));
    if isempty(x)
        value = nan;
    else
        value = mean(x);
    end
end

function value = LocalNanStd(x)
    x = x(~isnan(x));
    if isempty(x)
        value = nan;
    elseif numel(x) == 1
        value = 0;
    else
        value = std(x);
    end
end

function IterationPlotCallback(state, name)
    if exist('PlotPopulations', 'file') ~= 2
        return;
    end

    pop = struct('X', state.population.decs, 'F', state.population.objs);
    archive = struct('X', state.archive.decs, 'F', state.archive.objs);
    PlotPopulations(pop, archive, state.currentFE, state.maxFE, name, size(pop.X, 2));
    drawnow limitrate;
end

function block = NormalizeReferenceBlock(block, dimension)
    if isempty(block) || ~isnumeric(block)
        block = [];
        return;
    end

    if isempty(dimension)
        dimension = size(block, 2);
    end

    if size(block, 2) == dimension
        normalized = block;
    elseif mod(size(block, 2), dimension) == 0
        normalized = [];
        nGroups = size(block, 2) / dimension;
        for i = 1:nGroups
            cols = (i - 1) * dimension + (1:dimension);
            normalized = [normalized; block(:, cols)]; %#ok<AGROW>
        end
    else
        normalized = block;
    end

    mask = all(isfinite(normalized), 2);
    block = normalized(mask, :);
end

function value = LocalIGD(population, reference)
    if isempty(population) || isempty(reference)
        value = nan;
        return;
    end
    distances = PairwiseDistances(reference, population);
    value = mean(min(distances, [], 2));
end

function value = LocalCR(population, reference)
    if isempty(population) || isempty(reference)
        value = nan;
        return;
    end
    refRange = max(reference, [], 1) - min(reference, [], 1);
    tol = 0.01 * norm(refRange(refRange > 0));
    if isempty(tol) || tol == 0
        tol = 1e-3;
    end
    distances = PairwiseDistances(reference, population);
    value = sum(min(distances, [], 2) <= tol) / size(reference, 1);
end

function value = LocalHV(population, reference)
    if isempty(population)
        value = nan;
        return;
    end

    frontNo = NDSort(population, size(population, 1));
    population = population(frontNo == 1, :);
    M = size(population, 2);
    refPoint = max([population; reference], [], 1);
    lowPoint = min([population; reference], [], 1);
    span = refPoint - lowPoint;
    span(span == 0) = 1;
    refPoint = refPoint + 0.1 * span;

    if M == 2
        population = sortrows(population, 1);
        bestY = refPoint(2);
        value = 0;
        for i = 1:size(population, 1)
            if population(i, 2) < bestY
                value = value + (refPoint(1) - population(i, 1)) * (bestY - population(i, 2));
                bestY = population(i, 2);
            end
        end
    else
        value = MonteCarloHV(population, refPoint, lowPoint);
    end
end

function value = MonteCarloHV(population, refPoint, lowPoint)
    sampleCount = 20000;
    s = rng;
    rng(1, 'twister');
    samples = rand(sampleCount, numel(refPoint)) .* repmat(refPoint - lowPoint, sampleCount, 1) + repmat(lowPoint, sampleCount, 1);
    rng(s);
    dominated = false(sampleCount, 1);
    for i = 1:size(population, 1)
        dominated = dominated | all(samples >= population(i, :), 2);
    end
    value = prod(refPoint - lowPoint) * mean(dominated);
end

function distances = PairwiseDistances(A, B)
    AA = sum(A .^ 2, 2);
    BB = sum(B .^ 2, 2).';
    distances = sqrt(max(AA + BB - 2 * (A * B.'), 0));
end
