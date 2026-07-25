---
name: 05-writing
description: "数学建模竞赛论文 Typst 撰写阶段。根据 ANALYSIS_MODELING_REPORT.md、RESULTS_REPORT.md 和 figures/*.pdf 选择比赛模板、组织章节，并在论文正文中按章节直接插入图表。"
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Agent, WebSearch, WebFetch
---

# 竞赛论文撰写skill

本 skill 承接 `03-coding-visual` 和 `04-drawio`。前序阶段只提供真实数据、图表 PDF 和记录文件；本阶段负责选择比赛模板、组织论文结构，并决定每张图表放入哪个章节。

调用 typst-author skill 学习 typst 写法

## 数学建模规范参考

如需领域判断，读取 `../../references/math_modeling_norms.md` 中的“论文写作”“图表与可视化”和“非数据图工具选择”小节。该文件只作为规范知识库，论文结构仍按比赛模板和当前赛题内容决定。

## 模板族

本技能内捆绑的 Typst 模板位于：

```text
../../assets/templates/zh/<竞赛>/main.typ
../../assets/templates/en/<竞赛>/main.typ
```

支持的中文模板：

```text
apmcm, changsanjiao, cumcm, default, diangongbei, dongsansheng,
huashubei, huaweibei, huazhongbei, mathorcup, mcm, shuweibei, stats, wuyibei
```

华为杯、华中杯、五一杯统一使用 `huaweibei`、`huazhongbei`、`wuyibei` 作为模板。

支持的英文模板：

```text
apmcm, default, mcm
```

论文中的所有数值图表结论必须来自 `reports/RESULTS_REPORT.md` 或 `figures/*`。不得编造、估算或使用不同的四舍五入方式。

## 工作流

### 步骤 0：选择语言和模板


除非用户明确要求中文，否则 MCM/ICM/COMAP 一律使用英文。所有中文竞赛名称使用中文。

模板键示例：

```text
长三角 -> zh/changsanjiao
APMCM 英文版 -> en/apmcm
全国赛/国赛/CUMCM -> zh/cumcm
统计建模 -> zh/stats
MCM/ICM/COMAP -> en/mcm
```

### 步骤 1：准备模板

用以下命令检查捆绑模板是否可访问（`SKILL_DIR` 为本 skill 所在目录）：

```bash
TEMPLATE_ROOT="$SKILL_DIR/../../assets/templates"
ls "$TEMPLATE_ROOT/zh/<竞赛>/main.typ" 2>/dev/null && echo "OK" || echo "MISSING"
```

- **文件存在（OK）**：直接将 `../../assets/templates/zh/<竞赛>/` 或 `../../assets/templates/en/<竞赛>/` 整目录复制到 `paper/`。这些模板是自包含入口文件，不依赖额外共享样式文件。
- **文件不存在（MISSING）**：说明 skill 未完整安装或在沙箱中，此时依照本 SKILL.md 步骤 3 列出的对应节文件结构，从零重建最小可编译 Typst 框架，并在 `paper/` 内注明"重建自 default 结构"。

存在匹配模板时，绝不从零开始写论文。


### 步骤 2：构建图表规划

在写正文各节之前，根据 `figures/*.pdf`、`reports/RESULTS_REPORT.md`，以及 `reports/DRAWIO_REPORT.md`（如果存在）构建图表规划：

```text
图表规划
fig_roadmap.pdf -> 引言/问题重述
fig_flow_q1.pdf -> 问题一模型构建
fig_flow_q2.pdf -> 问题二模型构建
fig_pipeline.pdf -> 数据预处理/方法节
结果图 -> 对应的结果节
```

然后使用 Typst 将已有的 PDF 图片直接嵌入相关的章节文件。注意 Typst 图片路径相对于写入该 `image(...)` 的 `.typ` 文件：写在 `paper/main.typ` 中通常用 `../figures/xxx.pdf`，写在 `paper/sections/*.typ` 中通常用 `../../figures/xxx.pdf`。

```typst
#figure(
  image("../../figures/fig_q1_error_dist.pdf", width: 85%),
  caption: [问题一预测误差分布],
)
```

