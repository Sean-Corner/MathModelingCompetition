---
name: 07-graph-optimization
description: "数学建模工作流的图表升级节点。读取 03-coding-visual 与 04-drawio 的草稿图，按图表类型自动路由到 antv-g2-chart / antv-g6-graph / antv-x6-editor / antv-s2-expert，重新出论文级 PNG 高保真图表，并替换 paper/竞赛论文.md 中的图表引用。在 06-verity 通过后手动或自动触发，不重跑模型、不改数值。"
---

# 07-antv

本 skill 是数模工作流的**图表升级节点**，对应顶层 `SKILL.md` 中第 7 步。它把草稿图（`figures/*.png`、`figures/*.drawio`）重画成论文级高保真版本，统一收口到 `figures/antv/`，再回写终稿 `paper/竞赛论文.md`，并导出 `paper/竞赛论文.docx`。

**职责边界**：只换"皮"，不重算"数"，不修改已撰写好的论文正文。任何对数据/模型的修改都属于上游 02/03 步骤，07 不接受。

---

## 1. 何时触发

---本子skill为最后一个执行的子skill，前序子skill都已执行完毕后再执行。

## 2. 输入 / 输出

### 输入

| 来源 | 路径                                               | 用途                              |
| --- |----------------------------------------------------|-----------------------------------|
| 草稿数据图 | `figures/*.png` + 对应 `results/*.csv`（如可追溯） | 重新出统计图                      |
| 草稿非数据图 | `figures/*.drawio` 或等价 JSON 描述                | 重新出流程 / 架构图               |
| 数值结论 | `reports/RESULTS_REPORT.md`                        | 校验图表数据一致                  |
| 草稿论文 | `paper/竞赛论文(草稿).md`               | 供本子skill生成最终版论文word文件 |

### 输出

| 产物                  | 路径                     | 说明                                                          |
|-----------------------|--------------------------|---------------------------------------------------------------|
| AntV 高质量论文级别图 | `figures/antv/*.png`     | 终稿用图，300 DPI                                             |
| AntV 工作日志         | `reports/ANTV_REPORT.md` | 每张图的输入数据、模板、配色、ANTV 子 skill 名                |
| 终稿论文              | `paper/竞赛论文.docx`    | 将本skill生成的高质量论文级图插入论文正文后导出的论文word文件 |

---

## 3. AntV 路由表

按**图表形态**自动选 antv 子 skill。每个 07-antv 调用都必须先回答"这是哪种图"，再查表选子 skill。**不要凭感觉选**——上游子 skill 的 SKILL.md 里写了它支持哪些 mark / layout，按表选能避免幻觉。
所有AntV 子 skill都在本子skill所属的目录下。
### 3.1 主路由表

