---
name: math-modeling
description: "数学建模竞赛全流程 Skill。用于需要完成赛题分析、数学建模、代码求解、草稿数据图、DrawIO 非数据图、论文撰写（md/Word）、可选 AntV 高保真图表升级、最终验证和提交检查的任务；触发 Math Modeling 后按内置子 skill 工作流编排执行。"
---

# Math Modeling

本 skill 是数学建模竞赛的顶层入口。它负责把多个子 skill 组织成一条完整工作流；执行具体阶段时，读取对应 `subskills/` 下的子 skill。

## 子 Skill 调用顺序

按顺序执行以下子 skill，并在每个阶段结束后更新项目 `todo.md`：

| 顺序 | 子 skill                | 用途                                                                                                                                      | 主要产物                                                          |
| --- |-------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| 0 | `doctor`                | 手动触发的环境检查与安装向导。                                                                                                            | 依赖检查结果                                                      |
| 1 | `01-start-mathmodel`    | 启动工作流，记录偏好，生成整体计划。                                                                                                      | `plan.md`, `todo.md`                                              |
| 2 | `02-analysis-modeling`  | 解析题目、拆解子问题、建立模型和求解方案。                                                                                                | `reports/ANALYSIS_MODELING_REPORT.md`                             |
| 3 | `03-coding`             | 实现代码、运行实验、保存结果，并生成**草稿版**数据图（matplotlib / seaborn 等探索用图）。                                                 | `code/`, `results/`, `reports/RESULTS_REPORT.md`, `figures/*.png` |
| 4 | `04-drawio`             | 绘制技术路线图、流程图、模型结构图等非数据图的草稿。                                                                                      | `figures/*.drawio`, `figures/*.png`, `reports/DRAWIO_REPORT.md`   |
| 5 | `05-writing`            | 撰写竞赛论文**草稿**，引用 03/04 草稿图。                                                                                                 | `paper/竞赛论文(草稿).md`                                         |
| 6 | `06-verity`             | 验证**草稿版**论文、图表、数值、代码复现和提交状态。                                                                                      | `reports/VERIFY_REPORT.md`                                        |
| 7 | `07-graph-optimization` | 图表升级，把前序子skill生成的草稿图升级为论文级高质量版本（统计图 / 网络图 / 流程图 / 表格 全栈），将图插入论文正文并导出成论文word文件。 | `paper/竞赛论文.docx`                                             |


## 工作流规则

- 先判断用户是否要完整流程，还是只要某个阶段；完整流程从 `01-start-mathmodel` 开始。
- 每个阶段只做本阶段职责，不提前写后续阶段产物。
- **双轨图表**：`03-coding` 与 `04-drawio` 只负责**草稿图**（落在 `figures/`）；论文级高保真图表由 `07-graph-optimization` 重新生成（落在 `figures/antv/`），**不在 03/04 阶段提前出成品**。
- 论文中的数值结论必须来自 `reports/RESULTS_REPORT.md`、结果表或图表数据，不得在写作阶段重新编造。
- 验收阶段发现硬错误时，优先小范围修复；若需要重新建模或重跑实验，在 `reports/VERIFY_REPORT.md` 标记返回对应阶段；如仅是图表美观度问题，可在 `07-graph-optimization` 内修复，不必回退到 03/04。

## 资源导航

- 规范知识库：`references/math_modeling_norms.md`。子 skill 只在需要领域判断时读取相关小节。
- 子 skill 索引：`skills.sh.json`。它只作为结构化清单，不替代本入口文件。
- AntV 子 skill 入口：位于`07-graph-optimization`目录下， 按图表类型路由到 `antv-g2-chart` / `antv-g6-graph` / `antv-x6-editor` / `antv-s2-expert`；每个 antv 子 skill 的详细规约、配色规范、模板由它们各自的 `SKILL.md` 提供。

## 默认项目产物结构

```text
.
├── plan.md
├── todo.md
├── reports/
│   ├── ANALYSIS_MODELING_REPORT.md
│   ├── RESULTS_REPORT.md
│   ├── DRAWIO_REPORT.md
│   ├── VERIFY_REPORT.md
│   └── ANTV_REPORT.md
├── code/
├── results/
├── figures/                       # 03/04 草稿图
│   └── antv/                      # 07 AntV 高质量图
└── paper/
    ├── 竞赛论文(草稿).md          # 05 输出（md 正文）
    ├── 竞赛论文.md                # 07 输出（更新图表后的 md 终稿）
    └── 竞赛论文.docx              # 07 输出（Word 终稿）
```
