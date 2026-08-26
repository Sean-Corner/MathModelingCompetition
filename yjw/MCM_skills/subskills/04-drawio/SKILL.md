---
name: 04-drawio
description: "数学建模非数据型图示绘制阶段。根据 ANALYSIS_MODELING_REPORT.md、RESULTS_REPORT.md 和已有 figures/ 生成论文级技术路线图、子问题求解流程图、模型结构图、数据处理流程图等 DrawIO 图，并导出论文可引用 PNG。"
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Agent, WebSearch, WebFetch
---

# DrawIO 非数据图示绘制

本 skill 承接 `03-coding`。它只负责论文中的**非数据型图示（论文级成品）**，例如技术路线图、求解流程图、模型结构图、数据处理流程图、变量关系图、指标体系图等。
本 skill 生成的示意图即为论文级成品，直接供 `05-writing` 引用，后续不再二次重画。

## 数学建模规范参考

如需领域判断，读取 `../../references/math_modeling_norms.md` 中的“图表与可视化”和“非数据图工具选择”小节。该文件只作为规范知识库，不要求为了凑数量生成额外图示。

## 阶段边界

- 本阶段负责：DrawIO 源文件、非数据图 PNG、图示生成记录。
- 本阶段不负责：折线图、柱状图、散点图、热力图、箱线图、雷达图等数据图。这些由 `03-coding` 生成。
- 本阶段不重跑模型、不修改 `code/`，不改写 `reports/RESULTS_REPORT.md` 的数值结论。

## 必须产出

在当前工作目录创建或更新：

```text
figures/
  fig_roadmap.drawio
  fig_roadmap.png
  fig_flow_q1.drawio
  fig_flow_q1.png
  ...
reports/DRAWIO_REPORT.md
```

如果某类图不需要生成，必须在 `reports/DRAWIO_REPORT.md` 中说明原因。竞赛论文通常至少需要一张 `fig_roadmap` 技术路线图。

读取这些文件的目的不是提取数据作图，而是理解论文方法、章节结构、子问题关系和已有图表，避免重复。

## 工作流程

### Step 1: 盘点已有图表和需求

先读取以下文件（存在则读取）：`reports/ANALYSIS_MODELING_REPORT.md`、`reports/RESULTS_REPORT.md`、`figures/` 目录列表。

然后从前序文档提取非数据图需求，输出一个清单：

```text
DRAWIO PLAN CHECKLIST:
[ ] fig_roadmap      技术路线图，放在问题重述/绪论
[ ] fig_flow_q1      问题一求解流程图
[ ] fig_flow_q2      问题二求解流程图
[ ] fig_flow_q3      问题三求解流程图
[ ] fig_pipeline     数据处理流程图
[ ] fig_model        模型结构/变量关系图
```

清单不是固定模板，要根据题目实际删减或增补。不要为了凑图生成无意义图示。

### Step 2: 判定图类型

常见图示选择：

| 图类型 | 文件名建议 | 适用场景 |
| --- | --- | --- |
| 技术路线图 | `fig_roadmap` | 展示整体解题路线、章节逻辑、方法串联 |
| 子问题求解流程图 | `fig_flow_q1`, `fig_flow_q2` | 展示单个子问题的输入、判断、算法、输出 |
| 数据处理流程图 | `fig_pipeline` | 展示数据清洗、特征构造、建模输入 |
| 模型结构图 | `fig_model` | 展示模块关系、变量关系、模型层次 |
| 指标体系图 | `fig_index_system` | 展示目标层、准则层、指标层 |
| 决策树/规则图 | `fig_decision_tree` | 展示分类规则、设备选择、策略分支 |

不要用 DrawIO 画这些图：

- 结果对比柱状图
- 预测误差曲线
- 灵敏度曲线
- 相关性热力图
- 分布图和箱线图

### Step 3: 用 scibox-diagram 绘制

所有示意图统一使用本目录下的 `scibox-diagram/` 框架绘制（`.drawio` 源文件为最终交付源，放在 `figures/`）。三选一路径：

- **套模板**：全文脉络/研究框架/执行流程/任务分解 → `roadmap-5band` / `framework-3col` / `stageflow-3col` / `taskflow-land`（复制 `scibox-diagram/assets/<id>/example.json` 改写后渲染）。
- **从零手写 XML**：算法流程/模型架构/实验设计/机制示意 → 照 `scibox-diagram/references/authoring.md` 手写。
- **高保真复刻**：给了参考图要照着重画 → 照 `scibox-diagram/references/replication.md` 执行。

渲染、校验与导出（Windows 下 `python3` 换 `python`）：

```bash
python scibox-diagram/scripts/roadmap_5band.py content.json -o figures/fig_roadmap.drawio   # 模板渲染
python scibox-diagram/scripts/check_layout.py figures/fig_roadmap.drawio --strict            # 版式门禁（应 FAIL 0 / WARN 0）
python scibox-diagram/scripts/export_figure.py figures/fig_roadmap.drawio                     # 导出 1:1 PNG + PDF（需 drawio 命令行）
python scibox-diagram/scripts/preview_html.py figures/fig_roadmap.drawio                      # 无 drawio 时的浏览器预览
```

模板语义约定、字数预算、图标、复刻闭环、九区盘点等详见 `scibox-diagram/SKILL.md` 与其 `references/`。

### Step 4: 自检

每张图必须检查（配合 `check_layout.py --strict`）：

- `.drawio` 文件非空；若导出成功，`.png` 文件非空。
- 打开 PNG 过目：文字溢出/压线、箭头方向与语义、同族元素对齐同宽、数值无抄错。
- 字号、颜色、边框风格一致。
- 文件名和图意一致。
- 没有与 `03-coding` 的数据图重复。

发现问题要修 `.drawio` 并重新导出，不要只在报告里解释。

### Step 5: 写生成记录

创建 `reports/DRAWIO_REPORT.md`，至少包含：

```markdown
# DrawIO 图示生成报告

## 图示清单
| 文件 | 类型 | 来源依据 | 用途 | 状态 |
| --- | --- | --- | --- | --- |

## 未生成图示及原因

## 导出与自检记录

## 给论文阶段的嵌入建议
```

嵌入建议只说明每张图适合放入哪个章节和建议 caption，不生成独立的图片引用文件。最终图片以 md 语法 `![](figures/...)` 插入，具体位置由 `05-writing` 根据论文结构决定。

## 质量要求

- 图示服务论文论证，不为装饰而画。
- 每张图必须能对应到`reports/ANALYSIS_MODELING_REPORT.md` 中的真实方法。
- 数据型图表不得在本阶段重复生成。
- 论文阶段引用的非数据图都应有 `.drawio` 源文件和 PNG，或者在 `reports/DRAWIO_REPORT.md` 说明导出失败。
