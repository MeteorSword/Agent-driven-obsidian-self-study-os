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

## 进入本课：选择模式

进入课程后先选模式，不把新课学习、作业推进和复习混在一起。

| 模式 | 适用场景 | 本课入口 | 使用 prompt |
|---|---|---|---|
| 开始学习模式 | 新概念、新小节、新公式，还没准备直接做完整作业 | [[raw/material_queue\|raw 队列]]；课程资料；课堂笔记 | [`prompts/02_course_session.md`](../../../../../prompts/02_course_session.md) |
| 作业模式 | 课后题、作业题、截图题、指定题组 | 教材/习题 PDF；[[problems/problem_index\|题组索引]]；[[progress\|progress]]；[[../../../../01_LearningDesk/03_行动队列\|行动队列]] | [`prompts/03_problem_loop.md`](../../../../../prompts/03_problem_loop.md) |
| 复习模式 | 错题回看、冷复测、间隔复习、复习债务 | [[../../Review/revision_notes\|复习债务]]；[[mistakes/mistake_index\|错题索引]]；[[progress\|progress]] | [`prompts/09_course_review.md`](../../../../../prompts/09_course_review.md) |

选择规则：

- 开始学习模式先问 3 个诊断问题，再压到一个最小学习单元。
- 作业模式必须先让学习者写尝试、思路或卡点，再给 Hint 1。
- 复习模式优先冷复测，不先重讲。

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

1. 从 raw 队列或行动队列选择一个小范围。
2. 先判断当前是开始学习模式、作业模式还是复习模式。
3. 开 learning session / problem loop / course review。
4. 如果进入题目，按 Hint 1/2/3 分层。
5. 结束时按 [[99_Meta/Templates/learning_close_5lines|5 行收口]] 写进 Daily Note。
6. 只有发生结构性事件时另开文件（错题卡 / revision_notes / progress 新题号）。

### 当前候选队列

> agent 内部使用。学生看 [[01_LearningDesk/03_行动队列|03_行动队列]]，不看这里。

| Priority | Mode | Topic | Source | Status | Next action |
|---|---|---|---|---|---|
| P0 | 作业模式 | Example problem | problem_index | candidate | 先让学习者写尝试 |
| P1 | 复习模式 | Example review object | revision_notes | candidate | 冷复测输出 |
