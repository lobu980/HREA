function results = run_HREA_experiment(name, num_of_runs)
%RUN_HREA_EXPERIMENT Benchmark driver that wraps MMOEA-DC/HREA workflow.
%   RESULTS = RUN_HREA_EXPERIMENT(NAME, NUM_OF_RUNS) integrates the
%   user-provided experiment procedure, including benchmark path setup,
%   repeated execution, indicator calculation, result saving, and optional
%   plotting, while dispatching the optimization core to MMEA_BDC/MMOEADC.

    if nargin < 1 || isempty(name)
        name = 'IDMPM2T4_e';
    end
    if nargin < 2 || isempty(num_of_runs)
        num_of_runs = 1;
    end

    AddExistingPath('MM_testfunctions');
    AddExistingPath('IDMP_testfunctions');
    AddExistingPath('Indicator_calculation');
    AddExistingPath('fun_plot');

    clc;
    close all;

    problem = ResolveBenchmarkProblem(name);
    fprintf('Running test function: %s\n', name);

    opts = BuildDefaultOptions(problem);
    [pfture, psture] = ResolveReferenceSets(name);

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

    fprintf('\n==================== %d 次运行结果汇总 ====================\n', num_of_runs);
    fprintf('IGDX 平均值: %.6e (标准差: %.4e)\n', results.IGDX_mean, results.IGDX_std);
    fprintf('IGD  平均值: %.6e (标准差: %.6e)\n', results.IGD_mean, results.IGD_std);
    fprintf('HV   平均值: %.6e (标准差: %.6e)\n', results.HV_mean, results.HV_std);
    fprintf('DPSP 平均值: %.6e (标准差: %.6e)\n', results.rPSP_mean, results.rPSP_std);

    algTag = 'HREA';
    resultDir = fullfile(pwd, 'compare_results');
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
        'IGDX_all', 'IGD_all', 'HV_all', 'rPSP_all', ...
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

function AddExistingPath(folderName)
    if exist(folderName, 'dir') == 7
        addpath(genpath(folderName));
    end
end

function problem = ResolveBenchmarkProblem(name)
    if exist('objective_description_function', 'file') == 2
        problem = objective_description_function(name);
    else
        error('run_HREA_experiment:MissingDependency', ...
            'objective_description_function.m was not found on the MATLAB path.');
    end
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

function [pfture, psture] = ResolveReferenceSets(name)
    pfture = [];
    psture = [];

    if exist('loadReferenceData', 'file') == 2
        referenceData = loadReferenceData(name);
    else
        referenceData = struct();
    end

    if ~isempty(referenceData)
        psture = mergeReferenceBlocks(...
            GetStructField(referenceData, 'PS_global1', []), ...
            GetStructField(referenceData, 'PS_global2', []), ...
            GetStructField(referenceData, 'PS_local', []));
        pfture = mergeReferenceBlocks(...
            GetStructField(referenceData, 'PF_global', []), ...
            GetStructField(referenceData, 'PF_local', []));
    end
end

function metric = ComputeMetrics(TraPop, pfture, psture)
    metric = struct('IGD', nan, 'HV', nan, 'IGDx', nan, 'rPSP', nan);

    if ~isempty(pfture) && exist('IGD_calculation', 'file') == 2
        metric.IGD = IGD_calculation(TraPop.F, pfture);
    end
    if ~isempty(pfture) && exist('HV_calculation', 'file') == 2
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
    end
    if ~isempty(psture) && exist('IGDX_calculation', 'file') == 2
        metric.IGDx = IGDX_calculation(TraPop.X, psture);
    end
    if ~isempty(psture) && exist('CR_calculation', 'file') == 2 && ~isnan(metric.IGDx) && metric.IGDx ~= 0
        CR = CR_calculation(TraPop.X, psture);
        PSP = CR / metric.IGDx;
        if PSP ~= 0
            metric.rPSP = 1 / PSP;
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
