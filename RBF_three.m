function [TraPop, out] = RBF_three(problem, opts, name, psture, pfture)
% 流程：真实初始化/环境选择 -> 初始训练；每代：
% RBF预测当前X，同时调用逆GP预测X -> 用预测目标辅助交配选择
% -> GA生成子代 -> 真实评价 -> 真实目标环境选择
% -> 用全部选择后X/真实F重训RBF和逆GP。
% 本文件只负责调用RBF、逆GP和GA模块，不包含这些模块的子程序。
% 假设静态、确定性目标函数：父代真实F可复用，不需要重复评价父代。

%% 参数
opts = bdc_default_opts(problem, opts);
N = opts.N;
FEmax = opts.FEmax;
goal = 1e-5;
spread = 0.8;
maxNeurons = 100;
rbfShowPlot = false;

%% 真实初始化及初始化环境选择
TraPop = bdc_init_pop(problem,N);
P = [];
TraPop = EnvironmentalSelection(TraPop,P,P,N,opts);
% 保留原计数。若 bdc_init_pop 实际仅评价 N 个解，应将 2*N 改为 N。
FE = 2*N;
gen = 0;
assert(size(TraPop.X,1)==N && size(TraPop.F,1)==N, ...
    '初始化环境选择后的 X/F 行数必须为 N。');

out = struct();
out.IGD_hist = [];
out.IGDX_hist = [];
out.FE_hist = [];
out.gen_hist = [];
out.FE = FE;
out.gen = gen;
out.RBF_gen_hist = [];
out.RBF_used_hist = [];
out.RBF_RMSE_train_hist = [];
out.RBF_MAE_train_hist = [];
out.RBF_R2_train_hist = [];
out.RBF_bias_train_hist = [];
% 当前父代也用于上一轮训练，下面这一项不是独立测试误差。
out.RBF_parent_RMSE_hist = [];
out.InvGP_gen_hist = [];
out.InvGP_used_hist = [];

if nargin >= 5
    out.IGD_hist(end+1,1) = IGD_calculation(TraPop.F,pfture);
    out.IGDX_hist(end+1,1) = IGDX_calculation(TraPop.X,psture);
    out.FE_hist(end+1,1) = FE;
    out.gen_hist(end+1,1) = gen;
end

%% 首次训练：为第一代的“先预测”提供模型
out.RBF = RBF_train(TraPop.X,TraPop.F, ...
    goal,spread,maxNeurons,gen,rbfShowPlot);
% 逆GP以目标F为输入、决策变量X为输出；具体实现由外部模块提供。
out.InvGP = InvGP_train(TraPop.F,TraPop.X,gen);

%% 主循环：预测、遗传算法、训练依次独立调用
while FE < FEmax
    gen = gen+1;
    opts.FE = FE;

    %% 1. 预测模块：RBF预测目标，逆GP反向预测决策变量
    X_for_prediction = TraPop.X;
    parentPredF = RBF_predict(X_for_prediction,out.RBF);
    inversePredX = InvGP_predict(parentPredF,out.InvGP);
    % 两类预测结果单独保存，绝不写回TraPop；TraPop.X/F始终为真实值。
    parentRMSE = sqrt(mean((parentPredF-TraPop.F).^2,1));
    rbfModelGen = out.RBF.gen;
    % 当前模型在上一轮训练完成，因此其训练代数为gen-1。
    % 不要求外部InvGP_train返回带gen字段的特定结构体。
    invGPModelGen = gen-1;

    %% 2. GA模块：预测目标指导交配，真实目标执行环境选择
    nOffspring = min(N,floor(FEmax-FE));
    assert(nOffspring>=1, '剩余预算不足一次真实评价，请使用整数 FEmax。');
    [TraPop,step] = GA(TraPop,parentPredF,problem,opts,N,nOffspring);
    FE = FE+step.nEvaluated;

    % 记录两类预测及其所用模型代数，便于核对。
    out.Prediction.gen = gen;
    out.Prediction.modelGen = rbfModelGen;
    out.Prediction.X = X_for_prediction;
    out.Prediction.Fpred = parentPredF;
    out.InversePrediction.gen = gen;
    out.InversePrediction.modelGen = invGPModelGen;
    out.InversePrediction.F = parentPredF;
    out.InversePrediction.Xpred = inversePredX;
    out.GA = step;
    out.RBF_used_hist(end+1,1) = true;
    out.RBF_parent_RMSE_hist(end+1,:) = parentRMSE;
    out.InvGP_used_hist(end+1,1) = true;

    %% 3. 训练模块：全部选择后的真实X/F重新训练RBF和逆GP
    out.RBF = RBF_train(TraPop.X,TraPop.F, ...
        goal,spread,maxNeurons,gen,rbfShowPlot);
    out.InvGP = InvGP_train(TraPop.F,TraPop.X,gen);
    out.RBF_gen_hist(end+1,1) = gen;
    out.InvGP_gen_hist(end+1,1) = gen;
    out.RBF_RMSE_train_hist(end+1,:) = out.RBF.rmse_train';
    out.RBF_MAE_train_hist(end+1,:) = out.RBF.mae_train';
    out.RBF_R2_train_hist(end+1,:) = out.RBF.r2_train';
    out.RBF_bias_train_hist(end+1,:) = out.RBF.bias_train';

    %% 4. 真实目标下的性能评价与记录
    PlotPopulations(TraPop,name,problem.D);
    out.FE(end+1,1) = FE;
    out.gen(end+1,1) = gen;
    if nargin >= 5
        out.IGD_hist(end+1,1) = IGD_calculation(TraPop.F,pfture);
        out.IGDX_hist(end+1,1) = IGDX_calculation(TraPop.X,psture);
        out.FE_hist(end+1,1) = FE;
        out.gen_hist(end+1,1) = gen;
    end
end
out.finalFE = FE;
out.finalGen = gen;
out.stopReason = '达到函数评价预算';
end