| 图表形态 | AntV 子 skill | mark / layout | 典型场景 |
| --- | --- | --- | --- |
| 柱状图（基础 / 堆叠 / 分组 / 百分比 / 水平） | `antv-g2-chart` | `interval` (+ `stackY` / `dodgeX` / `transpose`) | 分类对比、Top-N、构成 |
| 折线图（基础 / 多系列 / 平滑 / 阶梯） | `antv-g2-chart` | `line` | 时间序列、参数扫描 |
| 面积图 / 堆叠面积图 | `antv-g2-chart` | `area` (+ `stackY`) | 累计、占比变化 |
| 饼图 / 环形图 | `antv-g2-chart` | `interval` + `coordinate: { type: 'theta' }` | 占比、构成 |
| 玫瑰图 / 玉珏图 | `antv-g2-chart` | `interval` + `coordinate: { type: 'polar' / 'radial' }` | 周期占比、排名 |
| 散点图 / 气泡图 | `antv-g2-chart` | `point` | 相关性、聚类 |
| 直方图 | `antv-g2-chart` | `rect` + `transform: [{ type: 'binX' }]` | 分布 |
| 箱线图 / 小提琴图 | `antv-g2-chart` | `boxplot` / `density` | 分布、异常值 |
| 雷达图 | `antv-g2-chart` | `line` + `coordinate: { type: 'polar' }` | 多指标对比 |
| 热力图（矩阵型） | `antv-g2-chart` | `cell` | 相关系数矩阵、网格搜索 |
| 漏斗图 | `antv-g2-chart` | `interval` + `shape: 'funnel'` | 转化率 |
| 桑基图 / 和弦图 | `antv-g2-chart` | `sankey` / `chord` | 流向 / 转移关系 |
| 矩阵树图 / 旭日图 / 分区图 | `antv-g2-chart` | `treemap` / `sunburst` / `partition` | 层级占比 |
| 词云 / 水波图 / 仪表盘 | `antv-g2-chart` | `wordCloud` / `liquid` / `gauge` | 文本频率 / 进度 |
| 甘特图 / K 线图 | `antv-g2-chart` | `interval` / `link` + `interval` | 项目进度 / 金融 |
| **网络图 / 关系图** | `antv-g6-graph` | `force` / `circular` layout | 节点-边关系、社交网络 |
| **树图 / 决策树 / 组织结构** | `antv-g6-graph` | `mindmap` / `dendrogram` / `compact-box` | 层级 |
| **路径图** | `antv-g6-graph` | 自定义边 + 布局 | TSP 解、最短路 |
| **流程图 / 技术路线图** | `antv-x6-editor` | 节点 + 边编辑器 | 模型流程 |
| **架构图 / 模型结构图** | `antv-x6-editor` | 节点 + 边 + 端口 | 神经网络、组件结构 |
| **DAG / ER 图 / 血缘图** | `antv-x6-editor` | 节点 + 边 + 端口 | 数据/模型关系 |
| **时序图** | `antv-x6-editor` | 节点 + 时序边 | 系统调用 |
| **透视表 / 交叉表** | `antv-s2-expert` | `PivotSheet` | 多维对比 |
| **明细表 / 大表** | `antv-s2-expert` | `TableSheet` | 结果对比、参数表 |
| **指标卡 / 趋势表** | `antv-s2-expert` | `TrendSheet` / 自定义单元格 | KPI 突出 |

### 3.2 冲突优先级（同名形态跨子 skill 时）

- **流程图** 优先 `x6-editor`（编辑器场景、可序列化），不要用 `g6-graph`（后者是数据可视化，编辑能力弱）。
- **树形图** 优先 `g6-graph`（布局算法全），不要用 `x6-editor`（后者布局要手排）。
- **矩阵型热力图** 用 `g2-chart`（`cell` mark），不要用 `g6-graph`。
- **甘特图** 用 `g2-chart`（标准 mark），不要用 `x6-editor`（后者要手写时间轴）。
- **判断不了时**：先回 `figures/*.drawio` 看是否有节点-边结构——有就 `x6`，没就 `g2`。

---

## 4. 配色规范

数模论文图表需同时满足 **学术规范**（黑白印刷可读）和 **评审观感**（不土气）。所有 07-antv 出的图**必须**套用下面的主色板，禁止凭审美另起色。

### 4.1 主色板（学术蓝绿橙红四象限）

| 名称 | HEX | 用途 |
| --- | --- | --- |
| `primary` | `#1f4e79` | 主导柱、主要折线（深学术蓝，**避**与正文混淆） |
| `secondary` | `#2e75b6` | 第二组数据（中蓝） |
| `accent` | `#c00000` | 强调、对比组（深红） |
| `warning` | `#bf9000` | 警示、阈值线（暗金） |
| `success` | `#548235` | 正向指标、可行域（暗绿） |
| `neutral` | `#7f7f7f` | 参考线、网格 |
| `grid` | `#e8e8e8` | 坐标网格（不抢主色） |
| `axis-text` | `#262626` | 标题文本 |
| `sub-text` | `#595959` | 副标题 |
| `label` | `#8c8c8c` | 轴标签 |

> 这套色板参考 Microsoft Office 学术配色，**全部通过灰度打印测试**（灰度后顺序仍可区分）。

### 4.2 使用规则

- **单图配色 ≤ 4 种**主色；多于 4 组数据时改用「主色 + 同色系深浅」或拆子图。
- **避免**：3D、阴影、渐变背景、霓虹色、纯红 + 纯绿（色盲不友好）。
- **中文 / 数字字体**：
  - 中文：`Noto Sans CJK SC` 或 `Source Han Sans CN`
  - 数字：英文部分用 `Inter` 或 `Times New Roman`；中文混排时跟随中文字体
  - 在 G2 / S2 中通过 `style: { fontFamily: '...' }` 显式设置，**不要依赖默认**
