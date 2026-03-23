# MMOEA-DC（HREA 风格 MATLAB 版本）

本仓库提供了一个**不依赖 PlatEMO** 的 MMOEA-DC（Decision-space Crowding based Multi-Objective Evolutionary Algorithm）MATLAB 实现，并将实验入口改成了与 HREA 相同的批量测试模式，便于直接调用：

- `CEC2020`
- `IDMP`
- `IDMP_e`

## 文件说明

- `MMOEADC.m`：算法主入口，执行 MMOEA-DC 进化流程，并输出种群、前沿编号、FE 历史和代数历史。
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
- `MMEA_BDC.m`：把外部 benchmark 问题结构转换为 `MMOEADC` 所需格式。
- `run_HREA_experiment.m`：HREA 风格实验驱动入口，支持 `CEC2020`、`IDMP`、`IDMP_e`。
- `loadReferenceData.m`：按 suite 和常见目录规则加载参考 PF/PS 数据。
  - `run_HREA_experiment.m` 现在优先使用内部参考数据加载逻辑，避免 MATLAB 路径上同名函数的参数签名冲突导致“输入参数太多”。
- `mergeReferenceBlocks.m`：合并参考数据块。
- `demo_MMOEADC_HREA_mode.m`：HREA 风格运行示例。
- `get_local_fun.m`：生成 PS / PF 参考曲线或曲面。
- `PlotPopulations.m`：按参考 PS / PF 绘制决策空间和目标空间图像。

## 推荐入口

### 1）直接按 HREA 风格跑实验

```matlab
results = run_HREA_experiment('IDMPM2T4_e', 1, 'IDMP_e');
results = run_HREA_experiment('IDMPM2T4',   1, 'IDMP');
results = run_HREA_experiment('CEC2020_F01', 1, 'CEC2020');
```

如果第三个参数 `suite` 不传，程序会根据名字自动推断：

```matlab
results = run_HREA_experiment('IDMPM2T4_e', 1);
```

### 2）使用 demo 入口

```matlab
demo_MMOEADC_HREA_mode('IDMP_e', 'IDMPM2T4_e', 1);
demo_MMOEADC_HREA_mode('IDMP',   'IDMPM2T4',   1);
demo_MMOEADC_HREA_mode('CEC2020','CEC2020_F01',1);
```

## 运行依赖

为了真正运行 `CEC2020 / IDMP / IDMP_e` 测试函数，需要你的工程目录中存在以下 HREA 风格依赖：

- `objective_description_function.m`
- 对应测试函数目录，例如 `MM_testfunctions/`、`IDMP_testfunctions/`
- 指标计算目录，例如 `Indicator_calculation/`
- 可选绘图目录，例如 `fun_plot/`
- 可选参考 PF / PS 数据文件
- 即使缺少外部 `Indicator_calculation/` 指标函数或 `.mat` 参考数据，程序也会优先尝试使用 `get_local_fun.m` 生成参考集，并用内置 MATLAB 版本的 IGD / IGDX / HV / CR 计算逻辑回退计算指标。

## 绘图支持

运行 `run_HREA_experiment` 时，若 `opts.enablePlot = true` 且基准名称被 `get_local_fun.m` 支持，则会在**迭代过程中**通过 `PlotFcn` 回调自动调用 `PlotPopulations.m`，实时绘制当前种群与参考 PS / PF 的对比图。

## 输出结果

运行 `run_HREA_experiment` 后，结果会保存到：

```matlab
compare_results/<suite>/MMOEADC_<problem_name>_metrics_all_runs.mat
```

并返回 `results` 结构体，其中包含：

- `IGDX_all`, `IGD_all`, `HV_all`, `rPSP_all`
- `IGD_hist_all`, `IGDX_hist_all`, `FE_hist_all`, `gen_hist_all`
- `IGDX_mean/std`, `IGD_mean/std`, `HV_mean/std`, `rPSP_mean/std`
- `suite`, `problem_name`, `options`
