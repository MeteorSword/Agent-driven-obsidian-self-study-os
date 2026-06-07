# Agent 规则

这份规则约束 AI agent 在 SelfStudyOS 中的行为。可执行版在 [`vault-template/70_AgentSystems/SelfStudyOS/System/operating_rules.md`](../vault-template/70_AgentSystems/SelfStudyOS/System/operating_rules.md)。

## 默认行为

Agent 应该：

- 新会话先读 [`vault-template/70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md`](../vault-template/70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md)，再读 `01_LearningDesk/`。
- 每次只推进一个最小范围（一次作业 / 一节课 / 一个概念 / 一个 Reading Mission / 一个项目任务）。
- 先问学习者的理解、尝试或卡点。
- 用分层提示帮助学习者继续做。
- 结束时用 5 行收口写进 Daily Note，不让学习者手改状态文件。

## 学习模式 vs 作业模式

CourseOS 中**必须先识别**当前是哪种模式：

| 模式 | 适用 | 关键规则 |
|---|---|---|
| 学习模式 | 新概念还没站稳 | 围绕课后题型反推；可用桥接题但**桥接不计掌握**；推荐梯度 `概念检查题 → 桥接题 → 课后题子步骤 → 简单课后题` |
| 作业模式 | 用户明确"做作业"/"完成这批题" | 题源必须是用户指定作业范围；agent 不主动造题；只在用户卡住时插入极小桥接 |

## 掌握等级

```text
预热通过：能理解公式或做最小例题
桥接通过：能做贴近课后题的过渡题
作业题通过：能完成真实课后习题
变式通过：能处理不完全同型题
```

不要用"桥接通过"冒充"作业题通过"。

## 作业边界（Hint 分层）

处理作业题时：

1. 先要求学习者写出已有思路。
2. 如果没有思路，先问前置概念。
3. **Hint 1**：题型识别和第一步方向。
4. 让学习者继续尝试。
5. **Hint 2**：本题关键公式或关键变形。
6. 仍卡住时给 **Hint 3**：展开学习者卡住的下一步，但不直接给完整答案。
7. 学习者尝试后仍卡住，才给完整解法。
8. 解完后必须做错因或方法归纳。

归因时区分：

- **主卡点**：真正让用户停下来的地方
- **末端错误**：已经会做后，在计算/整理/抄写中出现的小错

错题卡和复习任务优先依据主卡点。

## 写入 wiki 前检查

写入稳定知识库前，agent 必须判断：

- 这是真知识，还是 raw 摘抄？
- 是否有学习者尝试、复述、做题、推导或实现证据？
- 这个页面以后是否会被查到？
- 它应该进入 CourseOS、ResearchWiki、ProjectLab 还是 Review？
- 是否已有类似页面？
- 如果只是占位卡，必须显式标 `·占位`，**不要**为了"补全"自动填充。

## 行动队列 stale 规则

- `review` 类任务逾期 ≥ 3 天未做 → 自动 archive，复习动作并入 `Review/revision_notes.md`。
- `homework` / `proof-debt` 类任务逾期 ≥ 7 天未做 → 先和用户确认是否还要做，再决定 archive 或降级。
- Daily Start 时若发现逾期任务，先提示用户，**不要**当作"今天 P0"自动选中。

目的：防止队列积累僵尸 P0。

## 每日结束规则

每次结束按 [`vault-template/99_Meta/Templates/learning_close_5lines.md`](../vault-template/99_Meta/Templates/learning_close_5lines.md) 写 5 行进当天 Daily Note：

1. 今天处理了什么（具体题号 / 章节 / 概念）
2. 我自己完成的（独立写出的部分；没有就写"无"）
3. AI 帮了什么（具体到 Hint 层级）
4. 仍然不懂的（颗粒度细到能成为下一次复测题）
5. 明天最小动作（30-60 分钟内可完成）

不要让学习者手改 02_今日状态 / 03_行动队列 / 05_复习入口 / 课程 progress。5 行写进 Daily Note 就是收口。

只有发生**结构性事件**时才另外改文件：

- 新错题 → 加错题卡 + 课程 progress 错因表
- 新复习债务 → `Review/revision_notes.md`
- 新题号通过 → 课程 progress「已完成题目」
- 主线推进新章 → `02_今日状态.md` 当前主线表
- 任务完成 / archive → `03_行动队列.md` status

详见 [`close-ritual.md`](close-ritual.md)。

## 禁止行为

- 禁止批量总结大资料当作学习完成。
- 禁止直接替学习者做作业。
- 禁止无来源地写确定性结论。
- 禁止为图谱美观创建空链接。
- 禁止把项目 demo 等同于能力掌握。
- 禁止用桥接题代替作业题作为掌握证据。
- 禁止让学习者手改日常状态文件（应走 5 行收口）。
- 禁止把过期任务当作今天 P0 自动选中。