英文论文使用英文图注。

### 步骤 3：撰写各节

中文数学建模通用模板各节文件（`changsanjiao`、`diangongbei`、`huashubei`、`mathorcup`、`wuyibei`）：

```text
1_restatement.typ  - 问题重述与分析
2_analysis.typ     - 数据理解与总体思路
3_assumptions.typ  - 模型假设
4_symbols.typ      - 符号说明
5_problem1.typ     - 问题一建模与求解
6_problem2.typ     - 问题二建模与求解
7_problem3.typ     - 问题三建模与求解
...         - 根据题目调整问题数量  
8_evaluation.typ   - 灵敏度分析、模型评价与推广
A_code.typ         - 附录代码
```

国赛/华中杯/华为杯（`cumcm`、`huazhongbei`、`huaweibei`）按 

```text
1_restatement.typ
2_analysis.typ
3_assumptions.typ
4_symbols.typ
5_problem1.typ
6_problem2.typ
7_problem3.typ
...        - 根据题目调整问题数量
8_sensitivity.typ
9_evaluation.typ
A_code.typ
```

东三省模板（`dongsansheng`）额外使用单独摘要文件：

```text
abstract.typ
1_restatement.typ
2_analysis.typ
3_assumptions.typ
4_symbols.typ
5_problem1.typ
6_problem2.typ
7_problem3.typ
...       - 根据题目调整问题数量
8_evaluation.typ
A_code.typ
```

数维杯模板（`shuweibei`）保留原 LaTeX 的示例入口命名：

```text
Abstract.typ
Introduction.typ
2_analysis.typ
3_assumptions.typ
4_symbols.typ
5_problem1.typ
6_problem2.typ
7_problem3.typ
...      - 根据题目调整问题数量
8_evaluation.typ
Appendices1.typ
A_code.typ
```

中文默认模板（`default`）：

```text
1_restatement.typ
2_assumptions.typ
3_symbols.typ
4_problem1.typ
5_problem2.typ
6_problem3.typ
...      - 根据题目调整问题数量
7_sensitivity.typ
8_evaluation.typ
A_code.typ
```

中文统计建模各节文件：

```text
1_introduction.typ
2_method.typ
3_data.typ
4_analysis.typ
5_results.typ
6_conclusion.typ
A_code.typ
```

英文 MCM/APMCM 各节文件（`en/mcm`、`en/apmcm`、`zh/mcm`、`zh/apmcm`）：

```text
1_introduction.typ
2_assumptions.typ
3_model_design.typ
4_solution.typ
5_sensitivity.typ
6_strengths_weaknesses.typ
7_conclusions.typ
A_code.typ
```

英文默认模板（`en/default`）default：

```text
1_introduction.typ
2_assumptions.typ
3_notations.typ
4_model.typ
5_sensitivity.typ
6_evaluation.typ
7_conclusions.typ
A_code.typ
```
**本skill之规定可能会与选定模板之规定有所冲突，若确有冲突，以本skill之规定为准。本skill未规定之事，以选定模板之规定为准。**

**正文写作应使用连贯的学术段落。避免在最终论文中出现工作流内部名称，如 `reports/`、`figures/` 或 `CLAUDE.md`。**

**一篇数学建模论文的各章节依顺序排列如下：
摘要；
一、问题重述；
二、模型假设；
三、符号说明；
四、问题分析；
五、模型的建立与求解；
六、模型的评价；
七、参考文献；
附录。**


一道数学建模竞赛题目一般由若干道问题组成。摘要的撰写应当放到最后写。
问题重述由问题背景与问题提出组成。写问题背景时，用不超过200字的文段简要介绍问题背景即可。写问题提出时，简明扼要地写每道题目具体要算的是什么。以下是问题提出的范例：


“为使 NIPT 检测在今后的临床应用中获得更高的检测准确性和更好的风险控制效果，现需结合实际情况与附件所给信息建立数学模型，分析以下问题：

问题一：分析胎儿 Y 染色体浓度与孕妇的孕周数和 BMI 等指标的相关性，给出相应的关系模型，并检验其显著性。

