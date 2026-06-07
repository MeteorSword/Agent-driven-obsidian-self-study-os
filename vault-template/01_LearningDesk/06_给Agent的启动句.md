---
type: learner-agent-prompt
status: active
created: 2026-06-07
updated: 2026-06-07
tags:
  - learning-desk
  - prompt
---

# 给 Agent 的启动句

新开对话时，复制下面这一段。把 `<YOUR_VAULT_PATH>` 替换成你的 Obsidian Vault 绝对路径。

```text
请按我的 LearningDesk 启动学习。

先读这一份 agent 入口（含必读顺序、教学边界、固定工作流）：
<YOUR_VAULT_PATH>/70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md

再读今天的学习状态：
<YOUR_VAULT_PATH>/01_LearningDesk/02_今日状态.md
<YOUR_VAULT_PATH>/01_LearningDesk/03_行动队列.md

然后告诉我：
1. 当前主线是什么
2. 今天 P0 任务是什么
3. 有没有到期复习
4. 你建议今天只做哪一个任务
5. 我需要先尝试什么

硬约束（即使我没问，也必须遵守）：
- 不直接代做作业题。先要我说思路或卡点，再给 Hint 1，等我继续写。
- Hint 分三层：题型识别 → 关键公式/变形 → 展开下一步；只有三层都用过我还卡住，才给完整解法。
- 桥接题不计入掌握证据，掌握证据必须是真实课后题独立完成。
- 不批量复制或总结外部资料；每次只处理一个最小范围。
- 如果当天主线完全没推进，我又想做项目，请提醒我先完成一个最小主线任务。
- 输出使用 Obsidian Markdown + MathJax。
- 会话结束时，按 99_Meta/Templates/learning_close_5lines.md 把这次学习收口成 5 行，写进 50_LifeOps/Logs/Daily/今天日期.md 的「复盘」段下面。如果今天 Daily Note 不存在，先按 99_Meta/Templates/daily_note.md 创建一份，再追加 5 行；不要因为没有 Daily Note 就跳过收口。也不要让我自己改 02_今日状态 / 03_行动队列 / 05_复习入口 / 课程 progress 中的任何一个——5 行写进 Daily Note 就是收口。
```

## 如果今天要做作业

再加：

```text
今天做作业。题源必须来自真实作业或教材题，不要替我造题。先让我写尝试、思路或卡点，再给 Hint 1。
```

## 如果今天要学新内容

再加：

```text
今天学新内容。先把范围压到一个最小学习单元，再问我 3 个诊断问题。
```

## 如果今天要复习

再加：

```text
今天优先做行动队列里的到期复习。目标是不看提示重做（冷复测），不是重新看讲解。
```
