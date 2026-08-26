---
name: mathmodel-figure-templates
description: 数学建模工作流 03-coding 图表子任务（Step 4）的可选数据图模板库，基于 Python + Matplotlib 的科研绘图模板集合。当需要复现内置科研绘图模板（SHAP 蜂群柱状图、配对云雨图、交叉验证 ROC、泰勒图、相关矩阵组合图、预测真实值边缘分布图、TPE 调参 3D 曲面、下三角相关矩阵半边小提琴图、分组环形热图、城市公园降温组合图、Nature 和弦图）时使用，提供可直接运行的 Python 脚本。
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob
---

# 科研绘图模板（Matplotlib）

本 skill 位于 `subskills/03-coding/scibox-figure/`，内置可直接运行的 Python/Matplotlib 脚本，用于复现数学建模论文中常用的科研图表模板。

## 快速路径

1. 在 `references/figure-catalog.md` 中匹配所需图表。
2. 在竞赛项目根目录下，用本 skill 的渲染器按模板 id 运行：

```bash
python subskills/03-coding/scibox-figure/scripts/render_template.py paired-raincloud
```

3. 渲染器把内置模板脚本复制到 `绘图复刻/scripts/`，在该目录运行，输出写到 `绘图复刻/outputs/`。
4. 把生成的 PNG/PDF/SVG 路径与复制的脚本路径返回给 03-coding 主流程（落盘到 `figures/`）。

用 `--list` 查看支持的 id：

```bash
python subskills/03-coding/scibox-figure/scripts/render_template.py --list
```

可用 `--project <目录>` 覆盖输出目录（例如 `--project figures`）。

## 输出约定

- 在当前竞赛项目目录下工作，除非用户指定其它路径。
- 默认项目目录：`绘图复刻`。
- 脚本路径：`绘图复刻/scripts/make_<template>.py`。
- 输出：`绘图复刻/outputs/<template>_replica.png`、`.pdf`、`.svg`。
- 优先使用内置脚本；仅当用户要求定制时才编辑复制到工作目录的脚本。
- 内置脚本使用确定性的模拟数据。不要声称模拟值精确复现了某篇源论文。

## 模板 id

- `multiclass-shap-combo`
- `paired-raincloud`
- `cv-roc-ci`
- `taylor-diagram`
- `correlation-pairgrid`
- `prediction-marginal-grid`
- `rf-tpe-surface`
- `grouped-corr-split-violin`
- `grouped-circular-heatmap`
- `urban-park-cooling-combo`
- `nature-chord-diagram`

## 定制时

如果用户要求修改，先复制/运行最近的模板，再编辑 `绘图复刻/scripts/` 中复制的脚本。保留：

- 导入 matplotlib 前设置 `MPLCONFIGDIR`。
- 模拟数据的确定性随机种子。
- PNG/PDF/SVG 导出。
- 可读的标签、图例与高 DPI 输出。

实现模式见 `references/plot-recipes.md`。