问题二：临床证明，男胎孕妇的 BMI 是影响胎儿 Y 染色体浓度达标时间的主要因素。试对男胎孕妇的 BMI 进行合理分组，给出每组的 BMI 区间和最佳 NIPT 时点，使得孕妇可能的潜在风险最小，并分析检测误差对结果的影响。

问题三：综合考虑身高、体重、年龄等多种因素及检测误差，根据男胎孕妇的 BMI 给出合理分组以及每组的最佳 NIPT 时点，使得在不同 Y 染色体浓度达标比例要求下孕妇潜在风险最小，并分析检测误差对结果的影响。

问题四：针对女胎异常判定问题，试以女胎孕妇的 21 号、18 号和 13 号染色体非整倍体为判定结果，综合考虑 X 染色体、21 号/18 号/13 号染色体 Z值、GC含量、读段数及相关比例，BMI指标等因素，给出女胎异常判定方法。”

写模型假设时，简明扼要地写清楚模型的假设即可。

写符号说明时，按学术论文的格式写一张符号说明表即可，要囊括本文内出现的所有符号。

写问题分析时，对每道问题应当用不超过400字的文段进行分析，不得含有任何数学演算过程。以下是一段问题分析范例：

“2.1 问题一：双光束干涉模型与厚度计算公式

本题首先需要建立红外干涉法下的物理模型。在假设仅有空气/外延层与外延层/衬底两界面单次反射时，可用双光束干涉模型描述反射率。其关键是基于菲涅尔公式写出反射振幅，结合外延层厚度d与相位延迟δ的关系，得到反射率 
的解析式。这样，膜厚d就成为反射率曲线的决定性参数。问题一的核心是将折射率模型与干涉公式结合，推导出外延层厚度的计算表达式。

2.2 问题二：两种厚度反演方法与可靠性分析

在问题一模型基础上，需要从实际反射率光谱数据反推出膜厚。为此设计了两条路线：

周期波谷直接计算法：利用干涉极值点之间的相位差值均为2π的特征，推导出厚度d与相邻波谷波数间隔的显式关系。通过样条插值获取精确极值点，再逐对计算出多个d，最后用统计方法得出平均厚度及置信区间。

牛顿迭代反演法：将反射率表达式与实测曲线拟合，构造残差平方和作为目标函数，以d、N1、N2为变量进行迭代优化。通过网格搜索设定初值，避免局部极值陷阱。最终得到稳定的迭代解，输出厚度d。

两种方法相互验证，并结合统计指标（标准差、置信区间、变异系数）来评估厚度求解结果的可靠性。

2.3 问题三：多光束干涉效应与修正

实际情况中，光在外延层内会发生多次往返反射，形成多光束干涉。相比双光束模型，多光束干涉在反射率表达式中引入分母几何级数项。

问题三的思路是：

推导多光束干涉的等效反射率公式 
，并定义表征效应显著性的参数G。

通过比较多光束与双光束模型的差异，判断多光束效应对厚度计算精度的影响，特别是在外延层折射率较大、吸收较弱时，G值增大，效应显著。

对附件数据，先用双光束模型计算厚度，再引入修正公式还原得到双光束等效反射率，重新进行厚度反演，从而减弱多光束效应带来的系统偏差。

这样既能解释多光束效应的物理条件，也能通过修正得到更接近真实的厚度值。”

写模型的建立与求解时，针对不同的问题分成不同的小节撰写。行文中必须含有数学模型建立与求解的详细演算过程和采用的算法的具体步骤详述，包括但不限于推导目标函数的数学演算过程、推导约束条件的数学演算过程、建立数学模型的具体演算过程。整个演算过程必须完全正确，绝不许有任何错误的地方。

模型的评价由模型的优点和模型的缺点两小节组成，简要写即可。模型的评价这一章控制在200字以内。

撰写参考文献和摘要的指引参照本skill的下文。

### 步骤4：参考文献

创建 `paper/references.typ`。只使用真实存在的参考文献。

中文参考文献块：

```typst
#set enum(numbering: "[1]")
#enum[
  作者. 题名[J]. 期刊名, 年份, 卷(期): 页码.
]
```

