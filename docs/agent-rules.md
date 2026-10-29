# Agent 规则（导读）

**这份文件是导读，不是规则正文。**

规则的唯一 source of truth 是可执行文件 [`vault-template/70_AgentSystems/SelfStudyOS/System/operating_rules.md`](../vault-template/70_AgentSystems/SelfStudyOS/System/operating_rules.md)。本文件只回答"你要找的东西在哪"，不重复定义——同一规则写两处，迟早互相矛盾。

## 我想查什么

| 我想知道 | 打开哪里 |
|---|---|
| agent 新会话从哪开始 | [`vault-template/AGENTS.md`](../vault-template/AGENTS.md) 与 [`06_给Agent的启动句.md`](../vault-template/01_LearningDesk/06_给Agent的启动句.md) |
| 冷启动做什么 | `06_给Agent的启动句.md` 第 1 段 |
| 四个模式怎么进 | `06_给Agent的启动句.md` 第 3 段 |
| 四个模式各自的执行步骤 | [`skills/selfstudyos-course-workflow/SKILL.md`](../skills/selfstudyos-course-workflow/SKILL.md) |
| 掌握等级怎么算 | `operating_rules.md` 的「掌握等级」段 |
| 复习债务什么时候展开 | `operating_rules.md` 的「复习债务路由规则」段 |
| 行动队列过期怎么处理 | `operating_rules.md` 的「行动队列 stale 规则」段 |
| session 结束怎么收口 | `operating_rules.md` 的「每日结束规则」段 + [`87 close-ritual.md`](close-ritual.md) |
| 换学期/换考试怎么切换 | `operating_rules.md` 的「周期切换」段 |
| 资料放哪 | `operating_rules.md` 的「资料放置规则」段（在 `raw_data_pipeline.md`）|
| 写记忆的流程 | [`skills/agent-memory-write/SKILL.md`](../skills/agent-memory-write/SKILL.md) |

## 三句话版本

如果你只想记住最少的规则：

1. **先让学习者尝试，再给提示。** Hint 分三层，三层用完才给完整解法。
2. **5 行收口是唯一的日常收尾。** 只有结构性事件（新错题 / 新复习债务 / 新题号通过 / 主线推进 / 任务 archive）才另开文件。
3. **06 是协议文件，不存当期计划。** 当期计划在 `Review/study_plan.md`，当期主线在 `02_今日状态.md`。

## 为什么这份文件变短了

v1.0 之前，本文件与 `operating_rules.md` 有五段内容重复（复习债务表、掌握等级、stale 规则、每日结束、Hint 七步）。改一处忘一处的结果是两边说法不一致，agent 按哪份执行取决于它先读到谁。

v1.0 起：规则只在 `operating_rules.md` 定义一次，本文件只做索引。
