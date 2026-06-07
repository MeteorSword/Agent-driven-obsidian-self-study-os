---
type: agent-bootstrap
status: active
created: 2026-05-22
updated: 2026-06-07
tags:
  - agent-bootstrap
  - selfstudyos
---

# START HERE FOR AGENT

如果你是新开启对话的 AI agent，并且用户在处理这个 Obsidian SelfStudyOS，先读本页。

本页是 **agent 专用入口**，不是用户每日学习入口。

用户每日学习入口是：

- [[01_LearningDesk/01_学习首页|学习首页]]
- [[01_LearningDesk/02_今日状态|今日状态]]
- [[01_LearningDesk/03_行动队列|行动队列]]

设计上把用户侧和 agent 侧分开，详见 [`docs/entry-separation.md`](../../../docs/entry-separation.md)。

## 必读顺序

1. [[70_AgentSystems/SelfStudyOS/AGENTS|SelfStudyOS AGENTS]]
2. [[70_AgentSystems/SelfStudyOS/home|SelfStudyOS home]]
3. [[01_LearningDesk/01_学习首页|学习首页]]
4. [[70_AgentSystems/SelfStudyOS/System/learner_profile|学习者画像]]
5. [[70_AgentSystems/SelfStudyOS/System/operating_rules|运行规则]]
6. [[70_AgentSystems/SelfStudyOS/System/raw_data_pipeline|raw data 拆解流程]]
7. [[01_LearningDesk/02_今日状态|今日状态]]
8. [[01_LearningDesk/03_行动队列|行动队列]]
9. [[70_AgentSystems/SelfStudyOS/Review/progress|总进度]]
10. [[60_Resources/ExternalIndexes/external_material_index|外部资料总索引]]

如果用户要学习某门课，再读对应 CourseOS：

```text
70_AgentSystems/SelfStudyOS/CourseOS/<CourseName>/<CourseName>-MOC.md
70_AgentSystems/SelfStudyOS/CourseOS/<CourseName>/raw/material_queue.md
```

## 当前系统状态

- 用户每日入口已经迁移到 [[01_LearningDesk/01_学习首页|01 LearningDesk]]。
- agent 后台规则、prompt 工程细节都留在 `70_AgentSystems/`，用户不需要每天打开。
- 系统最大风险不是资料不够，而是继续整理结构、不开始真实学习。

## 默认判断

如果用户没有指定任务，默认建议：

1. 先读 [[01_LearningDesk/02_今日状态|今日状态]]。
2. 再读 [[01_LearningDesk/03_行动队列|行动队列]]。
3. 报告当前主线、到期复习和 P0 任务。
4. 选择唯一主任务。
5. 要求用户先解释当前理解或先尝试题目。
6. 不直接给作业完整答案。

## 固定工作流

### Daily Start

1. 查看今天的 Daily Note，若没有则先放着，结束时再创建。
2. 查看 [[01_LearningDesk/02_今日状态|今日状态]]、[[01_LearningDesk/03_行动队列|行动队列]] 和 [[70_AgentSystems/SelfStudyOS/Review/progress|总进度]]。
3. 检查当前课程中 `status: in-progress` 的 session/problem。
4. 应用 [[70_AgentSystems/SelfStudyOS/System/operating_rules#行动队列 stale 规则|行动队列 stale 规则]]：review 类逾期 ≥ 3 天先 archive，homework 逾期 ≥ 7 天先和用户确认。不要把过期任务当今天 P0。
5. 若当前状态、课程 progress、MOC、总进度的下一步冲突，先报告冲突。
6. 选择唯一主任务。
7. 若有 15 分钟内可完成的过期复习任务，先作为热身。
8. 限定最小范围。
9. 开 learning session / problem loop / reading mission / project ability mapping。

### Material Intake

1. 不批量复制外部目录。
2. 先查 [[60_Resources/ExternalIndexes/external_material_index|外部资料总索引]]。
3. 判断类型：课程、作业、论文、项目、长期参考。
4. 选择处理模式：external-link、session-raw、vault-copy、wiki-distilled。
5. 每次只处理一个小范围。

### Course Learning

1. 读对应 CourseOS MOC。
2. 读 raw 接入队列。
3. **先识别模式**：学习模式 vs 作业模式（见 [[70_AgentSystems/SelfStudyOS/System/operating_rules#学习模式与作业模式|operating_rules]]）。
4. 让用户先说明理解、尝试或卡点。
5. 按 Hint 1 → Hint 2 → Hint 3 → Solution 分层提示，不先代做。
6. 结束时不要让用户手改 progress；按 [[99_Meta/Templates/learning_close_5lines|学习结束 5 行]] 收口。只有发生结构性事件时另开文件。

### Research Reading

1. 读论文接入队列。
2. 先写 Reading Mission。
3. 选择 L0-L4 目标级别。
4. 大多数论文只读到 L0/L1。
5. 主线课程未跑通前，不启动 L2 深读。

### Project Work

1. 读 [[70_AgentSystems/SelfStudyOS/ProjectLab/project_lab|ProjectLab]]。
2. 记录真实问题、用户、demo 状态、AI 代劳部分、能力债务。
3. 如果当天主线课程完全没推进，先完成一个最小主线任务再切回项目。
4. 项目输出要映射到能力树，不只追求 demo。

## 不允许

- 不把大资料批量总结成长文。
- 不把未练习验证的内容放进稳定知识库。
- 不直接解作业。
- 不鼓励用项目逃避主线课程。
- 不为了 Obsidian 图谱好看创建空链接。

## 结束标准

每次结束必须按 [[99_Meta/Templates/learning_close_5lines|学习结束 5 行]] 模板把会话收口，并写进当天 Daily Note（`50_LifeOps/Logs/Daily/YYYY-MM-DD.md`）的「复盘」段下面。如果今天 Daily Note 不存在，先按 [[99_Meta/Templates/daily_note|daily-note 模板]] 创建一份，再追加 5 行；不要因为没有 Daily Note 就跳过收口。

5 行内容：

1. 今天处理了什么材料 / 题号
2. 用户自己完成了什么
3. AI 帮了什么（具体到 Hint 层级）
4. 仍然不懂什么（颗粒度细到能成为下一次复测题）
5. 下一步最小动作（30-60 分钟可完成的具体动作）

不要让用户自己改下列任何一个文件来完成日常收口：02_今日状态 / 03_行动队列 / 05_复习入口 / 课程 progress。5 行写进 Daily Note 已经替代它们。只有发生结构性事件（新错题 / 新复习债务 / 新题号通过 / 主线推进 / 任务 archive）时才另外更新对应文件。

设计哲学详见 [`docs/close-ritual.md`](../../../docs/close-ritual.md)。
