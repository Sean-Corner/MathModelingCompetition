---
name: math-modeling
description: "数学建模竞赛全流程 Skill。用于需要完成赛题分析、数学建模、代码求解、数据图、DrawIO 非数据图、论文撰写（md）、最终验证和提交检查的任务；触发 Math Modeling 后按内置子 skill 工作流编排执行。"
---

# Math Modeling

本 skill 是数学建模竞赛的顶层入口。它负责把多个子 skill 组织成一条完整工作流；执行具体阶段时，读取对应 `subskills/` 下的子 skill。

## 子 Skill 调用顺序

按顺序执行以下子 skill，并在每个阶段结束后更新项目 `todo.md`：

| 顺序 | 子 skill               | 用途 | 主要产物 |
| --- |------------------------|------|----------|
| 0 | `doctor`               | 手动触发的环境检查与安装向导。 | 依赖检查结果 |
| 1 | `01-start-mathmodel`   | 启动工作流，记录偏好，生成整体计划。 | `plan.md`, `todo.md` |
| 2 | `02-analysis-modeling` | 解析题目、拆解子问题、建立模型和求解方案。 | `reports/ANALYSIS_MODELING_REPORT.md` |
| 3 | `03-coding`            | 实现代码、运行实验、保存结果，并生成论文级数据图（matplotlib，可选 scibox-figure 模板）。 | `code/`, `results/`, `reports/RESULTS_REPORT.md`, `figures/*.png` |
| 4 | `04-drawio`            | 绘制论文级非数据示意图（按图型选择 DrawIO/TikZ/SVG 等工具）。 | `figures/*.png`, 对应源文件, `reports/DRAWIO_REPORT.md` |
| 5 | `05-writing`           | 撰写最终竞赛论文 md，引用 03/04 成品图。 | `paper/竞赛论文.md` |
| 6 | `06-verity`            | 验证最终论文、图表、数值、代码复现和提交状态。 | `reports/VERIFY_REPORT.md` |


## 工作流规则

- 先判断用户是否要完整流程，还是只要某个阶段；完整流程从 `01-start-mathmodel` 开始。
- 每个阶段只做本阶段职责，不提前写后续阶段产物。
- **单遍出图**：`03-coding` 与 `04-drawio` 直接产出论文级成品图（落在 `figures/`），后续不再二次重画，也没有独立的「图表升级」阶段。
- **时序约束**：图表必须在 `02-analysis-modeling` 建模、`03-coding` 算出结果之后生成，且在 `05-writing` 撰写正文之前完成；`05-writing` 只引用成品图。
- 论文中的数值结论必须来自 `reports/RESULTS_REPORT.md`、结果表或图表数据，不得在写作阶段重新编造。
- 验收阶段发现硬错误时，优先小范围修复；若需要重新建模或重跑实验，在 `reports/VERIFY_REPORT.md` 标记返回对应阶段。

## 资源导航

- 规范知识库：`references/math_modeling_norms.md`。子 skill 只在需要领域判断时读取相关小节。
- 子 skill 索引：`skills.sh.json`。它只作为结构化清单，不替代本入口文件。
- 图表模板库：`03-coding/scibox-figure/`（数据图模板库，用于 03 的 Step 4）；`04-drawio/scibox-diagram/`（DrawIO 示意图框架，用于 04 选择 DrawIO 路线时使用）。详细规约由各自 `SKILL.md` 提供。

## 默认项目产物结构

```text
.
├── plan.md
├── todo.md
├── reports/
│   ├── ANALYSIS_MODELING_REPORT.md
│   ├── RESULTS_REPORT.md
│   ├── DRAWIO_REPORT.md
│   └── VERIFY_REPORT.md
├── code/
├── results/
├── figures/                       # 03/04 论文级成品图（.png + 对应源文件）
└── paper/
    └── 竞赛论文.md                # 05 输出（最终论文 md，仅 md）
```
