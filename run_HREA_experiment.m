function results = run_HREA_experiment(name, num_of_runs)
%RUN_HREA_EXPERIMENT Benchmark driver that wraps HREA in the provided workflow.
%   results = run_HREA_experiment(name, num_of_runs)
%
%   This function integrates the user-provided experiment script, including
%   benchmark-path setup, repeated runs, indicator calculation, result
%   saving, and optional plotting.

    if nargin < 1 || isempty(name)
        name = 'MMF1';
    end
    if nargin < 2 || isempty(num_of_runs)
        num_of_runs = 2;
    end

    addpath(genpath('MM_testfunctions/'));
    addpath(genpath('IDMP_testfunctions/'));
    addpath(genpath('Indicator_calculation/'));
    addpath(genpath('fun_plot'));

    clc;
    close all;

    problem = objective_description_function(name);
    fprintf('Running test function: %s\n', name);

    opts = struct();
    opts.N = 200 * problem.N_ops;
    opts.FEmax = 10000 * problem.N_ops;

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

    [PS_global, PS_local, PF_global, PF_local] = get_local_fun(name);
    psture = [PS_global; PS_local];
    pfture = [PF_global; PF_local];

    IGDX_all = zeros(num_of_runs, 1);
    IGD_all = zeros(num_of_runs, 1);
    HV_all = zeros(num_of_runs, 1);
    rPSP_all = zeros(num_of_runs, 1);

    static_metric(num_of_runs, 1) = struct('IGD', [], 'HV', [], 'IGDx', [], 'rPSP', []);
    IGD_hist_all = cell(num_of_runs, 1);
    IGDX_hist_all = cell(num_of_runs, 1);
    FE_hist_all = cell(num_of_runs, 1);
    gen_hist_all = cell(num_of_runs, 1);

    for runs = 1:num_of_runs
        fprintf('总循环次数: %d / %d\n', runs, num_of_runs);

        [DifPop, TraPop, out] = HREA(problem, opts, name); %#ok<ASGLU>

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

        metric.IGD = IGD_calculation(TraPop.F, pfture);
        [metric.HV, ~] = HV_calculation(TraPop.F, pfture);
        metric.IGDx = IGDX_calculation(TraPop.X, psture);

        CR = CR_calculation(TraPop.X, psture);
        PSP = CR / metric.IGDx;
        metric.rPSP = 1 / PSP;

        IGDX_all(runs) = metric.IGDx;
        IGD_all(runs) = metric.IGD;
        HV_all(runs) = metric.HV;
        rPSP_all(runs) = metric.rPSP;
        static_metric(runs, 1) = metric;
    end

    results.IGDX_all = IGDX_all;
    results.IGD_all = IGD_all;
    results.HV_all = HV_all;
    results.rPSP_all = rPSP_all;
    results.static_metric = static_metric;
    results.IGD_hist_all = IGD_hist_all;
    results.IGDX_hist_all = IGDX_hist_all;
    results.FE_hist_all = FE_hist_all;
    results.gen_hist_all = gen_hist_all;

    results.IGDX_mean = mean(IGDX_all);
    results.IGDX_std = std(IGDX_all);
    results.IGD_mean = mean(IGD_all);
    results.IGD_std = std(IGD_all);
    results.HV_mean = mean(HV_all);
    results.HV_std = std(HV_all);
    results.rPSP_mean = mean(rPSP_all);
    results.rPSP_std = std(rPSP_all);

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
