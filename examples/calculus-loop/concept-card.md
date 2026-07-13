# Concept Card: 球坐标

## 基本信息

```text
概念：球坐标
领域：高等数学 / 三重积分
状态：learning
来源：脱敏学习闭环示例
```

## 一句话解释

球坐标用距离 `rho`、水平旋转角 `theta` 和从正 `z` 轴向下的角 `phi` 描述三维空间点，特别适合球、球壳、圆锥边界。

## 核心定义

```text
x = rho sin(phi) cos(theta)
y = rho sin(phi) sin(theta)
z = rho cos(phi)
dV = rho^2 sin(phi) d rho d phi d theta
```

## 最小例子

上半球：

```text
0 <= rho <= R
0 <= theta <= 2pi
0 <= phi <= pi/2
```

## 常见误区

- 把 `phi` 当成从 `xy` 平面量起。
- 半球题把 `phi` 写成 `0` 到 `pi`。
- 漏掉体积元里的 `rho^2 sin(phi)`。
- 替换被积函数时仍然保留 `x,y,z`。

## 学习证据

```text
我做过的题：上半球积分限。
我能复述的版本：phi 是从正 z 轴往下量，上半球到 xy 平面，所以是 pi/2。
我仍然会错的点：圆锥边界对应的 phi 常数还需要练。
```

## 下一步

做 1 道圆锥边界题，检查 `phi` 是否稳定。

