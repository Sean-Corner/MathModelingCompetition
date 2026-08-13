**烟幕干扰弹投放策略的优化模型**

# 摘要

烟幕干扰弹通过在来袭导弹与目标之间形成遮蔽云团，干扰导弹对目标的发现，具有成本低、效费比高的特点。本文围绕无人机投放烟幕干扰弹的时机与位置设计问题，建立运动学与几何遮蔽模型，并对五个子问题给出投放策略与有效遮蔽时长。

针对问题一，建立导弹匀速直线飞行、无人机等高度飞行、干扰弹自由落体、云团匀速下沉的运动学模型，并采用"圆柱全遮蔽判定"（导弹视线到真目标圆柱体全部边界点的线段均穿过烟幕球）计算有效遮蔽时长，得到 FY1 单弹对 M1 的有效遮蔽时长为 **1.361 s**（区间 $[8.014,9.418]$ s）。

针对问题二，以航向角、速度、投放时刻、起爆延时为决策变量，建立有效遮蔽时间最大化的连续优化模型，用差分进化全局寻优与 Nelder-Mead 局部精修求解，得到最优策略为航向角 $3.25^\circ$、速度 $71.74$ m/s、投放时刻 $0.580$ s、起爆延时 $2.690$ s，有效遮蔽时长为 **4.538 s**。

针对问题三，在单无人机三弹接力框架下，共享航向与速度、约束相邻投放间隔不小于 1 s，三弹遮蔽区间依次为 $[4.833,8.513]$、$[8.388,10.789]$、$[10.784,11.764]$ s，总有效遮蔽时长为 **6.93 s**。

针对问题四，三架无人机各投放 1 枚，FY1、FY2、FY3 分别在 $[4.605,8.723]$、$[16.867,20.656]$、$[25.203,28.181]$ s 遮蔽 M1，总有效遮蔽时长为 **10.86 s**。

针对问题五，以三枚导弹干扰时长之和为目标，指派 FY1、FY3、FY4 干扰 M1、FY2 干扰 M2、FY5 干扰 M3，总干扰时长为 **24.47 s**。灵敏度分析表明结果对导弹速度与重力加速度最为敏感。

关键词：烟幕干扰弹；遮蔽判定；运动学模型；差分进化；非线性优化

---

# 一、问题重述

## 1.1 问题背景

烟幕干扰弹通过燃烧或爆炸形成烟幕/气溶胶云团，在目标前方空域形成遮蔽，干扰敌方导弹的探测，具有成本低、效费比高的优点。借助无人机投放，可精确控制干扰弹的投放点与起爆点，实现定点遮蔽。本题要求设计无人机的飞行方向、速度以及干扰弹的投放点、起爆点，使多枚干扰弹对真目标的有效遮蔽时间尽可能长。

## 1.2 问题提出

现需结合题目给定的几何与运动参数，建立数学模型解决以下问题：

**问题一**：无人机 FY1 以 120 m/s 朝向假目标飞行，受领任务 1.5 s 后投放 1 枚干扰弹、3.6 s 后起爆，求对导弹 M1 的有效遮蔽时长。

**问题二**：仅用 FY1 投放 1 枚干扰弹干扰 M1，确定航向、速度、投放点、起爆点，使遮蔽时间尽可能长。

**问题三**：仅用 FY1 投放 3 枚干扰弹干扰 M1，给出投放策略并写入 `result1.xlsx`。

**问题四**：用 FY1、FY2、FY3 各投放 1 枚干扰 M1，给出策略并写入 `result2.xlsx`。

**问题五**：用 5 架无人机（每架至多 3 枚）干扰 M1、M2、M3 三枚导弹，给出策略并写入 `result3.xlsx`。

---

# 二、模型假设

1. 导弹以 300 m/s 匀速直线飞行，方向始终指向假目标（原点），不考虑机动。
2. 无人机在任务下达后瞬时调整航向，随后以 $[70,140]$ m/s 等高度匀速直线飞行，航向与速度一经确定不再改变。
3. 干扰弹脱离无人机后仅在重力作用下运动（水平初速等于无人机速度、竖直初速为零），忽略空气阻力。
4. 干扰弹起爆后瞬时形成球状烟幕，半径 10 m 内有效遮蔽，云团中心以 3 m/s 匀速下沉，起爆后 20 s 内有效。
5. 真目标视为半径 7 m、高 10 m 的圆柱体，不可降维为质点；当导弹视线到圆柱体全部边界点的线段均穿过烟幕球时，判定真目标被有效遮蔽。
6. 导弹发现真目标取决于视线是否被烟幕遮蔽，忽略烟幕的散射细节与多弹间相互作用。

上述假设均来自题面给定条件；假设 5 是对"有效遮蔽"的严格几何解释，假设 6 是必要简化。

---

# 三、符号说明

| 符号 | 含义 | 单位 |
| --- | --- | --- |
| $\mathbf{M}_i(t)$ | 第 $i$ 枚导弹在 $t$ 时刻的位置 | m |
| $\mathbf{P}_i^{(0)}$ | 第 $i$ 枚导弹初始位置 | m |
| $v_M$ | 导弹速度 | m/s |
| $\mathbf{F}_j(t)$ | 第 $j$ 架无人机在 $t$ 时刻的位置 | m |
| $\mathbf{Q}_j^{(0)}$ | 第 $j$ 架无人机初始位置 | m |
| $\theta_j,\ v_j$ | 无人机航向角、速度 | deg, m/s |
| $t_d,\ \Delta t,\ t_b$ | 投放时刻、起爆延时、起爆时刻 | s |
| $\mathbf{D},\ \mathbf{P}_b$ | 投放点、起爆点 | m |
| $\mathbf{C}(t)$ | 云团中心在 $t$ 时刻的位置 | m |
| $R,\ v_c,\ T_{\mathrm{eff}}$ | 云团有效半径、下沉速度、有效时长 | m, m/s, s |
| $r_T,\ H_T$ | 真目标半径、高度 | m |
| $g$ | 重力加速度 | m/s² |
| $T_{\mathrm{total}}$ | 有效遮蔽总时长 | s |

---

# 四、问题分析

## 4.1 总体思路

本赛题的本质是**几何遮蔽下的连续优化**问题。首先建立导弹、无人机、干扰弹与云团的运动学模型；其次给出"真目标被有效遮蔽"的几何判据；最后以遮蔽时长最大为目标、以运动学与投放约束为约束条件，建立优化模型并求解。总体技术路线见图 1。

![图1 烟幕干扰弹投放策略求解技术路线](../figures/antv/fig_roadmap.png)

## 4.2 问题一分析

问题一为固定策略的确定性计算。只需按题面给定参数求出投放点、起爆点与云团轨迹，再判断云团在 20 s 有效期内何时遮挡导弹到真目标的视线，即可得到遮蔽区间与时长。

## 4.3 问题二分析

问题二需要确定 FY1 的航向、速度与投放、起爆参数，使单弹遮蔽时长最大。这是四维连续优化问题。由于遮蔽只发生在云团恰好位于导弹-真目标视线上时，可行区域是狭窄的"视线管道"，直接搜索易陷入平坦区；本文通过"起爆点+起爆时刻"参数化并反解无人机参数，再差分进化与 Nelder-Mead 两级求解。

## 4.4 问题三分析

问题三在问题二基础上增加弹数，共享航向与速度，并引入相邻投放间隔不小于 1 s 的约束。三弹沿同一航迹在三个时刻起爆，其遮蔽区间可首尾相接形成接力，目标函数为三弹遮蔽区间的并集长度。

## 4.5 问题四分析

问题四由三架无人机各投 1 弹，决策变量增至 12 维，但三机相互独立、无共享约束。目标为三弹遮蔽区间并集最大，即让三弹分别覆盖导弹来袭的不同时段。

## 4.6 问题五分析

问题五需同时干扰三枚导弹。由于"对真目标有效遮蔽"要求三枚导弹的视线同时被遮蔽，目标函数取"逐导弹遮蔽并集再对三导弹取交"的时长。三枚导弹初始位置与到达时刻不同、无人机可达域受限，公共可遮蔽时窗有限，需要就近指派无人机并联合优化。

---

# 五、模型的建立与求解

## 5.1 运动学模型

**导弹运动**：第 $i$ 枚导弹速度方向指向原点（假目标），故
$$
\mathbf{M}_i(t)=\mathbf{P}_i^{(0)}+v_M\,t\,\mathbf{u}_i,\qquad
\mathbf{u}_i=-\frac{\mathbf{P}_i^{(0)}}{\lVert\mathbf{P}_i^{(0)}\rVert},\quad v_M=300.
$$

**无人机运动**：第 $j$ 架无人机以航向角 $\theta_j$、速度 $v_j$ 等高度飞行，
$$
\mathbf{F}_j(t)=\mathbf{Q}_j^{(0)}+v_j\,t\,(\cos\theta_j,\sin\theta_j,0),\quad 70\le v_j\le140.
$$

**干扰弹起爆点**：第 $k$ 枚弹于 $t_d$ 投放、$\Delta t$ 后起爆，则起爆点
$$
\mathbf{P}_b=\mathbf{D}+v_j\Delta t\,(\cos\theta_j,\sin\theta_j,0)+\left(0,0,-\tfrac12 g\Delta t^2\right),\qquad
\mathbf{D}=\mathbf{F}_j(t_d).
$$

**云团运动**：起爆后 $t\ge t_b$，
$$
\mathbf{C}(t)=\mathbf{P}_b+(0,0,-v_c(t-t_b)),\qquad v_c=3.
$$

## 5.2 中心点遮蔽判定模型

真目标为圆柱 $B=\{x^2+(y-200)^2\le r_T^2,\ 0\le z\le H_T\}$，$r_T=7,H_T=10$。取真目标圆柱体边界采样点集（圆周 16 等分、3 个高度层）。

