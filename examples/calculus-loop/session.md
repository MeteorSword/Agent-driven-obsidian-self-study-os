# Learning Session: 球坐标入门

## 基本信息

```text
日期：2026-05-24
课程/领域：高等数学
材料路径：脱敏示例材料
本次范围：球坐标表示半球区域
deadline：无
```

## 启动问题

1. 我今天要学什么？
   - 用球坐标写出半球区域的积分限。
2. 这个内容在课程里的位置是什么？
   - 属于三重积分换元，和柱坐标、Jacobian、体积元有关。
3. 我已经知道什么？
   - 知道球坐标大致形式：`x=rho sin(phi) cos(theta)`，`y=rho sin(phi) sin(theta)`，`z=rho cos(phi)`。
4. 我最可能卡在哪里？
   - `phi` 的范围和体积元 `rho^2 sin(phi)`。
5. 今天结束时，什么算完成？
   - 能独立写出上半球 `x^2+y^2+z^2 <= R^2, z >= 0` 的积分限和体积元。

## Agent 处理

### Global orientation

球坐标适合处理球、球壳、圆锥边界。它的核心不是把坐标公式背下来，而是看清：

- `rho` 控制离原点多远。
- `theta` 控制绕 `z` 轴转多少。
- `phi` 控制从正 `z` 轴向下转多少。

### Core extraction

- 上半球：`0 <= rho <= R`
- 绕一圈：`0 <= theta <= 2pi`
- 从正 `z` 轴到 `xy` 平面：`0 <= phi <= pi/2`
- 体积元：`dV = rho^2 sin(phi) d rho d phi d theta`

### Check understanding

Agent 问：

1. 为什么上半球不是 `0 <= phi <= pi`？
2. 如果是下半球，`phi` 范围怎么变？
3. 体积元里为什么不能漏掉 `sin(phi)`？

学习者回答后再进入最小题。

## 学习证据

```text
我能复述：
phi 是从正 z 轴向下量的角，上半球只到 xy 平面，所以是 0 到 pi/2。

我能做的题：
能写出上半球区域的球坐标积分限。

我只是看懂但不会做：
遇到非标准球冠时还不稳定。

我还不懂：
圆锥面对应的 phi 常数还需要再练。
```

## 结束记录（v1.0 格式：5 行进 Daily Note）

```text
### 学习结束 5 行 · 2026-05-24 · 球坐标入门

1. 今天处理了什么：球坐标表示上半球区域的积分限与体积元；通过方式：Hint 1 后独立写出。
2. 我自己完成的：写出 rho、theta 的范围，判断 phi 到 xy 平面为止。
3. AI 帮了什么：Hint 1 用"从正 z 轴向下转"解释 phi 的几何方向。
4. 仍然不懂的：圆锥面对应的 phi 是常数，还需要再练。
5. 明天最小动作：做 1 道球冠或圆锥边界的球坐标积分限题。
```

模板与判据见 `vault-template/05_Templates/learning_close_5lines.md`；结构性事件才另开文件，见 [`progress-after.md`](progress-after.md)。

