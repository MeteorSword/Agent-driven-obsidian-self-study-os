# ExampleCourse MOC

把 `ExampleCourse` 复制或重命名为你的真实课程。

这个 MOC 同时面向学生和 agent，**上半段是学生入口**，下半段是 agent 内部工作流。

## 当前目标（学生入口）

```text
课程：
阶段：
本周目标：
当前最不稳的点：
```

## 进入课程后我要做什么

| 我要做什么 | 怎么做 |
|---|---|
| 做作业 | 在 [[01_LearningDesk/03_行动队列|03_行动队列]] 找当前作业题号 → 自己写一段尝试/思路 → 让 agent 给 Hint |
| 学新内容 | 让 agent 把范围压到一节、一个概念，先做 3 个诊断问题 |
| 做复习 | 回 [[01_LearningDesk/05_复习入口|05_复习入口]]，按到期复习走 |

## 学生侧索引

- [[progress|progress（总进度）]]
- [[concepts/concept_index|概念索引]]
- [[mistakes/mistake_index|错题索引]]
- [[problems/problem_index|题组索引]]
- [[raw/material_queue|raw 队列]]

---

## Agent 内部使用（不是学生入口）

下面的内容是 agent 工作流引用位置，**填模板不等于学习**。学生平时不需要打开下面这一段。

### Agent 学习流程

1. 从 raw 队列选择一个小范围。
2. 识别模式：学习模式 / 作业模式（见 [[70_AgentSystems/SelfStudyOS/System/operating_rules#学习模式与作业模式|operating_rules]]）。
3. 开 learning session。
4. 如果进入题目，开 problem loop，按 Hint 1/2/3 分层。
5. 结束时按 [[99_Meta/Templates/learning_close_5lines|5 行收口]] 写进 Daily Note。
6. 只有发生结构性事件时另开文件（错题卡 / revision_notes / progress 新题号）。

### 当前候选队列

> agent 内部使用。学生看 [[01_LearningDesk/03_行动队列|03_行动队列]]，不看这里。

| Priority | Topic | Source | Status | Next action |
|---|---|---|---|---|
| P0 | Example topic | material_queue | candidate | 开一次 learning session |