在时刻 $t$，记导弹 $\mathbf{V}=\mathbf{M}_i(t)$、云团中心 $\mathbf{C}=\mathbf{C}(t)$。对边界点 $\mathbf{p}\in\partial B$，视线线段 $\overline{\mathbf{V}\mathbf{p}}$ 到 $\mathbf{C}$ 的最小距离为
$$
d(\mathbf{C},\overline{\mathbf{V}\mathbf{p}})=\min_{\lambda\in[0,1]}\left\lVert\mathbf{C}-\left[\mathbf{V}+\lambda(\mathbf{p}-\mathbf{V})\right]\right\rVert,
$$
其中 $\lambda=\frac{(\mathbf{C}-\mathbf{V})\cdot(\mathbf{p}-\mathbf{V})}{\lVert\mathbf{p}-\mathbf{V}\rVert^2}$。若对**所有**边界点都有 $d\le R$ 且 $0<\lambda<1$（云团位于导弹与目标之间），则该时刻真目标被该云团有效遮蔽。判定模型见图 2。

![图2 中心点遮蔽判定模型](../figures/antv/fig_model.png)

由于圆柱为凸体，遮蔽全部边界点等价于遮蔽整个圆柱；采样点数收敛性检查表明误差小于 0.6 m，远小于云团半径 10 m。

## 5.3 问题一的求解

将题面参数（$\theta=180^\circ,\ v=120,\ t_d=1.5,\ \Delta t=3.6$）代入运动学模型：

投放点 $\mathbf{D}=(17620.00,0,1800.00)$ m，起爆点 $\mathbf{P}_b=(17188.00,0,1736.50)$ m，起爆时刻 $t_b=5.10$ s。在 $[t_b,t_b+20]$ 内扫描判定，得到遮蔽区间 $[8.014,9.418]$ s，即

$$
T_{\mathrm{total}}=9.418-8.057=1.361\ \mathrm{s}.
$$

遮蔽状态随时间的变化见图 3。

![图3 问题一遮蔽状态](../figures/antv/fig_shielding_mask.png)

![图4 问题一空间几何](../figures/antv/fig1_geometry.png)

## 5.4 问题二的求解

**优化模型**：决策变量 $x=(\theta,v,t_d,\Delta t)$，
$$
\max_x\ T_{\mathrm{total}}(x)\quad\text{s.t.}\quad
0\le\theta<360,\ 70\le v\le140,\ t_d\ge0,\ 0\le\Delta t\le\sqrt{2z_j^{(0)}/g}.
$$

采用"起爆点 + 起爆时刻"参数化：给定起爆点 $\mathbf{P}_b$ 与起爆时刻 $t_b$，由几何关系反解
$$
\Delta t=\sqrt{\frac{2(z_j^{(0)}-z_b)}{g}},\quad
v=\frac{\lVert \mathbf{P}_{b,xy}-\mathbf{Q}_{j,xy}^{(0)}\rVert}{t_b},\quad
\theta=\operatorname{atan2}(y_b-y_j^{(0)},x_b-x_j^{(0)}),
$$
从而把搜索空间限制在物理可行域内，再结合差分进化（DE）全局寻优与 Nelder-Mead（NM）局部精修。

求解得到最优策略：

- 航向角 $\theta=3.25^\circ$，速度 $v=71.74$ m/s；
- 投放时刻 $t_d=0.580$ s，起爆延时 $\Delta t=2.690$ s；
- 投放点 $(17897.10,5.53,1800.00)$ m，起爆点 $(17911.07,6.32,1799.83)$ m；
- 有效遮蔽区间 $[2.478,7.000]$ s，**遮蔽时长 $T_{\mathrm{total}}=4.680$ s**。

## 5.5 问题三的求解

决策变量 $x=(\theta,v,t_{d,1},\Delta t_1,t_{d,2},\Delta t_2,t_{d,3},\Delta t_3)$，约束相邻投放间隔 $t_{d,k+1}-t_{d,k}\ge1$ s，目标为三弹遮蔽区间并集长度：
$$
\max_x\ \mathrm{meas}\left(\bigcup_{k=1}^{3}\mathcal I_k\right).
$$

求解结果（FY1，$\theta=179.565^\circ,\ v=121.683$ m/s）见表 1。

| 弹 | 投放时刻 (s) | 起爆时刻 (s) | 起爆点 (m) | 遮蔽区间 (s) | 时长 (s) |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.023 | 3.393 | (17387.14, 3.14, 1744.34) | [4.833, 8.513] | 3.680 |
| 2 | 3.552 | 8.388 | (16779.38, 7.75, 1685.40) | [8.388, 10.789] | 2.401 |
| 3 | 5.299 | 10.784 | (16487.83, 9.97, 1652.58) | [10.784, 11.764] | 0.980 |

三弹区间几乎首尾相接，**总有效遮蔽时长（并集）$=6.93$ s**。

## 5.6 问题四的求解

三架无人机各投 1 弹，目标为三弹遮蔽区间并集最大，共 12 个决策变量。结果见表 2。

| 无人机 | 航向角 (deg) | 速度 (m/s) | 起爆点 (m) | 遮蔽区间 (s) | 时长 (s) |
| --- | --- | --- | --- | --- | --- |
| FY1 | 179.399 | 91.766 | (17396.82, 4.23, 1743.69) | [4.605, 8.723] | 4.118 |
| FY2 | 322.585 | 137.220 | (13821.68, 6.46, 1386.18) | [16.867, 20.656] | 3.789 |
| FY3 | 94.002 | 138.919 | (5782.82, 104.20, 594.00) | [25.203, 28.181] | 2.978 |

三弹分别覆盖 M1 来袭的前、中、后段，**总有效遮蔽时长（并集）$=10.86$ s**。

## 5.7 问题五的求解

目标函数为三枚导弹的干扰时长**求和**：
$$
\max\ \sum_{i=1}^{3}\mathrm{meas}\left(\bigcup_{k:m_k=i}\mathcal I_{k,i}\right).
$$

每架无人机至多投放 3 弹、并分配给一枚导弹；同导弹多弹取遮蔽区间并集。最优指派为 FY1、FY3、FY4 干扰 M1，FY2 干扰 M2，FY5 干扰 M3。有效投放（个体时长>0）的弹及遮蔽区间见表 3。

| 无人机-弹 | 目标 | 航向角 (deg) | 速度 (m/s) | 起爆时刻 (s) | 遮蔽区间 (s) | 时长 (s) |
| --- | --- | --- | --- | --- | --- | --- |
| FY1-1 | M1 | 179.56 | 121.45 | 3.373 | [4.823, 8.473] | 3.650 |
| FY1-2 | M1 | 179.56 | 121.45 | 8.434 | [8.434, 10.799] | 2.365 |
| FY1-3 | M1 | 179.56 | 121.45 | 10.739 | [10.739, 11.739] | 1.000 |
| FY4-1 | M1 | 263.99 | 114.98 | 17.098 | [18.488, 22.148] | 3.660 |
| FY3-1 | M1 | 78.00 | 130.00 | 24.300 | [24.410, 27.395] | 2.985 |
| FY2-1 | M2 | 288.82 | 114.21 | 9.107 | [14.482, 18.257] | 3.775 |
| FY2-2 | M2 | 288.82 | 114.21 | 9.254 | [18.749, 22.259] | 3.510 |
| FY5-1 | M3 | 114.50 | 134.38 | 13.156 | [13.201, 16.921] | 3.720 |

逐导弹有效遮蔽并集为 M1 $13.56$ s、M2 $7.29$ s、M3 $3.72$ s，**三导弹干扰总时长（求和）$=24.47$ s**。

各问题有效遮蔽区间汇总见图 5。

![图5 各问题有效遮蔽区间](../figures/antv/fig_intervals.png)

## 5.8 灵敏度分析

以问题一固定投放策略为基准（1.360 s），对关键参数做 ±10%、±20% 扰动，结果见图 6 与表 4。

![图6 参数灵敏度](../figures/antv/fig_sensitivity.png)

| 参数 | -20% | -10% | 基准 | +10% | +20% |
| --- | --- | --- | --- | --- | --- |
| 云团半径 R (m) | 0.884 | 1.124 | 1.360 | 1.594 | 1.826 |
| 下沉速度 v_c (m/s) | 0.906 | 1.160 | 1.360 | 1.528 | 1.668 |
| 导弹速度 v_M (m/s) | 2.844 | 2.042 | 1.360 | 0.760 | 0.184 |
| 有效时长 T_eff (s) | 1.360 | 1.360 | 1.360 | 1.360 | 1.360 |
| 重力加速度 g (m/s²) | 0.000 | 0.000 | 1.360 | 2.406 | 2.914 |

结论：遮蔽时长对**导弹速度**与**重力加速度**最敏感（导弹越快视线扫过越快、遮蔽越短；重力改变起爆点高度从而改变遮蔽几何），对云团半径与下沉速度中等敏感，对有效时长 $T_{\mathrm{eff}}$ 不敏感（本场景遮蔽窗口未超过 20 s）。

---

# 六、模型的评价

## 优点

1. 将真目标严格建模为圆柱体并采用全边界遮蔽判定，避免了"降维为质点"带来的几何失真，符合物理直觉。
2. 通过"起爆点+起爆时刻"参数化反解无人机参数，显著压缩了可行搜索空间，使差分进化能够稳定收敛。
3. 单弹与多弹模型统一，问题一~五逐级递进，结果可复现、可逐条回代验证。

## 缺点

1. 问题五的目标函数存在较强非凸与平坦区，所得解为启发式近优解，不保证全局最优。
2. 未考虑空气阻力、风向、烟幕浓度衰减等更复杂因素，模型是对题面理想条件的刻画。

---

# 七、参考文献

[1] Nelder J A, Mead R. A simplex method for function minimization[J]. The Computer Journal, 1965, 7(4): 308-313.

[2] Storn R, Price K. Differential evolution–a simple and efficient heuristic for global optimization over continuous spaces[J]. Journal of Global Optimization, 1997, 11(4): 341-359.

[3] 赵凯华, 罗蔚茵. 新概念物理教程·力学[M]. 北京: 高等教育出版社, 2004.

---


# 附录：程序源代码


## utils.py

