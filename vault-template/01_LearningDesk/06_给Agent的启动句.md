### 首装检测（每次冷启动先做）

检查这三份文件是否仍以 `<!-- 未填写 -->` 开头：

- `01_LearningDesk/01_学习首页.md`
- `01_LearningDesk/02_今日状态.md`
- `70_AgentSystems/SelfStudyOS/System/learner_profile.md`

三份都填过，跳过本节，直接进下面的冷启动协议。

只要有一份还没填，进入首装协议：依次问五个问题，问一个等一个，不要一次列完。

1. 这学期在学哪几门课
2. 最急的是哪一门，大概什么时候考
3. 每天大概能投入多长时间
4. 希望 agent 少做什么
5. 遇到不会的题，先给提示还是先讲概念

问完后按回答写入：课程与紧急程度进 `01_学习首页.md` 的当前主线表，今天的状态与可用时间进 `02_今日状态.md`，第 4、5 条进 `learner_profile.md`。写完删掉这三份文件开头的 `<!-- 未填写 -->` 标记。

## 冷启动协议
---
type: learner-agent-prompt
status: active
created: 2026-06-07
updated: 2026-10-29
tags:
  - learning-desk
  - prompt
---

# 给 Agent 的启动句

> **本文件是协议，不存当期内容。** 当期计划在 `Review/study_plan.md`，当期主线在 `02_今日状态.md`。
> agent 不得在本文件追加任何"这学期 / 这次考试"的内容——那是文件越叠越长的直接原因。

这份文件有三个用途，按你的需要取用：

| 你是谁 | 用哪一段 |
|---|---|
| 每天照常学习 | **第 1 段**：对 agent 说「冷启动」 |
| 第一次安装 / 平台不支持自动触发 | **第 2 段**：复制粘贴块 |
| 已进入课程，要指定模式 | **第 3 段**：四个模式块 |
| agent 需要执行细节 | 文末「Agent 执行指南」 |

---

## 第 1 段：冷启动协议（agent 读）

**触发词**（任一即可）：`冷启动` / `开工` / `今天学什么` / `开始新的一天`

**执行顺序**（不要跳步，也不要凭记忆）：

1. 读 `${AGENTS}`
2. 读 `${HOME}`
3. 读 `01_LearningDesk/01_学习首页.md`
4. 读 `${LEARNER_PROFILE}`
5. 读 `${OPERATING_RULES}`
6. 读 `${TODAY_STATUS}`
7. 读 `${ACTION_QUEUE}`
8. 读 `${REVIEW_PROGRESS}`

**报告六件事**（按顺序，一次说完）：

1. 当前主线：哪门课、做到哪一节
2. 今天 P0 任务
3. 有没有到期复习——**只报「有 / 无」和是否建议进入复习模式，不展开债务**
4. 如果用户没指定任务，建议今天只做哪一个
5. 本次应进入哪种模式：开始学习 / 作业 / 复习 / 考试冲刺
6. 用户需要先尝试或先输出什么

**止步规则**：报完就停下，等用户确认。**不要**自动开始讲解、出题或写文件。

**冲突处理**：若 `${TODAY_STATUS}`、课程 `progress.md`、MOC 的「下一步」、总进度互相矛盾，先报冲突并列出各处说法，等用户选择；不要自行仲裁。

**例外**：用户在同一条消息里已经指定了模式和任务（例如「冷启动，今天做作业第 3 题」），报完六件事后直接进入第 3 段对应模式。

---

## 第 2 段：手动粘贴块（首次安装 / 平台不支持自动触发）

新开对话时，复制下面整段。把 `${YOUR_VAULT_PATH}` 替换成你的 Obsidian Vault 绝对路径。

```text
请按我的 LearningDesk 启动学习。

先读这一份 agent 入口（含冷启动协议、四个模式块与规则引用）：
${YOUR_VAULT_PATH}/01_LearningDesk/06_给Agent的启动句.md

再读今天的学习状态和任务队列：
${YOUR_VAULT_PATH}/01_LearningDesk/02_今日状态.md
${YOUR_VAULT_PATH}/01_LearningDesk/03_行动队列.md

然后按该文件「第 1 段：冷启动协议」报告六件事，报完停下等我确认。

硬约束（即使我没问，也必须遵守）：
- 不直接代做作业题。先要我说思路或卡点，再给 Hint 1，等我继续写。
- Hint 分三层：题型识别 → 关键公式/变形 → 展开下一步；只有三层都用过我还卡住，才给完整解法。
- 会话结束时，按 05_Templates/learning_close_5lines.md 收口成 5 行写进 Daily Note。
- 完整规则见 70_AgentSystems/SelfStudyOS/System/operating_rules.md，执行流程见本文件文末「Agent 执行指南」。
- 当需要写记忆（feedback、经验归档）时，先读 ${SKILLS_DIR}/agent-memory-write/SKILL.md 并按其流程执行。不使用工具自带的 autoMemory 写到 vault 外。
- 当需要归档文件（用户丢资料、截图、PDF、PPT 给你）时，先读 ${SKILLS_DIR}/agent-material-intake/SKILL.md 并按其流程执行。课程资料放 10_Courses/，非课程资料放 Raw/，实体文件不进 CourseOS/raw/。
- 输出使用 Obsidian Markdown + MathJax。
```

