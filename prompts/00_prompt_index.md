# Prompt Index

这些 prompt 用于在新对话中快速进入 SelfStudyOS 的固定工作流。

> **推荐**：直接使用 vault 内的 [`vault-template/01_LearningDesk/06_给Agent的启动句.md`](../vault-template/01_LearningDesk/06_给Agent的启动句.md)。它已经把“必读顺序 / 硬约束 / 5 行收口 / 三模式边界”全部写进同一段 prompt，并提供“作业 / 学新内容 / 复习”三种追加模式。本目录下的 prompt 是更细分场景的备份。

使用方式：

1. 把 `<YOUR_VAULT_PATH>` 替换成你的 Obsidian Vault 路径。
2. 复制对应 prompt 的 `text` 代码块。
3. 作为新对话第一条消息发送给 AI agent。

## 通用启动

- [`01_general_start.md`](01_general_start.md)

用于：不知道今天该做什么时，让 agent 读取 LearningDesk、判断状态、推进一个真实学习任务。

## 课程学习

- [`02_course_session.md`](02_course_session.md)
- [`03_problem_loop.md`](03_problem_loop.md)
- [`09_course_review.md`](09_course_review.md)
- [`08_exam_sprint.md`](08_exam_sprint.md)

用于：课程、作业、题型、错题、日常复习和考试复习。所有作业题处理必须按 Hint 1 → 2 → 3 → Solution 分层。

模式边界：

- 开始学习模式：新课件、新概念、新公式。
- 作业模式：真实作业、教材题、截图题、错题订正中的做题环节。
- 复习模式：冷复测、错题回看、间隔复习、复习债务。
- 期末冲刺：考前 1-3 周的大范围复习计划。

## 科研与项目

- [`04_reading_mission.md`](04_reading_mission.md)
- [`05_project_ability_tree.md`](05_project_ability_tree.md)

用于：读论文、探索研究方向、拆项目能力。主线课程未跑通前不启动论文 L2 深读。

## 资料与系统维护

- [`06_external_material_intake.md`](06_external_material_intake.md)
- [`07_weekly_review.md`](07_weekly_review.md)

用于：接入新资料、整理 raw data、复盘学习系统。

## 收口

所有 session 结束按 [`vault-template/99_Meta/Templates/learning_close_5lines.md`](../vault-template/99_Meta/Templates/learning_close_5lines.md) 写 5 行进当天 Daily Note，**不要**让用户手改 02 / 03 / 05 / 课程 progress。设计动机见 [`docs/close-ritual.md`](../docs/close-ritual.md)。