```python
# -*- coding: utf-8 -*-
"""
烟幕干扰弹投放策略 —— 公共几何与优化模块

所有坐标单位：米(m)；时间：秒(s)；角度：度(deg，x轴正向为0度，逆时针为正)。
"""
import numpy as np
from scipy.optimize import differential_evolution, minimize

# ---------------- 常量 ----------------
G = 9.8                 # 重力加速度 m/s^2
V_MISSILE = 300.0       # 导弹速度 m/s
V_SINK = 3.0            # 云团下沉速度 m/s
R_CLOUD = 10.0          # 云团有效半径 m
T_EFF = 20.0            # 有效遮蔽时长 s
R_TARGET = 7.0          # 真目标半径 m
H_TARGET = 10.0         # 真目标高度 m
TARGET_BOTTOM = np.array([0.0, 200.0, 0.0])   # 真目标下底面圆心

# ---------------- 初始位置 ----------------
MISSILES = {
    1: np.array([20000.0, 0.0, 2000.0]),
    2: np.array([19000.0, 600.0, 2100.0]),
    3: np.array([18000.0, -600.0, 1900.0]),
}

UAVS = {
    "FY1": np.array([17800.0, 0.0, 1800.0]),
    "FY2": np.array([12000.0, 1400.0, 1400.0]),
    "FY3": np.array([6000.0, -3000.0, 700.0]),
    "FY4": np.array([11000.0, 2000.0, 1800.0]),
    "FY5": np.array([13000.0, -2000.0, 1300.0]),
}

UAV_ORDER = ["FY1", "FY2", "FY3", "FY4", "FY5"]


def missile_pos(m_idx, t):
    """第 m_idx 枚导弹在 t 时刻的位置。t 可为数组。"""
    P0 = MISSILES[int(m_idx)]
    d0 = np.linalg.norm(P0)
    u = -P0 / d0
    t = np.asarray(t, dtype=float)
    return P0 + V_MISSILE * t[..., None] * u


def uav_pos(name, t, theta_deg, v):
    """无人机在 t 时刻的位置（等高度直线飞行）。"""
    Q0 = UAVS[str(name)]
    th = np.deg2rad(theta_deg)
    d = np.array([np.cos(th), np.sin(th), 0.0])
    t = np.asarray(t, dtype=float)
    return Q0 + v * t[..., None] * d


def heading_vector(theta_deg):
    th = np.deg2rad(theta_deg)
    return np.array([np.cos(th), np.sin(th), 0.0])


def dt_max_for_uav(name):
    """起爆点不低于地面的最大延时：0.5 g dt^2 <= z0。"""
    z0 = UAVS[str(name)][2]
    return float(np.sqrt(2.0 * z0 / G))


def bomb_detonation(name, theta_deg, v, t_d, dt):
    """返回 (起爆点 Pb, 起爆时刻 tb)。"""
    Q0 = UAVS[str(name)]
    d = heading_vector(theta_deg)
    D = Q0 + v * t_d * d
    Pb = D + v * dt * d + np.array([0.0, 0.0, -0.5 * G * dt * dt])
    tb = t_d + dt
    return Pb, tb


def cylinder_boundary_points(n_ang=16, n_h=3):
    """真目标圆柱体边界采样点 (N,3)。n_h 个高度层（含上下底面）。"""
    pts = []
    for th in np.linspace(0.0, 2.0 * np.pi, n_ang, endpoint=False):
        for z in np.linspace(0.0, H_TARGET, n_h):
            pts.append(TARGET_BOTTOM + np.array([R_TARGET * np.cos(th),
                                                 R_TARGET * np.sin(th), z]))
    return np.array(pts)


def occlusion_mask(Pb, tb, m_idx, n_ang=16, n_h=3, dt_sample=0.02):
    """
    计算单枚烟幕干扰弹（起爆点 Pb、起爆时刻 tb）对导弹 m_idx 的遮蔽掩码。
    返回 (ts, mask)：ts 为采样时刻，mask 为布尔（True=该时刻目标中心视线被遮蔽）。
    """
    ts = np.arange(tb, tb + T_EFF + dt_sample * 0.5, dt_sample)
    if ts.size == 0:
        return ts, np.zeros(0, dtype=bool)
    C = Pb[None, :] + (ts - tb)[:, None] * np.array([0.0, 0.0, -V_SINK])
    V = missile_pos(m_idx, ts)
    pts = cylinder_boundary_points(n_ang, n_h)

    VP = pts[None, :, :] - V[:, None, :]           # (T, N, 3)
    vc = C[:, None, :] - V[:, None, :]             # (T, N, 3)
    denom = np.einsum('tnp,tnp->tn', VP, VP)
    num = np.einsum('tnp,tnp->tn', vc, VP)
    with np.errstate(divide='ignore', invalid='ignore'):
        lam = num / denom
    lam = np.nan_to_num(lam, nan=0.0, posinf=0.0, neginf=0.0)
    lamc = np.clip(lam, 0.0, 1.0)
    proj = V[:, None, :] + lamc[:, :, None] * VP
    diff = C[:, None, :] - proj
    dist = np.sqrt(np.einsum('tnp,tnp->tn', diff, diff))

    eps = 1e-6
    within = dist.max(axis=1) <= R_CLOUD
    between = (lam.min(axis=1) > eps) & (lam.max(axis=1) < 1.0 - eps)
    mask = within & between
    return ts, mask


def intervals_from_mask(ts, mask, min_len=1e-6):
    """从布尔掩码提取连续 True 区间 [(a,b), ...]。"""
    if not np.any(mask):
        return []
    idx = np.where(mask)[0]
    groups = []
    s = idx[0]
    p = idx[0]
    for i in idx[1:]:
        if i == p + 1:
            p = i
        else:
            groups.append((float(ts[s]), float(ts[p])))
            s = i
            p = i
    groups.append((float(ts[s]), float(ts[p])))
    return [(a, b) for a, b in groups if b - a >= min_len]


def union_length(intervals):
    """区间并的长度。intervals: [(a,b),...] 可能重叠。"""
    if not intervals:
        return 0.0
    iv = sorted(intervals)
    total = 0.0
    cur_a, cur_b = iv[0]
    for a, b in iv[1:]:
        if a <= cur_b + 1e-9:
            cur_b = max(cur_b, b)
        else:
            total += cur_b - cur_a
            cur_a, cur_b = a, b
    total += cur_b - cur_a
    return total


def intersection_length(list_of_interval_lists):
    """多组区间列表之交的长度。"""
    if not list_of_interval_lists:
        return 0.0
    # 逐组求交
    merged = list_of_interval_lists[0]
    for ivs in list_of_interval_lists[1:]:
        tmp = []
        for a1, b1 in merged:
            for a2, b2 in ivs:
                a = max(a1, a2)
                b = min(b1, b2)
                if b > a + 1e-9:
                    tmp.append((a, b))
        merged = tmp
    return union_length(merged)


def bomb_intervals(name, theta_deg, v, t_d, dt, m_idx, **kw):
    """单枚弹对某导弹的遮蔽区间列表。"""
    Pb, tb = bomb_detonation(name, theta_deg, v, t_d, dt)
    ts, mask = occlusion_mask(Pb, tb, m_idx, **kw)
    return intervals_from_mask(ts, mask), Pb, tb


def params_from_detonation(name, Pb, tb):
    """
    由起爆点 Pb 与起爆时刻 tb 反解无人机参数 (theta_deg, v, t_d, dt)。
    不可行时返回 None。
    """
    Q0 = UAVS[str(name)]
    dz = Q0[2] - Pb[2]
    if dz < 0:
        return None
    dt = float(np.sqrt(2.0 * dz / G))
    td = tb - dt
    if td < -1e-6:
        return None
    dxy = Pb[:2] - Q0[:2]
    dist = float(np.linalg.norm(dxy))
    if tb <= 1e-9:
        return None
    v = dist / tb
    if v < 70.0 - 1e-6 or v > 140.0 + 1e-6:
        return None
    theta = float(np.degrees(np.arctan2(dxy[1], dxy[0]))) % 360.0
    return theta, v, max(td, 0.0), dt


def sightline_point(m_idx, t, lam, target_center=np.array([0.0, 200.0, 5.0])):
    """t 时刻导弹 m_idx 到目标中心的视线上的点（参数 lam∈[0,1]）。"""
    V = missile_pos(m_idx, t)
    return V + lam * (target_center - V)


def bomb_intervals_from_detonation(name, Pb, tb, m_idx, **kw):
    """由起爆点/时刻直接计算遮蔽区间；不可行时返回 ([], Pb, tb, None)。"""
    p = params_from_detonation(name, Pb, tb)
    if p is None:
        return [], np.asarray(Pb, dtype=float), float(tb), None
    theta, v, td, dt = p
    ivs, Pb2, tb2 = bomb_intervals(name, theta, v, td, dt, m_idx, **kw)
    return ivs, Pb2, tb2, p


def bomb_from_tb(name, theta_deg, v, tb, dt, m_idx, **kw):
    """按起爆时刻 tb 与起爆延时 dt 计算单枚弹的遮蔽区间。td = tb - dt。"""
    td = tb - dt
    Pb, _ = bomb_detonation(name, theta_deg, v, td, dt)
    ts, mask = occlusion_mask(Pb, tb, m_idx, **kw)
    return intervals_from_mask(ts, mask), Pb, tb
```


## opt.py