- **图例**：放在图表上方或右侧；多于 5 项时改用颜色 + 标签嵌入。
- **数据来源**：在图底加一行小字 `数据来源：results/<file>.csv`，字体 ≤ 10pt。

### 4.3 推荐模板（AntV 子 skill 主题）

| 子 skill | 主题 | 说明 |
| --- | --- | --- |
| `antv-g2-chart` | `classic`（默认 light） | 默认即可，无需 `classicDark` |
| `antv-g6-graph` | `default` | 节点色用 `primary`、边色用 `neutral` |
| `antv-x6-editor` | 自定义（参考 4.1 主色板） | 背景 `background: { color: '#FAFAFA' }` |
| `antv-s2-expert` | `default` | 表头色用 `primary`，正文 zebra 用 `grid` |

---

## 5. 调用规约

每张图按以下顺序处理，缺一步就跳到失败处理。

### 5.1 标准流程

1. **读数据**：从 `results/*.csv` 或 `figures/*.png` 反推数据表（OCR 不靠谱时优先找原 CSV）。
2. **选模板**：查 §3 路由表 → 选定 antv 子 skill。
3. **应用配色**：按 §4 主色板配置 `scale.color.range` 或 `node.style.fill`，**禁止**把 hex 写在数据字段里（参考 G2 约束 #17）。
4. **加标注**：标题、轴标签、图例、数据来源。
5. **导出 PNG**：保存到 `figures/antv/<原草稿名>.png`，300 DPI。
6. **登记日志**：在 `reports/ANTV_REPORT.md` 写一行（格式见 §6）。
7. **替换引用**：在终稿 md 中把 `figures/<name>.png` 替换为 `figures/antv/<name>.png`。

### 5.2 调用示例（伪代码）

```text
# 例子 1：折线图（参数扫描）
g2:
  invoke: antv-g2-chart
  input: results/sensitivity.csv  (x=param, y1=score, y2=baseline)
  mark: type: 'view' + children: [line(y1), line(y2, dash)]
  palette: [primary, accent]
  output: figures/antv/sensitivity.png

# 例子 2：模型结构图
x6:
  invoke: antv-x6-editor
  input: figures/draft/model_arch.drawio → 解析为 nodes/edges JSON
  layout: 3 层水平（输入层 / 隐藏层 / 输出层）
  palette: [primary, secondary, accent]
  output: figures/antv/model_arch.png

# 例子 3：参数对照表
s2:
  invoke: antv-s2-expert
  input: results/param_sweep.csv (pivot on algorithm × metric)
  sheet: PivotSheet
  palette: 表头 primary, 数值列 zebra
  output: figures/antv/param_table.png
```

### 5.3 各子 skill 的强约束速查

执行时直接对照上游子 skill 的"核心约束"小节，避免幻觉：

- **G2 v5**：只能调一次 `chart.options()`；多 mark 用 `view + children`；禁止 V4 链式 API；`padding` 不能是数组；详见 `antv-g2-chart` SKILL §1。
- **G6 v5**：`new Graph({...})` 一次性配置；节点业务属性必须放 `data` 字段；`force` 布局不支持 `preventOverlap`；详见 `antv-g6-graph` SKILL。
- **X6 3.x**：没有 `graph.render()`；容器字符串必须是 `'container'`；插件用前先 `graph.use(new Plugin(...))`；详见 `antv-x6-editor` SKILL。
- **S2**：优先按关键字路由到具体参考文档（透视 / 明细 / 主题 / 自定义单元格 / 事件 / SSR）；详见 `antv-s2-expert` SKILL §Query Routing。

---

## 6. `reports/ANTV_REPORT.md` 格式

每张升级后的图必须登记一行，便于终稿论文回溯和 06-verity 复查。

```markdown
# AntV 升级日志

| # | 原草稿 | 图表类型 | AntV 子 skill | 输入数据 | 输出文件 | 配色 | 备注 |
|---|--------|----------|---------------|----------|----------|------|------|
| 1 | figures/sensitivity.png | 折线图 | antv-g2-chart | results/sensitivity.csv | figures/antv/sensitivity.png | [primary, accent] | 多系列，含基线 |
| 2 | figures/model_arch.drawio | 架构图 | antv-x6-editor | drawio 解析 → 3 层节点 | figures/antv/model_arch.png | [primary, secondary, accent] | 输入/隐藏/输出 |
| 3 | figures/param_table.png | 透视表 | antv-s2-expert | results/param_sweep.csv | figures/antv/param_table.png | primary 表头 | 算法 × 指标 |
```

