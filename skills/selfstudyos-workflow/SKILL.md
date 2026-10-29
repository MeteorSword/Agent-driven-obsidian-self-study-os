---
name: selfstudyos-workflow
description: 当用户说"冷启动""开工""今天学什么""开始新的一天"，或要看进度、问"今天干什么"、需要学习调度时使用。负责冷启动序列、选任务、确认状态、半强制复习触发。资料归档由 agent-material-intake 处理，课程执行（做题/学新内容/复习/考试冲刺）由 selfstudyos-course-workflow 处理，ResearchWiki 和 ProjectLab 为 v1.1 计划。
---

# SelfStudyOS Workflow

Use this skill to operate an Obsidian-based AI self-study system.

The user should provide the Vault path. If they do not, ask for it once or infer it from the current workspace.

## Step 0：冷启动（用户只说「冷启动」时走这里）

用户每天可能只打三个字：`冷启动`（或「开工」「今天学什么」）。这时**不要问他要做什么**，直接执行：

1. 读 `${STARTUP_PROMPT}`（冷启动协议定义在此，以它为准）
2. 读 `${AGENTS}`、`${HOME}`、`${LEARNER_PROFILE}`
3. 读 `${OPERATING_RULES}`
4. 读 `${TODAY_STATUS}`、`${ACTION_QUEUE}`、`${REVIEW_PROGRESS}`

然后按 `${STARTUP_PROMPT}` 第 1 段报告六件事：当前主线 / 今天 P0 / 有无到期复习（只报有/无）/ 建议唯一任务 / 本次模式 / 用户要先输出什么。

**报完停下**，等用户确认，或按第 3 段选了模式再往下走。

若 `${TODAY_STATUS}`、课程 `progress.md`、MOC 的下一步、总进度互相矛盾，先报冲突，不要自行仲裁。

## First Move

Before making recommendations or editing notes, read:

1. `${STARTUP_PROMPT}`
2. `${AGENTS}`
3. `${HOME}`
4. `${LEARNER_PROFILE}`
5. `${REVIEW_PROGRESS}`

Then choose the smallest relevant workflow.

## Workflow Selection

### 日常学习（Daily Learning）

用户想学习、开始新的一天、查看进度，或问"今天干什么"时使用。

1. 读 `${REVIEW_PROGRESS}`。
2. 读 `${TODAY_STATUS}` 和 `${ACTION_QUEUE}`。
3. 选一个主任务。
4. 检查 `${ACTION_QUEUE}` 的 review 类任务，如有到期的，提示"有到期复习，可在今天结束时处理"，不立即展开，不打断当前模式。
5. 默认当前主线课程，除非用户指定别的课程。
6. 打开对应 CourseOS MOC 和 `${MATERIAL_QUEUE}`。
7. 问用户当前理解、第一次尝试或冷复测输出，然后交接给 selfstudyos-course-workflow skill 的对应子模式（开始学习 / 作业 / 复习 / 考试冲刺）。
8. 结束时半强制复习触发：检查 `${ACTION_QUEUE}` review 类任务，有到期的提出"现在做复习还是明天"。用户选"明天"才能跳过，在 `${REVISION_NOTES}` 对应条目标记延期和下次提醒日期（仅标记延期，不触发 archive；archive 规则以 `${OPERATING_RULES}` 的 stale 规则为准）。用户选"现在"则交接给 selfstudyos-course-workflow skill 的复习模式。

> 资料归档（用户丢文件、截图、PDF、PPT 等）由 agent-material-intake skill 处理，不在本工作流展开。
> 课程执行（开始学习/作业/复习/考试冲刺）由 selfstudyos-course-workflow skill 处理，本工作流只负责调度与交接。

### ResearchWiki

v1.1 计划。当前版本不提供研究工作流支持。

### ProjectLab

v1.1 计划。当前版本不提供项目工作流支持。

## Hard Rules

- Do not directly solve homework before the learner attempts or explains the stuck point.
- Do not batch ingest large folders.
- Do not turn sources into long summaries without practice evidence.
- Do not create decorative Obsidian links.
- Do not treat old notes as proof of current mastery.
- Do not expand review debts in homework or start-learning mode unless they directly block the current task.
- If the user drifts into projects to avoid foundations, point it out.

## Closeout

每次 session 结束，按 `${LEARNING_CLOSE_5LINES}` 把 5 行写进当天 Daily Note。这是**唯一**的日常收口动作。

只有结构性事件才另开文件（新错题卡 / 新复习债务 / 新题号通过 / 主线推进 / 任务 archive），清单与判据见 `${OPERATING_RULES}` 的「每日结束规则」段。

不要在本工作流里另外维护 queue、index 或 progress——那会与 5 行收口产生两套真相。

汇报内容（给用户看，不落盘）：

- Material handled
- What the learner did independently
- What AI helped with
- Remaining unclear point
- Next smallest action