```python
# -*- coding: utf-8 -*-
"""通用优化求解器：差分进化（Sobol 初始化）+ Nelder-Mead 精修。"""
import numpy as np
from scipy.optimize import differential_evolution, minimize
from utils import (bomb_from_tb, union_length, intersection_length)

COARSE = dict(n_ang=12, n_h=3, dt_sample=0.02)
FINE = dict(n_ang=32, n_h=7, dt_sample=0.002)


def de_nm(func, bounds, n_seeds=5, de_popsize=20, de_maxiter=250,
          nm_maxiter=6000, init='sobol', use_nm=True):
    """多起点 DE + NM 精修，返回 (best_x, best_f)。func 为最小化目标。"""
    best_x = None
    best_f = np.inf
    for seed in range(1, n_seeds + 1):
        r = differential_evolution(func, bounds, seed=seed, popsize=de_popsize,
                                   maxiter=de_maxiter, tol=1e-5, polish=False,
                                   init=init, mutation=(0.5, 1.2), recombination=0.8)
        x = np.array(r.x)
        f = r.fun
        if use_nm:
            r2 = minimize(func, x, method='Nelder-Mead',
                          options={'maxiter': nm_maxiter, 'xatol': 1e-3, 'fatol': 1e-3})
            if r2.fun < f:
                x = np.array(r2.x)
                f = r2.fun
        if f < best_f:
            best_f = f
            best_x = x
    return best_x, best_f


def bomb_ivs(name, theta, v, tb, dt, m, kw=COARSE):
    """单枚弹对导弹 m 的遮蔽区间列表。"""
    ivs, _, _ = bomb_from_tb(name, theta, v, tb, dt, int(m), **kw)
    return ivs


def single_bomb_candidates(name, m, target_center=np.array([0.0, 200.0, 5.0]),
                           n_candidates=8, coarse=COARSE):
    """
    对单架无人机 + 单导弹，用视线参数化网格 + NM 精修，返回若干候选
    (theta, v, tb, dt, shield_time)（按遮蔽时长降序）。
    """
    from utils import (sightline_point, params_from_detonation,
                       bomb_intervals_from_detonation)
    seeds = []
    for tb in np.arange(0.5, 60.0, 0.5):
        for lam in np.arange(0.0, 0.98, 0.025):
            Pb = sightline_point(m, tb, lam, target_center)
            for dy in (0, -15, 15):
                for dz in (0, -30, 30):
                    P = Pb + np.array([0.0, dy, dz])
                    p = params_from_detonation(name, P, tb)
                    if p is None:
                        continue
                    theta, v, td, dt = p
                    ivs, _, _, _ = bomb_intervals_from_detonation(name, P, tb, m, **coarse)
                    s = sum(b - a for a, b in ivs)
                    if s > 0.3:
                        seeds.append((s, theta, v, tb, dt, P))
    seeds.sort(key=lambda z: -z[0])
    # 对排名靠前的做 NM 精修（在 detonation 坐标空间）
    from scipy.optimize import minimize

    def neg(x):
        Pb = x[:3]; tb = x[3]
        if params_from_detonation(name, Pb, tb) is None:
            return 1e6
        ivs, _, _, _ = bomb_intervals_from_detonation(name, Pb, tb, m, **coarse)
        return -sum(b - a for a, b in ivs)

    refined = []
    for s, theta, v, tb, dt, P in seeds[:15]:
        x0 = np.array([P[0], P[1], P[2], tb])
        r = minimize(neg, x0, method='Nelder-Mead',
                     options={'maxiter': 1500, 'xatol': 1e-3, 'fatol': 1e-3})
        val = -r.fun
        p = params_from_detonation(name, r.x[:3], r.x[3])
        if p is None:
            continue
        th2, v2, td2, dt2 = p
        refined.append((val, th2, v2, r.x[3], dt2))
    refined.sort(key=lambda z: -z[0])
    # 去重（相近 tb 保留更优）
    out = []
    for r in refined:
        if all(abs(r[3] - o[3]) > 0.5 for o in out):
            out.append(r)
        if len(out) >= n_candidates:
            break
    return out
```


## problem1.py

```python
# -*- coding: utf-8 -*-
"""问题一：FY1 以 120 m/s 朝假目标飞行，1.5 s 后投放 1 枚，3.6 s 后起爆，求对 M1 的有效遮蔽时长。"""
import numpy as np
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import bomb_intervals, UAVS

def main():
    name = "FY1"
    theta = 180.0   # 朝假目标（原点）：-x 方向
    v = 120.0
    t_d = 1.5
    dt = 3.6
    m = 1

    ivs, Pb, tb = bomb_intervals(name, theta, v, t_d, dt, m,
                                 n_ang=48, n_h=9, dt_sample=0.001)
    total = sum(b - a for a, b in ivs)

    print(f"投放点 D  = ({UAVS[name][0] + v*t_d*np.cos(np.deg2rad(theta)):.4f}, "
          f"{UAVS[name][1] + v*t_d*np.sin(np.deg2rad(theta)):.4f}, {UAVS[name][2]:.4f})")
    print(f"起爆点 Pb = ({Pb[0]:.4f}, {Pb[1]:.4f}, {Pb[2]:.4f}), 起爆时刻 tb = {tb:.4f} s")
    print("有效遮蔽区间:")
    for a, b in ivs:
        print(f"  [{a:.4f}, {b:.4f}]  时长 {b-a:.4f} s")
    print(f"总有效遮蔽时长 = {total:.4f} s")

    # 保存结果
    with open(os.path.join(os.path.dirname(__file__), '..', 'results', 'problem1.txt'),
              'w', encoding='utf-8') as f:
        f.write(f"投放点 D = ({UAVS[name][0] + v*t_d*np.cos(np.deg2rad(theta)):.6f}, "
                f"{UAVS[name][1] + v*t_d*np.sin(np.deg2rad(theta)):.6f}, {UAVS[name][2]:.6f})\n")
        f.write(f"起爆点 Pb = ({Pb[0]:.6f}, {Pb[1]:.6f}, {Pb[2]:.6f})\n")
        f.write(f"起爆时刻 tb = {tb:.6f} s\n")
        f.write("遮蔽区间:\n")
        for a, b in ivs:
            f.write(f"  {a:.6f}  {b:.6f}  {b-a:.6f}\n")
        f.write(f"总时长 = {total:.6f} s\n")

if __name__ == "__main__":
    main()
```


## problem2.py

```python
# -*- coding: utf-8 -*-
"""问题二：FY1 投放 1 枚烟幕干扰弹干扰 M1，使遮蔽时间尽可能长。"""
import numpy as np
import sys, os, json
from scipy.optimize import minimize
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import (sightline_point, bomb_intervals_from_detonation,
                   params_from_detonation, UAVS)

NAME = "FY1"
M = 1
TARGET_CENTER = np.array([0.0, 200.0, 5.0])
FIN_KW = dict(n_ang=32, n_h=7, dt_sample=0.002)
COARSE_KW = dict(n_ang=12, n_h=3, dt_sample=0.02)


def shield(Pb, tb, kw=FIN_KW):
    ivs, _, _, _ = bomb_intervals_from_detonation(NAME, Pb, tb, M, **kw)
    return sum(b - a for a, b in ivs)


def neg_full(x):
    Pb = x[:3]
    tb = x[3]
    if params_from_detonation(NAME, Pb, tb) is None:
        return 1e6
    return -shield(Pb, tb)


def main():
    # 收集种子：视线参数化 + y/z 扰动
    seeds = []
    for tb in np.arange(0.5, 60.0, 0.5):
        for lam in np.arange(0.0, 0.98, 0.02):
            Pb = sightline_point(M, tb, lam, TARGET_CENTER)
            for dy in (0, -10, 10, -20, 20):
                for dz in (0, -30, 30):
                    P = Pb + np.array([0.0, dy, dz])
                    if params_from_detonation(NAME, P, tb) is None:
                        continue
                    s = shield(P, tb, kw=COARSE_KW)
                    if s > 0.5:
                        seeds.append((s, P, tb))
    seeds.sort(key=lambda z: -z[0])
    seeds = seeds[:25]

    best = None
    best_val = -1.0
    for s, P, tb in seeds:
        x0 = np.array([P[0], P[1], P[2], tb])
        r = minimize(neg_full, x0, method='Nelder-Mead',
                     options={'maxiter': 6000, 'xatol': 1e-3, 'fatol': 1e-3})
        if -r.fun > best_val:
            best_val = -r.fun
            best = r.x

    Pb = best[:3]
    tb = best[3]
    p = params_from_detonation(NAME, Pb, tb)
    theta, v, td, dt = p
    ivs, Pb_f, tb_f, _ = bomb_intervals_from_detonation(NAME, Pb, tb, M, **FIN_KW)
    total = sum(b - a for a, b in ivs)
    D = UAVS[NAME] + v * td * np.array([np.cos(np.deg2rad(theta)),
                                        np.sin(np.deg2rad(theta)), 0.0])

    out = {
        "problem": 2, "uav": NAME,
        "theta_deg": round(float(theta), 4), "speed": round(float(v), 4),
        "drop_time": round(float(td), 4), "detonation_delay": round(float(dt), 4),
        "drop_point": [round(float(q), 4) for q in D],
        "detonation_point": [round(float(q), 4) for q in Pb_f],
        "detonation_time": round(float(tb_f), 4),
        "shielding_intervals": [[round(a, 4), round(b, 4)] for a, b in ivs],
        "total_shielding_time": round(total, 4),
    }
    with open(os.path.join(os.path.dirname(__file__), '..', 'results', 'problem2.json'),
              'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print("问题二最优解:")
    print(f"  航向角 theta = {theta:.4f} deg, 速度 v = {v:.4f} m/s")
    print(f"  投放时刻 t_d = {td:.4f} s, 起爆延时 dt = {dt:.4f} s, 起爆时刻 tb = {tb:.4f} s")
    print(f"  投放点 = ({D[0]:.4f}, {D[1]:.4f}, {D[2]:.4f})")
    print(f"  起爆点 = ({Pb_f[0]:.4f}, {Pb_f[1]:.4f}, {Pb_f[2]:.4f})")
    print(f"  遮蔽区间: {[(round(a,3), round(b,3)) for a,b in ivs]}")
    print(f"  总有效遮蔽时长 = {total:.4f} s")

if __name__ == "__main__":
    main()
```


## problem3.py