---

## 7. 自检清单（强制执行）

完成所有图后**必须**逐项检查。**任何一项不过都不要交付终稿**，先修复。

### 7.1 文件级

- [ ] **论文word文件可读**：`paper/竞赛论文.docx` 能正常打开，无乱码、无缺字符；文件大小合理。
- [ ] **图表替换完整**：草稿论文中的 `figures/*.png` 引用**全部**替换为 `figures/antv/*.png`，无遗漏（用 `grep` 在 md 里搜一遍旧路径，应返回 0 行）。
- [ ] **文件名映射**：`reports/ANTV_REPORT.md` 中每张图都有对应条目。

### 7.2 数据级

- [ ] **数值一致**：随机抽 3 张图，数据点（柱高 / 折线值 / 节点权重）与 `reports/RESULTS_REPORT.md` 一致。
- [ ] **数据来源标注**：每张图底部都有 `数据来源：...` 小字。
- [ ] **比例轴**：从 0 开始（或明确标注截断），不要"为了好看"从 1/2 起点。

### 7.3 视觉级

- [ ] **配色合规**：主色 ≤ 4 种；无 3D、无渐变背景；中文字体生效（抽 1 张放大看）。
- [ ] **编号连贯**：图 1, 图 2, ... 在终稿中按出现顺序编号，与 `ANTV_REPORT.md` 索引一致。
- [ ] **黑白可读**：把 PNG 转灰度看，主要信息（折线、柱、节点）仍可区分。

### 7.4 流程级

- [ ] **不重跑模型**：与 03 输出的 `results/*.csv` 数据点完全一致。
- [ ] **不修改结论文字**：终稿论文中所有数值、模型结论与草稿论文一致；07 只换图，不改字。
- [ ] **日志完备**：`reports/ANTV_REPORT.md` 已写入，所有图都有条目。

---

## 8. 失败处理

| 现象 | 处理 |
| --- | --- |
| AntV 子 skill 渲染失败（语法 / 数据格式错） | 重试 1 次；仍失败则降级用 matplotlib/seaborn 重出，文件名 `figures/antv/<name>.fallback.png`，在 `ANTV_REPORT.md` 注明 fallback 原因 |
| 数据与 `RESULTS_REPORT.md` 不一致 | **不要强行修图**——回退到 03/02 修数据，重跑后再升级 |
| 终稿 Word 缺图或图裂 | 确认图片路径正确、文件存在，重新导出 Word |
| 草稿论文引用了 antv 没覆盖的图（如 3D 模型截图、PS 出图） | 留在 `figures/` 不动，在终稿论文中标注"草稿图"或"示意图" |
| AntV 子 skill 出了幻觉 mark 类型 | 立刻停止，回查对应上游 SKILL.md 的"合法 mark 列表"小节，重写配置 |
| 配色不满足 §4 规则 | 重出，**不要** 提交带违规配色的终稿 |
| 用户临时改数据 → 07 已出的图过期 | 重新跑一次 07（只升级受影响的几张，其余保留） |

---

## 9. 不做的事（边界）

- ❌ **不**重跑模型或代码——属于 03。
- ❌ **不**修改 `reports/RESULTS_REPORT.md`——属于 02/03。
- ❌ **不**出草稿论文——属于 05。
- ❌ **不**验证数值结论——属于 06（07 只校验"图与结论一致"，不验证结论本身正确）。
- ❌ **不**在 03/04 阶段调用——草稿数据会迭代，浪费 token。
- ❌ **不**跳过自检清单——任何一项不过都视为交付失败。
- ❌ **不**给论文加图表以外的元素（封面 / 摘要图 / 装饰）——保持"只升级已有图"。

---

## 10. 与上层 SKILL.md 的衔接

- 上层 `SKILL.md` 在"工作流规则"里写了"双轨图表"和"AntV 路由"两条硬规则，本文件是它们的落地实现。
- 上层 `SKILL.md` 的产物结构里 `figures/antv/`、`reports/ANTV_REPORT.md`、`paper/竞赛论文.md`、`paper/竞赛论文.docx` 由本 skill 产出；其他文件不要在本 skill 里改动。