英文参考文献块：

```typst
#set enum(numbering: "[1]")
#enum[
  Author. "Title." Journal or Conference, year.
]
```

只对真实存在的文献使用上标引用标记：

```typst
相关研究已用于物流网络优化#super("[1]")。
```

### 步骤5：撰写附录
附录里写为解题而写的所有程序的完整源代码，比如用于解答某道题的python程序源代码。很多参赛者喜欢只放一部分或最核心的部分，这是不正确的，必须放完整的代码。


### 步骤 6：最后一步——撰写摘要

在所有章节完成后撰写中文摘要或英文 Summary Sheet。必须包含解答每道问题采用的方法和得出的精确数值结果。
以下是摘要的范例：

“摘要

随着精准医疗技术的发展，无创产前检测（NIPT）作为染色体异常筛查的关键，其检测精度和时点选择影响着临床效果和孕妇安全。然而，现有检测一方面容易忽略孕妇BMI等个体差异；另一方面如果采血时点过早可能因胎儿游离DNA浓度过低导致检测失败率升高，过晚则易引发临床安全。

针对问题一，首先通过Pearson相关性分析，识别出孕妇个体差异是影响检测效果的关键因素。进而，采用改进的线性混合效应模型（LMM）结合限制性最大似然估计（REML）方法，有效处理重复测量数据的层次结构特征。模型结果表明在可检测孕周范围内，Y染色体浓度与孕周呈正相关，且增长速度越来越快，与BMI和身高呈显著负向关系。模型通过了随机效应必要性、随机截距正态性、同方差性检验。组内相关系数ICC证实74.3%的总变异源于孕妇间个体差异，相比传统回归模型AIC值提升17.2%。

针对问题二，首先对数据进行聚合得到267位孕妇的完整情况。采用改良的高斯过程回归（GPR）拟合每位孕妇的浓度增长轨迹，进而推算其浓度达标时间（T_attain）的后验分布。而构建了一个基于BMI分组和最佳NIPT时点决策的风险最小化优化模型，结合遗传算法（GA）实现分组边界与检测时点的全局优化。核心结果显示三分组策略为最优解，而BMI分界点随准确率要求动态调整。检验存在误差，对误差的容忍度越低，推荐时点会越靠后，50%准确率下推荐时点为11.00-12.00孕周，均为低风险，而90%以上准确率要求会将最佳时点推迟到16-20周甚至更晚。

针对问题三，模型从依赖单一BMI变量变为处理多维异构特征。本文引入生存分析框架，预测孕妇“随时间变化的染色体浓度达标的概率函数”，构建混合深度生存网络。在数据处理上，通过多层感知机（MLP）处理静态特征、长短期记忆网络（LSTM）处理时序特征，最终由DeepHit生存分析头输出高度个体化的概率曲线。核心结果表明该模型预测精度达94.7%。最后再对多维数据建立风险最小化优化模型，结合遗传算法（GA）实现全局优化，得到了不同误差下的分组结果，并通过多因素分析发现影响最佳时点的主要静态指标是年龄和BMI。

针对问题四的女胎异常判定方法构建，为了解决数据总数少且不平衡，本文采用基于LightGBM和Optuna的堆叠集成模型框架以充分利用数据。首先，采用LightGBM+Optuna构建13、18、21号染色体异常的专用判定模型，学习并构建出各个染色体自身异常的元特征，并进一步学习可能存在的交互作用。最终将元特征与原始数据进行堆叠聚合，训练出一个能够准确判定异常的元模型。结果显示该方法对女胎健康/异常二分类准确率达99.7%，在3组独立验证集上误差均低于1.5%，并且在准确判断具体异常症状时，各项指标仍超出70%。

关键词：NIPT检测优化 线性混合效应模型 高斯过程回归 遗传算法 混合深度生存网络 ”

为方便参赛者日后修改，撰写的论文正文文件应为md文件，不可为pdf文件或其他形式的文件。由于md文件内不可包含图，故应当在md文件中插入图的位置写明该图的文件名，方便参赛者日后插入。