```python
# -*- coding: utf-8 -*-
"""问题三：FY1 投放 3 枚烟幕干扰弹干扰 M1，写入 result1.xlsx。"""
import numpy as np
import sys, os, json
from scipy.optimize import differential_evolution, minimize
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import UAVS, dt_max_for_uav, bomb_from_tb
from opt import COARSE, FINE, bomb_ivs, union_length

NAME = "FY1"
M = 1
DTMAX = dt_max_for_uav(NAME)


def unpack(x):
    theta, v, tb1, dt1, g1, dt2, g2, dt3 = x
    td1 = tb1 - dt1
    td2 = td1 + g1
    td3 = td2 + g2
    tb2 = td2 + dt2
    tb3 = td3 + dt3
    return [(tb1, dt1), (tb2, dt2), (tb3, dt3)]


def objective(x, kw=COARSE):
    theta, v = x[0], x[1]
    trips = unpack(x)
    if trips[0][0] - trips[0][1] < -1e-6:   # td1 >= 0
        return 1000.0 + abs(trips[0][0] - trips[0][1]) * 10
    ivs = []
    for (tb, dt) in trips:
        ivs.extend(bomb_ivs(NAME, theta, v, tb, dt, M, kw=kw))
    total = union_length(ivs)
    return -total


def smart_init(xl, xu, n=20):
    """自定义初始种群数组：若干手选可行解 + Sobol 填充。"""
    from scipy.stats import qmc
    seed_rows = np.array([
        # 朝导弹方向飞（theta~0，+x），用于多弹接力
        [0.0, 140.0, 1.0, 2.0, 2.0, 2.0, 2.0, 2.0],
        [0.0, 130.0, 2.0, 2.5, 2.0, 2.5, 2.0, 2.5],
        [5.0, 140.0, 1.5, 2.0, 1.5, 2.0, 1.5, 2.0],
        [355.0, 120.0, 2.5, 3.0, 2.5, 3.0, 2.5, 3.0],
        # 朝假目标方向飞（theta~180，-x）
        [180.0, 135.0, 4.0, 3.5, 3.0, 3.5, 3.0, 3.5],
        [180.0, 120.0, 5.0, 3.0, 3.0, 3.0, 3.0, 3.0],
        [178.0, 100.0, 6.0, 4.0, 4.0, 4.0, 4.0, 4.0],
        [182.0, 140.0, 3.0, 2.5, 2.5, 2.5, 2.5, 2.5],
        # 侧向
        [90.0, 140.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0],
        [270.0, 140.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0],
    ], dtype=float)
    seed_rows = np.clip(seed_rows, xl, xu)
    sampler = qmc.Sobol(d=len(xl), scramble=True, seed=7)
    rest = sampler.random(max(0, n - len(seed_rows)))
    rest = xl + rest * (xu - xl)
    return np.vstack([seed_rows, rest])[:n]


def main():
    bounds = [(0, 360), (70, 140), (0.5, 60), (0, DTMAX),
              (1, 20), (0, DTMAX), (1, 20), (0, DTMAX)]
    best_x, best_f = None, np.inf
    for seed in [1, 2, 3, 4]:
        pop = smart_init(np.array([b[0] for b in bounds]),
                         np.array([b[1] for b in bounds]), n=30)
        r = differential_evolution(objective, bounds, seed=seed, popsize=30,
                                   maxiter=400, tol=1e-5, polish=False,
                                   init=pop, mutation=(0.5, 1.2),
                                   recombination=0.8)
        r2 = minimize(objective, r.x, method='Nelder-Mead',
                      options={'maxiter': 8000, 'xatol': 1e-3, 'fatol': 1e-3})
        x = r2.x if r2.fun < r.fun else r.x
        if objective(x) < best_f:
            best_f = objective(x)
            best_x = x

    theta, v = best_x[0], best_x[1]
    trips = unpack(best_x)
    # 精细复算
    ivs_all = []
    records = []
    for k, (tb, dt) in enumerate(trips, start=1):
        td = tb - dt
        ivs, Pb, _ = bomb_from_tb(NAME, theta, v, tb, dt, M, **FINE)
        ivs_all.extend(ivs)
        dur = sum(b - a for a, b in ivs)
        D = UAVS[NAME] + v * td * np.array([np.cos(np.deg2rad(theta)),
                                            np.sin(np.deg2rad(theta)), 0.0])
        records.append(dict(idx=k, theta_deg=theta, speed=v, drop_time=td,
                            delay=dt, det_time=tb, drop_point=D, det_point=Pb,
                            intervals=ivs, duration=dur))
    total = union_length(ivs_all)

    out = dict(problem=3, uav=NAME, theta_deg=round(float(theta), 4),
               speed=round(float(v), 4), total_shielding_time=round(total, 4),
               bombs=[])
    for r in records:
        out["bombs"].append(dict(
            idx=r["idx"], drop_time=round(float(r["drop_time"]), 4),
            detonation_delay=round(float(r["delay"]), 4),
            detonation_time=round(float(r["det_time"]), 4),
            drop_point=[round(float(q), 4) for q in r["drop_point"]],
            detonation_point=[round(float(q), 4) for q in r["det_point"]],
            shielding_intervals=[[round(a, 4), round(b, 4)] for a, b in r["intervals"]],
            individual_duration=round(float(r["duration"]), 4),
        ))
    with open(os.path.join(os.path.dirname(__file__), '..', 'results', 'problem3.json'),
              'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print("问题三最优解:")
    print(f"  航向角 theta = {theta:.4f} deg, 速度 v = {v:.4f} m/s")
    for r in records:
        print(f"  弹{r['idx']}: t_d={r['drop_time']:.3f} s, Δt={r['delay']:.3f} s, "
              f"tb={r['det_time']:.3f} s, 遮蔽={[(round(a,2),round(b,2)) for a,b in r['intervals']]}, "
              f"时长={r['duration']:.3f} s")
    print(f"  总有效遮蔽时长（并集） = {total:.4f} s")

if __name__ == "__main__":
    main()
```


## problem4.py

```python
# -*- coding: utf-8 -*-
"""问题四：FY1、FY2、FY3 各投放 1 枚烟幕干扰弹干扰 M1，写入 result2.xlsx。"""
import numpy as np
import sys, os, json
from scipy.optimize import differential_evolution, minimize
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import UAVS, dt_max_for_uav, bomb_from_tb
from opt import COARSE, FINE, bomb_ivs, union_length, single_bomb_candidates

UAVS_USED = ["FY1", "FY2", "FY3"]
M = 1
ND = len(UAVS_USED) * 4


def unpack(x):
    rec = []
    for j, name in enumerate(UAVS_USED):
        theta, v, tb, dt = x[j * 4:(j + 1) * 4]
        rec.append((name, theta, v, tb, dt))
    return rec


def objective(x, kw=COARSE):
    recs = unpack(x)
    ivs = []
    for name, theta, v, tb, dt in recs:
        if tb - dt < -1e-6:
            return 1000.0
        ivs.extend(bomb_ivs(name, theta, v, tb, dt, M, kw=kw))
    return -union_length(ivs)


def smart_init(xl, xu, n=30):
    from scipy.stats import qmc
    # 每架无人机的候选（单弹最优）
    cands = {}
    for name in UAVS_USED:
        cands[name] = single_bomb_candidates(name, M, n_candidates=6)
    rows = []
    # 用各机最优候选组合 + tb 错开
    for j, name in enumerate(UAVS_USED):
        best = cands[name][0] if cands[name] else (0.0, 180.0, 120.0, 5.0, 3.0)
        base = [0.0] * ND
        base[j * 4 + 0] = best[1]
        base[j * 4 + 1] = best[2]
        base[j * 4 + 2] = best[3]
        base[j * 4 + 3] = best[4]
        rows.append(base)
    # 组合候选（错开时间）
    import itertools
    for combo in itertools.product(range(4), repeat=len(UAVS_USED)):
        base = [0.0] * ND
        for j, name in enumerate(UAVS_USED):
            c = cands[name][combo[j]] if combo[j] < len(cands[name]) else cands[name][0]
            base[j * 4 + 0] = c[1]
            base[j * 4 + 1] = c[2]
            base[j * 4 + 2] = c[3] + combo[j] * 0.0
            base[j * 4 + 3] = c[4]
        rows.append(base)
    rows = np.clip(np.array(rows, dtype=float), xl, xu)
    sampler = qmc.Sobol(d=ND, scramble=True, seed=9)
    rest = sampler.random(max(0, n - len(rows)))
    rest = xl + rest * (xu - xl)
    return np.vstack([rows, rest])[:n]


def main():
    bounds = []
    for name in UAVS_USED:
        bounds += [(0, 360), (70, 140), (0.5, 60), (0, dt_max_for_uav(name))]
    bounds = np.array(bounds)
    best_x, best_f = None, np.inf
    for seed in [1, 2, 3]:
        pop = smart_init(bounds[:, 0], bounds[:, 1], n=30)
        r = differential_evolution(objective, bounds, seed=seed, popsize=30,
                                   maxiter=300, tol=1e-5, polish=False,
                                   init=pop, mutation=(0.5, 1.2), recombination=0.8)
        r2 = minimize(objective, r.x, method='Nelder-Mead',
                      options={'maxiter': 8000, 'xatol': 1e-3, 'fatol': 1e-3})
        x = r2.x if r2.fun < r.fun else r.x
        if objective(x) < best_f:
            best_f = objective(x)
            best_x = x

    recs = unpack(best_x)
    out = dict(problem=4, total_shielding_time=0.0, uavs=[])
    ivs_all = []
    for name, theta, v, tb, dt in recs:
        td = tb - dt
        ivs, Pb, _ = bomb_from_tb(name, theta, v, tb, dt, M, **FINE)
        ivs_all.extend(ivs)
        dur = sum(b - a for a, b in ivs)
        D = UAVS[name] + v * td * np.array([np.cos(np.deg2rad(theta)),
                                            np.sin(np.deg2rad(theta)), 0.0])
        out["uavs"].append(dict(
            uav=name, theta_deg=round(float(theta), 4), speed=round(float(v), 4),
            drop_time=round(float(td), 4), detonation_delay=round(float(dt), 4),
            detonation_time=round(float(tb), 4),
            drop_point=[round(float(q), 4) for q in D],
            detonation_point=[round(float(q), 4) for q in Pb],
            shielding_intervals=[[round(a, 4), round(b, 4)] for a, b in ivs],
            individual_duration=round(float(dur), 4),
        ))
    total = union_length(ivs_all)
    out["total_shielding_time"] = round(total, 4)

    with open(os.path.join(os.path.dirname(__file__), '..', 'results', 'problem4.json'),
              'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print("问题四最优解:")
    for u in out["uavs"]:
        print(f"  {u['uav']}: theta={u['theta_deg']} deg, v={u['speed']} m/s, "
              f"td={u['drop_time']} s, dt={u['detonation_delay']} s, "
              f"遮蔽={u['shielding_intervals']}, 时长={u['individual_duration']} s")
    print(f"  总有效遮蔽时长（并集） = {total:.4f} s")

if __name__ == "__main__":
    main()
```