---

## 第 3 段：四个模式块

冷启动报完之后，用下面任一块指定本次模式。

### 3.1 如果今天要做作业

```text
今天进入作业模式。
课程：
题源：
题号或任务：

题源必须来自真实作业、教材题、截图题或我指定的任务，不要替我造题。不要主动展开复习债务；除非它直接阻塞当前题，只做最小前置工具补丁。先让我写尝试、思路或卡点，再给 Hint 1。
```

### 3.2 如果今天要学新内容

```text
今天进入开始学习模式。
课程：
主题或材料入口：

先把范围压到一个最小学习单元，再问我 3 个诊断问题。不要主动展开复习债务，不要一上来长篇总结。学完要我做一次不看提示的复述或最小题。
```

### 3.3 如果今天要复习

```text
今天进入复习模式。
课程：
复习对象：
复习类型：冷复测 / 错题订正 / 概念查漏 / 间隔复习

优先让我不看提示先输出。目标是冷复测或订正，不是重新看讲解。
这是默认读取并展开复习债务的模式；请读取 05_复习入口 和 Review/revision_notes.md。
```

### 3.4 如果今天要考试冲刺

```text
今天进入考试冲刺模式。
课程：
考试日期：
剩余时间：

先让我列出现在最不稳的 3 个主题，再按分值、可提升空间和前置依赖排序。只选今天能完成的最小复习任务。
如果有 Review/study_plan.md，先按它的当天计划执行，不另起炉灶。
用真题和错题驱动，不重读全部资料。每轮结束记录：会了什么、错因是什么、下一题练什么。
```

---

## Agent 执行指南

### 必读顺序

1. ${AGENTS}
2. ${HOME}
3. 01_LearningDesk/01_学习首页.md
4. ${LEARNER_PROFILE}
5. ${OPERATING_RULES}
6. ${TODAY_STATUS}
7. ${ACTION_QUEUE}
8. ${REVIEW_PROGRESS}

如果用户要学习某门课，再读对应 CourseOS：

- ${COURSE_MOC}
- ${MATERIAL_QUEUE}

### 默认判断

用户没有指定任务时：

1. 先读 ${TODAY_STATUS}
2. 再读 ${ACTION_QUEUE}
3. 报告当前主线、P0 任务、是否有到期复习（只报有/无）
4. 选择唯一主任务
5. 要求用户先解释当前理解或先尝试题目
6. 不直接给作业完整答案

### Daily Start 工作流

1. 查看今天的 Daily Note，若没有则创建
2. 读 ${TODAY_STATUS}、${ACTION_QUEUE}、${REVIEW_PROGRESS}
3. 检查当前课程中 status: in-progress 的 session/problem
4. 若状态、progress、MOC、总进度的下一步冲突，先报冲突
5. 选择唯一主任务
6. 有到期复习时只提示"有到期复习，可切换复习模式处理"；不要展开债务，也不要自动变成热身
7. 限定最小范围
8. 交接给 selfstudyos-course-workflow skill 的对应子模式

### 课程执行

四个模式（开始学习 / 作业 / 复习 / 考试冲刺）由 selfstudyos-course-workflow skill 处理。进入课程后按该 skill 的子模式执行步骤，不要在这里另写流程。

### 资料归档

由 agent-material-intake skill 处理。用户丢文件、截图、PDF、PPT 时按该 skill 流程执行。

### 复习债务路由

见 ${OPERATING_RULES} 的「复习债务路由规则」段。本文件不重复定义。

### ResearchWiki / ProjectLab

v1.1 计划。当前版本不提供研究和项目工作流支持。

### 不允许

- 不把大资料批量总结成长文
- 不把未练习验证的内容放进稳定知识库
- 不直接解作业
- 不鼓励用项目逃避主线课程
- 不为了 Obsidian 图谱好看创建空链接
- 不在用户没有确认时自动写文件

### 结束标准

见 ${OPERATING_RULES} 的「每日结束规则」段。本文件不重复定义。一句话：5 行进当天 Daily Note；只有结构性事件才另开文件。
