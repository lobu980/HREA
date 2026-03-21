# MMOEA-DC（独立 MATLAB 版本）

本仓库提供了一个**不依赖 PlatEMO** 的 MMOEA-DC（Decision-space Crowding based Multi-Objective Evolutionary Algorithm）独立 MATLAB 实现。

## 文件说明

- `MMOEADC.m`：算法主入口。
- `Initialization.m`：种群初始化。
- `Variation.m`：模拟二进制交叉（SBX）与多项式变异。
- `TournamentSelection.m`：锦标赛选择。
- `Environmental_Selection_C.m`：环境选择核心过程。
- `Environmental_Selection.m`：兼容包装函数。
- `NCM.m`：邻域聚类方法。
- `Crowding.m`：决策空间拥挤距离。
- `NDSort.m`：非支配排序。
- `Dominates.m`：Pareto 支配判定。
- `HierarchicalClusteringWard.m`：纯 MATLAB 的 Ward 层次聚类。
- `MMEA_BDC.m`：外部问题结构到 `MMOEADC` 的适配器。
- `run_HREA_experiment.m`：整合实验驱动、指标统计、保存结果与绘图。
- `loadReferenceData.m`：加载参考 PF/PS 数据。
- `mergeReferenceBlocks.m`：合并参考数据块。
- `ZDT1_Problem.m`：示例测试问题。
- `demo_MMOEADC_ZDT1.m`：演示脚本。

## 基本用法

```matlab
problem = ZDT1_Problem(30);
options = struct('N',100,'MaxGen',200,'delta',5,'seed',1);
result = MMOEADC(problem, options);
scatter(result.population.objs(:,1), result.population.objs(:,2), 25, 'filled');
```

## 自定义问题接口

需要构造一个 `Problem` 结构体，包含以下字段：

```matlab
Problem.D = 30;
Problem.M = 2;
Problem.lower = zeros(1,30);
Problem.upper = ones(1,30);
Problem.evaluate = @(decs) myObjective(decs);
```

其中 `decs` 为 `N x D` 决策变量矩阵，返回值必须是 `N x M` 的目标矩阵。


## HREA/MMOEA-DC 实验主程序

如果你的工程里已经包含 `objective_description_function.m`、指标计算函数、参考 PF/PS 数据以及绘图函数，可以直接运行：

```matlab
results = run_HREA_experiment('IDMPM2T4_e', 1);
```

新增文件说明：

- `MMEA_BDC.m`：将外部问题结构适配到 `MMOEADC` 主程序。
- `run_HREA_experiment.m`：整合你提供的批量实验、指标统计、保存结果、绘图调用流程。
- `loadReferenceData.m`：按常见目录约定加载参考 PF/PS 数据。
- `mergeReferenceBlocks.m`：合并 `PF/PS` 分块数据。