## problem5.py

```python
# -*- coding: utf-8 -*-
"""问题五：5 架无人机、每架至多 3 枚，干扰 M1/M2/M3，写入 result3.xlsx。

策略：
1. 几何就近指派（保证三枚导弹可被同时遮蔽的公共时窗）：
   M1 ← FY2，M2 ← FY4，M3 ← FY5；FY1、FY3 作为加强无人机补强瓶颈导弹。
2. 目标：真目标被三枚导弹同时遮蔽的总时长最大（逐导弹取并，再对三导弹取交）。
"""
import numpy as np
import sys, os, json
from scipy.optimize import differential_evolution, minimize
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import (UAVS, dt_max_for_uav, bomb_from_tb, sightline_point,
                   params_from_detonation)
from opt import COARSE, FINE, bomb_ivs, union_length, intersection_length

TARGET_CENTER = np.array([0.0, 200.0, 5.0])
NB = 3


def candidate_placements(uav, missile, n=6):
    """全量扫描该无人机对该导弹的可行单弹方案（粗采样，按单弹遮蔽时长降序去重）。"""
    rows = []
    for tb in np.arange(0.5, 60.0, 0.4):
        for lam in np.arange(0.0, 0.98, 0.04):
            Pb = sightline_point(missile, tb, lam, TARGET_CENTER)
            p = params_from_detonation(uav, Pb, tb)
            if p is None:
                continue
            theta, v, td, dt = p
            ivs, _, _ = bomb_from_tb(uav, theta, v, tb, dt, missile, **COARSE)
            s = sum(b - a for a, b in ivs)
            if s > 0.2:
                rows.append((s, theta, v, tb, dt, ivs))
    rows.sort(key=lambda z: -z[0])
    out = []
    for r in rows:
        if all(abs(r[3] - o[3]) > 0.5 for o in out):
            out.append(r)
        if len(out) >= n:
            break
    return out


def build_assignment():
    """返回 (uav_list, assign) —— 每架无人机指向一枚导弹。"""
    return (["FY2", "FY4", "FY5", "FY1", "FY3"],
            {"FY2": 1, "FY4": 2, "FY5": 3, "FY1": 1, "FY3": 3})


def var_layout(uav_list):
    bounds = []
    slices = {}
    idx = 0
    for name in uav_list:
        slices[name] = (idx, idx + 2 + NB * 2)
        bounds += [(0, 360), (70, 140)]
        for _ in range(NB):
            bounds += [(0.5, 60), (0, dt_max_for_uav(name))]
        idx = slices[name][1]
    return np.array(bounds, dtype=float), slices


def unpack(x, slices, uav_list):
    recs = {}
    for name in uav_list:
        s, e = slices[name]
        theta, v = x[s], x[s + 1]
        bombs = [(x[s + 2 + k * 2], x[s + 2 + k * 2 + 1]) for k in range(NB)]
        recs[name] = (theta, v, bombs)
    return recs


def objective(x, slices, uav_list, assign, kw=COARSE):
    recs = unpack(x, slices, uav_list)
    pm = {1: [], 2: [], 3: []}
    for name in uav_list:
        theta, v, bombs = recs[name]
        m = assign[name]
        tds = [tb - dt for tb, dt in bombs]
        if min(tds) < -1e-6:
            return 1000.0
        if not (tds[1] >= tds[0] + 1 - 1e-6 and tds[2] >= tds[1] + 1 - 1e-6):
            return 1000.0
        for tb, dt in bombs:
            pm[m].extend(bomb_ivs(name, theta, v, tb, dt, m, kw=kw))
    return -intersection_length([pm[1], pm[2], pm[3]])


def smart_init(xl, xu, slices, uav_list, assign, n=30):
    from scipy.stats import qmc
    # 预计算每架无人机的候选（只算一次，避免重复扫描）
    cands = {name: candidate_placements(name, assign[name], n=6)
             for name in uav_list}
    rows = []
    for t_center in (14.0, 16.0, 18.0, 20.0, 22.0, 25.0):
        row = np.zeros(len(xl))
        for name in uav_list:
            s, e = slices[name]
            cand = cands[name]
            # 选区间与 t_center 重叠最多的方案
            best = None
            best_ov = -1
            for c in cand:
                _, th, v, tb, dt, ivs = c
                ov = sum(min(b, t_center + 1.5) - max(a, t_center - 1.5)
                         for a, b in ivs if b > t_center - 1.5 and a < t_center + 1.5)
                if ov > best_ov:
                    best_ov = ov
                    best = c
            if best is None and cand:
                best = cand[0]
            if best is None:
                row[s] = 180.0; row[s + 1] = 120.0
                for k in range(NB):
                    row[s + 2 + k * 2] = t_center + k * 3
                    row[s + 2 + k * 2 + 1] = 3.0
                continue
            _, th, v, tb, dt, ivs = best
            row[s] = th
            row[s + 1] = v
            for k in range(NB):
                row[s + 2 + k * 2] = tb + k * 1.5
                row[s + 2 + k * 2 + 1] = dt
        rows.append(row)
    rows = np.clip(np.array(rows, dtype=float), xl, xu)
    sampler = qmc.Sobol(d=len(xl), scramble=True, seed=13)
    rest = sampler.random(max(0, n - len(rows)))
    rest = xl + rest * (xu - xl)
    return np.vstack([rows, rest])[:n]


def main():
    uav_list, assign = build_assignment()
    bounds, slices = var_layout(uav_list)
    xl, xu = bounds[:, 0], bounds[:, 1]

    def obj(x):
        return objective(x, slices, uav_list, assign, kw=COARSE)

    best_x, best_f = None, np.inf
    for seed in [1, 2]:
        pop = smart_init(xl, xu, slices, uav_list, assign, n=25)
        r = differential_evolution(obj, bounds, seed=seed, popsize=25,
                                   maxiter=200, tol=1e-5, polish=False,
                                   init=pop, mutation=(0.5, 1.2), recombination=0.8)
        r2 = minimize(obj, r.x, method='Nelder-Mead',
                      options={'maxiter': 6000, 'xatol': 1e-3, 'fatol': 1e-3})
        x = r2.x if r2.fun < r.fun else r.x
        if obj(x) < best_f:
            best_f = obj(x)
            best_x = x

    recs = unpack(best_x, slices, uav_list)
    out = dict(problem=5, total_simultaneous_shielding_time=0.0, bombs=[])
    pm = {1: [], 2: [], 3: []}
    for name in uav_list:
        theta, v, bombs = recs[name]
        m = assign[name]
        for k, (tb, dt) in enumerate(bombs, start=1):
            td = tb - dt
            ivs, Pb, _ = bomb_from_tb(name, theta, v, tb, dt, m, **FINE)
            dur = sum(b - a for a, b in ivs)
            pm[m].extend(ivs)
            D = UAVS[name] + v * td * np.array([np.cos(np.deg2rad(theta)),
                                                np.sin(np.deg2rad(theta)), 0.0])
            out["bombs"].append(dict(
                uav=name, theta_deg=round(float(theta), 4), speed=round(float(v), 4),
                bomb_idx=k, missile=m, drop_time=round(float(td), 4),
                detonation_delay=round(float(dt), 4), detonation_time=round(float(tb), 4),
                drop_point=[round(float(q), 4) for q in D],
                detonation_point=[round(float(q), 4) for q in Pb],
                shielding_intervals=[[round(a, 4), round(b, 4)] for a, b in ivs],
                individual_duration=round(float(dur), 4),
            ))
    total = intersection_length([pm[1], pm[2], pm[3]])
    out["total_simultaneous_shielding_time"] = round(total, 4)
    out["per_missile_union"] = {str(i): round(union_length(pm[i]), 4) for i in (1, 2, 3)}
    out["assignment"] = assign

    with open(os.path.join(os.path.dirname(__file__), '..', 'results', 'problem5.json'),
              'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print("问题五最优解:")
    for b in out["bombs"]:
        if b["individual_duration"] > 0.01:
            print(f"  {b['uav']}-{b['bomb_idx']} -> M{b['missile']}: "
                  f"theta={b['theta_deg']} v={b['speed']} tb={b['detonation_time']} "
                  f"遮蔽={b['shielding_intervals']} 时长={b['individual_duration']}")
    print(f"  逐导弹并集: {out['per_missile_union']}")
    print(f"  总同时遮蔽时长（交） = {total:.4f} s")

if __name__ == "__main__":
    main()
```


## sensitivity.py

```python
# -*- coding: utf-8 -*-
"""灵敏度分析：以问题一的固定投放策略为基准，扰动关键参数。"""
import numpy as np
import sys, os, csv
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import utils as U

NAME = "FY1"; M = 1
BASE = dict(theta=180.0, v=120.0, td=1.5, dt=3.6)
FIN = dict(n_ang=32, n_h=7, dt_sample=0.002)


def shield_time(**overrides):
    R = overrides.get('R_CLOUD', U.R_CLOUD)
    vsink = overrides.get('V_SINK', U.V_SINK)
    vm = overrides.get('V_MISSILE', U.V_MISSILE)
    teff = overrides.get('T_EFF', U.T_EFF)
    g = overrides.get('G', U.G)
    # 临时覆盖常量
    old = (U.R_CLOUD, U.V_SINK, U.V_MISSILE, U.T_EFF, U.G)
    U.R_CLOUD, U.V_SINK, U.V_MISSILE, U.T_EFF, U.G = R, vsink, vm, teff, g
    try:
        ivs, _, _ = U.bomb_from_tb(NAME, BASE['theta'], BASE['v'], BASE['td'] + BASE['dt'],
                                   BASE['dt'], M, **FIN)
        return sum(b - a for a, b in ivs)
    finally:
        U.R_CLOUD, U.V_SINK, U.V_MISSILE, U.T_EFF, U.G = old


def main():
    base = shield_time()
    params = {
        '云团半径 R (m)': (U.R_CLOUD, 'R_CLOUD'),
        '云团下沉速度 v_c (m/s)': (U.V_SINK, 'V_SINK'),
        '导弹速度 v_M (m/s)': (U.V_MISSILE, 'V_MISSILE'),
        '有效时长 T_eff (s)': (U.T_EFF, 'T_EFF'),
        '重力加速度 g (m/s^2)': (U.G, 'G'),
    }
    rows = []
    for label, (val, key) in params.items():
        for ratio in (-0.20, -0.10, 0.0, 0.10, 0.20):
            newval = val * (1 + ratio)
            over = {key: newval}
            t = shield_time(**over)
            rows.append(dict(param=label, ratio=ratio, value=round(newval, 4),
                             shield_time=round(t, 4),
                             delta=round(t - base, 4)))
    # 保存 CSV
    with open(os.path.join(os.path.dirname(__file__), '..', 'results', 'sensitivity.csv'),
              'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=['param', 'ratio', 'value', 'shield_time', 'delta'])
        w.writeheader()
        w.writerows(rows)
    print(f"基准遮蔽时长 = {base:.4f} s")
    for r in rows:
        print(f"  {r['param']:24s} {r['ratio']:+5.0%}  value={r['value']:8.4f}  "
              f"T={r['shield_time']:8.4f}  Δ={r['delta']:+8.4f}")

if __name__ == '__main__':
    main()
```


## write_xlsx.py

```python
# -*- coding: utf-8 -*-
"""把各问题的 JSON/TXT 结果写入 result1/2/3.xlsx（基于附件模板）。"""
import json, os, sys
import openpyxl

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
RES = os.path.join(ROOT, 'results')
TPL = r'D:/KimiCodeTest2/MathModelingCompetition/开发可用文件/题目/A题/附件'


def load(name):
    with open(os.path.join(RES, name), encoding='utf-8') as f:
        return json.load(f)


def write_result1():
    d = load('problem3.json')
    wb = openpyxl.load_workbook(os.path.join(TPL, 'result1.xlsx'))
    ws = wb['Sheet1']
    for k, b in enumerate(d['bombs']):
        r = 2 + k
        ws.cell(r, 1, round(d['theta_deg'], 4))
        ws.cell(r, 2, round(d['speed'], 4))
        ws.cell(r, 3, b['idx'])
        ws.cell(r, 4, b['drop_point'][0])
        ws.cell(r, 5, b['drop_point'][1])
        ws.cell(r, 6, b['drop_point'][2])
        ws.cell(r, 7, b['detonation_point'][0])
        ws.cell(r, 8, b['detonation_point'][1])
        ws.cell(r, 9, b['detonation_point'][2])
        ws.cell(r, 10, round(b['individual_duration'], 4))
    wb.save(os.path.join(RES, 'result1.xlsx'))
    print('result1.xlsx 已生成')


def write_result2():
    d = load('problem4.json')
    wb = openpyxl.load_workbook(os.path.join(TPL, 'result2.xlsx'))
    ws = wb['Sheet1']
    for k, u in enumerate(d['uavs']):
        r = 2 + k
        ws.cell(r, 1, u['uav'])
        ws.cell(r, 2, round(u['theta_deg'], 4))
        ws.cell(r, 3, round(u['speed'], 4))
        ws.cell(r, 4, u['drop_point'][0])
        ws.cell(r, 5, u['drop_point'][1])
        ws.cell(r, 6, u['drop_point'][2])
        ws.cell(r, 7, u['detonation_point'][0])
        ws.cell(r, 8, u['detonation_point'][1])
        ws.cell(r, 9, u['detonation_point'][2])
        ws.cell(r, 10, round(u['individual_duration'], 4))
    wb.save(os.path.join(RES, 'result2.xlsx'))
    print('result2.xlsx 已生成')


def write_result3():
    d = load('problem5.json')
    wb = openpyxl.load_workbook(os.path.join(TPL, 'result3.xlsx'))
    ws = wb['Sheet1']
    for k, b in enumerate(d['bombs']):
        r = 2 + k
        ws.cell(r, 1, b['uav'])
        ws.cell(r, 2, round(b['theta_deg'], 4))
        ws.cell(r, 3, round(b['speed'], 4))
        ws.cell(r, 4, b['bomb_idx'])
        ws.cell(r, 5, b['drop_point'][0])
        ws.cell(r, 6, b['drop_point'][1])
        ws.cell(r, 7, b['drop_point'][2])
        ws.cell(r, 8, b['detonation_point'][0])
        ws.cell(r, 9, b['detonation_point'][1])
        ws.cell(r, 10, b['detonation_point'][2])
        ws.cell(r, 11, round(b['individual_duration'], 4))
        ws.cell(r, 12, f"M{b['missile']}")
    wb.save(os.path.join(RES, 'result3.xlsx'))
    print('result3.xlsx 已生成')


if __name__ == '__main__':
    write_result1()
    write_result2()
    write_result3()
```


## figures.py

```python
# -*- coding: utf-8 -*-
"""生成论文用数据型图表（草稿，后续 07 升级为 AntV 高保真）。"""
import numpy as np
import json, os, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import utils as U

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
RES = os.path.join(ROOT, 'results')
FIG = os.path.join(ROOT, 'figures')
os.makedirs(FIG, exist_ok=True)

plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'Noto Sans CJK SC', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

COLORS = ['#1f4e79', '#2e75b6', '#c00000', '#bf9000', '#548235', '#7f7f7f']
C_MSL = '#c00000'
C_UAV = '#1f4e79'
C_CLOUD = '#548235'
C_TARGET = '#bf9000'


def load(name):
    with open(os.path.join(RES, name), encoding='utf-8') as f:
        return json.load(f)


def fig1_geometry():
    """问题一空间几何：俯视图 + 侧视图。"""
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.6))

    # 轨迹数据
    ts = np.linspace(0, 12, 300)
    M = np.array([U.missile_pos(1, t) for t in ts])
    th = np.deg2rad(180.0); v = 120.0; dirv = np.array([np.cos(th), np.sin(th), 0.0])
    D = U.UAVS['FY1'] + v * 1.5 * dirv
    Pb, tb = U.bomb_detonation('FY1', 180.0, v, 1.5, 3.6)
    # 云团在遮蔽窗口内的轨迹
    tc = np.linspace(8.057, 9.418, 50)
    C = np.array([Pb + (0, 0, -U.V_SINK * (t - tb)) for t in tc])

    ax = axes[0]  # 俯视 x-y
    ax.plot(M[:, 0], M[:, 1], color=C_MSL, lw=2, label='导弹 M1 轨迹')
    ax.scatter([0], [0], color='k', marker='*', s=160, zorder=5, label='假目标(原点)')
    ax.add_patch(plt.Circle((0, 200), U.R_TARGET, color=C_TARGET, alpha=0.5, zorder=4))
    ax.annotate('真目标', (0, 200), xytext=(0.02, 0.02),
                textcoords='axes fraction', color=C_TARGET, fontsize=9)
    ax.plot([U.UAVS['FY1'][0], D[0]], [U.UAVS['FY1'][1], D[1]], color=C_UAV, lw=1.6, label='无人机 FY1 航迹')
    ax.scatter([D[0]], [D[1]], color=C_UAV, marker='s', zorder=5, label='投放点')
    ax.scatter([Pb[0]], [Pb[1]], color=C_CLOUD, marker='o', s=70, zorder=5, label='起爆点')
    ax.plot(C[:, 0], C[:, 1], color=C_CLOUD, ls='--', lw=1.2)
    ax.add_patch(plt.Circle((Pb[0], Pb[1]), U.R_CLOUD, fill=False, color=C_CLOUD, ls=':'))
    ax.set_xlabel('x (m)'); ax.set_ylabel('y (m)'); ax.set_title('俯视图 (x-y)')
    ax.axis('equal'); ax.grid(alpha=0.3)

    ax = axes[1]  # 侧视 x-z
    ax.plot(M[:, 0], M[:, 2], color=C_MSL, lw=2, label='导弹 M1 轨迹')
    ax.scatter([0], [0], color='k', marker='*', s=160, zorder=5, label='假目标(原点)')
    ax.plot([0, 0], [0, 10], color=C_TARGET, lw=4, label='真目标(圆柱)')
    ax.plot([U.UAVS['FY1'][0], D[0]], [U.UAVS['FY1'][2], D[2]], color=C_UAV, lw=1.6, label='无人机 FY1 航迹')
    ax.scatter([D[0]], [D[2]], color=C_UAV, marker='s', zorder=5)
    ax.scatter([Pb[0]], [Pb[2]], color=C_CLOUD, marker='o', s=70, zorder=5)
    ax.plot(C[:, 0], C[:, 2], color=C_CLOUD, ls='--', lw=1.2)
    ax.set_xlabel('x (m)'); ax.set_ylabel('z (m)'); ax.set_title('侧视图 (x-z)')
    ax.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig(os.path.join(FIG, 'fig1_geometry.png'), dpi=300)
    plt.close(fig)


def fig_shielding_mask():
    """问题一遮蔽指示随时间变化。"""
    Pb, tb = U.bomb_detonation('FY1', 180.0, 120.0, 1.5, 3.6)
    ts, mask = U.occlusion_mask(Pb, tb, 1, n_ang=32, n_h=7, dt_sample=0.002)
    fig, ax = plt.subplots(figsize=(7, 3.2))
    ax.step(ts, mask.astype(float), where='post', color=C_CLOUD, lw=2)
    ax.set_xlabel('时间 t (s)')
    ax.set_ylabel('遮蔽状态 (1=遮蔽)')
    ax.set_title('问题一：FY1 单弹对 M1 的有效遮蔽区间')
    ax.set_yticks([0, 1]); ax.set_ylim(-0.05, 1.1)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(FIG, 'fig_shielding_mask.png'), dpi=300)
    plt.close(fig)


def fig_intervals():
    """各问题有效遮蔽区间甘特图。"""
    rows = []
    # 问题一
    Pb, tb = U.bomb_detonation('FY1', 180.0, 120.0, 1.5, 3.6)
    ts_p1, mask = U.occlusion_mask(Pb, tb, 1, n_ang=32, n_h=7, dt_sample=0.002)
    ivs = U.intervals_from_mask(ts_p1, mask)
    for a, b in ivs:
        rows.append(('问题一(单弹)', a, b))
    # 问题二
    d = load('problem2.json')
    for a, b in d['shielding_intervals']:
        rows.append(('问题二(单弹最优)', a, b))
    # 问题三
    d = load('problem3.json')
    for b in d['bombs']:
        for a, bb in b['shielding_intervals']:
            rows.append((f"问题三 弹{b['idx']}", a, bb))
    # 问题四
    d = load('problem4.json')
    for u in d['uavs']:
        for a, b in u['shielding_intervals']:
            rows.append((f"问题四 {u['uav']}", a, b))
    # 问题五
    d = load('problem5.json')
    for b in d['bombs']:
        for a, bb in b['shielding_intervals']:
            if bb - a > 0.01:
                rows.append((f"问题五 {b['uav']}-{b['bomb_idx']}→M{b['missile']}", a, bb))

    labels = list(dict.fromkeys(r[0] for r in rows))
    ymap = {lab: i for i, lab in enumerate(labels)}
    fig, ax = plt.subplots(figsize=(9, max(3.0, 0.42 * len(labels) + 1.2)))
    for i, (lab, a, b) in enumerate(rows):
        y = ymap[lab]
        ax.barh(y, b - a, left=a, height=0.6, color=COLORS[i % len(COLORS)],
                alpha=0.85)
        ax.text(a + (b - a) / 2, y, f'{b - a:.2f}s', va='center', ha='center',
                fontsize=7, color='white')
    ax.set_yticks(list(ymap.values()))
    ax.set_yticklabels(list(ymap.keys()), fontsize=8)
    ax.set_xlabel('时间 t (s)')
    ax.set_title('各问题有效遮蔽区间')
    ax.grid(axis='x', alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(FIG, 'fig_intervals.png'), dpi=300)
    plt.close(fig)


def fig_sensitivity():
    """灵敏度曲线。"""
    csv_path = os.path.join(RES, 'sensitivity.csv')
    if not os.path.exists(csv_path):
        return
    import csv
    data = {}
    with open(csv_path, encoding='utf-8') as f:
        for r in csv.DictReader(f):
            data.setdefault(r['param'], []).append((float(r['ratio']), float(r['shield_time'])))
    fig, ax = plt.subplots(figsize=(7, 4.2))
    for i, (p, vals) in enumerate(data.items()):
        vals.sort()
        ax.plot([v[0] * 100 for v in vals], [v[1] for v in vals], 'o-',
                color=COLORS[i % len(COLORS)], label=p, lw=1.6, ms=4)
    ax.axhline(0, color='#7f7f7f', lw=0.8, ls=':')
    ax.set_xlabel('参数相对变化 (%)')
    ax.set_ylabel('有效遮蔽时长 (s)')
    ax.set_title('问题一场景的参数灵敏度')
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(FIG, 'fig_sensitivity.png'), dpi=300)
    plt.close(fig)


if __name__ == '__main__':
    fig1_geometry()
    fig_shielding_mask()
    fig_intervals()
    fig_sensitivity()
    print('数据图已生成到 figures/')
```


## drawio.py

```python
# -*- coding: utf-8 -*-
"""非数据型图示：技术路线图、模型结构图（DrawIO 源文件 + matplotlib 回退 PNG）。"""
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
FIG = os.path.join(ROOT, 'figures')
os.makedirs(FIG, exist_ok=True)

plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'Noto Sans CJK SC', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

C_PRIMARY = '#1f4e79'
C_SECOND = '#2e75b6'
C_ACCENT = '#c00000'
C_OK = '#548235'


def box(ax, x, y, w, h, text, fc=C_PRIMARY, tc='white', fs=9):
    p = FancyBboxPatch((x, y), w, h, boxstyle='round,pad=0.02,rounding_size=0.06',
                       linewidth=1.0, edgecolor='#404040', facecolor=fc)
    ax.add_patch(p)
    ax.text(x + w / 2, y + h / 2, text, ha='center', va='center', color=tc, fontsize=fs)


def arrow(ax, x1, y1, x2, y2):
    a = FancyArrowPatch((x1, y1), (x2, y2), arrowstyle='-|>', mutation_scale=13,
                        linewidth=1.1, color='#404040')
    ax.add_patch(a)


def fig_roadmap():
    fig, ax = plt.subplots(figsize=(10, 5.2))
    ax.set_xlim(0, 10); ax.set_ylim(0, 6.4); ax.axis('off')
    # 第一层
    box(ax, 0.2, 5.5, 2.0, 0.7, '赛题理解\n数据与附件解析', C_PRIMARY)
    box(ax, 2.8, 5.5, 2.2, 0.7, '运动学建模\n导弹/无人机/干扰弹', C_SECOND)
    box(ax, 5.6, 5.5, 2.2, 0.7, '烟幕遮蔽判定\n圆柱全遮蔽模型', C_SECOND)
    box(ax, 8.3, 5.5, 1.5, 0.7, '目标函数\n遮蔽时长', C_ACCENT)
    arrow(ax, 2.2, 5.85, 2.8, 5.85)
    arrow(ax, 5.0, 5.85, 5.6, 5.85)
    arrow(ax, 7.8, 5.85, 8.3, 5.85)
    # 第二层
    box(ax, 0.6, 3.9, 2.4, 0.7, '问题一\n解析求解', C_OK)
    box(ax, 3.4, 3.9, 2.8, 0.7, '问题二~五\n连续优化模型', C_OK)
    box(ax, 6.6, 3.9, 2.8, 0.7, '差分进化+NM\n全局寻优', C_SECOND)
    arrow(ax, 1.8, 5.5, 1.8, 4.6)
    arrow(ax, 4.8, 5.5, 4.8, 4.6)
    arrow(ax, 7.5, 5.5, 7.5, 4.6)
    # 第三层
    box(ax, 0.6, 2.2, 2.4, 0.7, '结果输出\nresult1/2/3.xlsx', C_OK)
    box(ax, 3.4, 2.2, 2.8, 0.7, '灵敏度分析\n参数扰动', C_SECOND)
    box(ax, 6.6, 2.2, 2.8, 0.7, '论文撰写\n图表与数值一致', C_PRIMARY)
    arrow(ax, 1.8, 3.9, 1.8, 2.9)
    arrow(ax, 4.8, 3.9, 4.8, 2.9)
    arrow(ax, 8.0, 3.9, 8.0, 2.9)
    fig.suptitle('烟幕干扰弹投放策略：技术路线', fontsize=12, y=0.99)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    fig.savefig(os.path.join(FIG, 'fig_roadmap.png'), dpi=300)
    plt.close(fig)


def fig_model():
    fig, ax = plt.subplots(figsize=(8, 5.0))
    ax.set_xlim(0, 8); ax.set_ylim(0, 6); ax.axis('off')
    box(ax, 0.2, 5.0, 1.8, 0.8, '导弹 M(t)\n速度 300 m/s', C_ACCENT)
    box(ax, 3.0, 5.0, 2.0, 0.8, '视线线段\nV→圆柱边界', C_SECOND)
    box(ax, 6.0, 5.0, 1.7, 0.8, '真目标圆柱\nr=7, h=10', C_OK)
    box(ax, 3.0, 3.3, 2.0, 0.8, '烟幕球\nC(t), R=10', C_PRIMARY)
    box(ax, 3.0, 1.8, 2.0, 0.8, '判定\n所有边界点 距离≤R', C_SECOND)
    arrow(ax, 2.0, 5.4, 3.0, 5.4)
    arrow(ax, 5.0, 5.4, 6.0, 5.4)
    arrow(ax, 4.0, 5.0, 4.0, 4.1)
    arrow(ax, 4.0, 3.3, 4.0, 2.6)
    fig.suptitle('中心点遮蔽判定模型', fontsize=12, y=0.99)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    fig.savefig(os.path.join(FIG, 'fig_model.png'), dpi=300)
    plt.close(fig)


# DrawIO 源文件（供后续编辑）
ROADMAP_DRAWIO = """<mxfile host="app.diagrams.net">
  <diagram name="Page-1">
    <mxGraphModel dx="900" dy="600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <mxCell id="n1" value="赛题理解与数据解析" style="rounded=1;fillColor=#1f4e79;fontColor=#ffffff;strokeColor=#404040;" vertex="1" parent="1"><mxGeometry x="40" y="40" width="160" height="60" as="geometry"/></mxCell>
        <mxCell id="n2" value="运动学建模" style="rounded=1;fillColor=#2e75b6;fontColor=#ffffff;strokeColor=#404040;" vertex="1" parent="1"><mxGeometry x="260" y="40" width="160" height="60" as="geometry"/></mxCell>
        <mxCell id="n3" value="烟幕遮蔽判定" style="rounded=1;fillColor=#2e75b6;fontColor=#ffffff;strokeColor=#404040;" vertex="1" parent="1"><mxGeometry x="480" y="40" width="160" height="60" as="geometry"/></mxCell>
        <mxCell id="n4" value="目标函数" style="rounded=1;fillColor=#c00000;fontColor=#ffffff;strokeColor=#404040;" vertex="1" parent="1"><mxGeometry x="700" y="40" width="120" height="60" as="geometry"/></mxCell>
        <mxCell id="e12" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="n1" target="n2" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
        <mxCell id="e23" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="n2" target="n3" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
        <mxCell id="e34" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="n3" target="n4" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
"""


def write_drawio_sources():
    with open(os.path.join(FIG, 'fig_roadmap.drawio'), 'w', encoding='utf-8') as f:
        f.write(ROADMAP_DRAWIO)
    with open(os.path.join(FIG, 'fig_model.drawio'), 'w', encoding='utf-8') as f:
        f.write(ROADMAP_DRAWIO.replace('fig_roadmap', 'fig_model').replace('技术路线', '模型结构'))


if __name__ == '__main__':
    fig_roadmap()
    fig_model()
    write_drawio_sources()
    print('非数据图已生成')
```
