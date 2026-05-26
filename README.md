# Obsidian SelfStudyOS

An AI-agent-driven Obsidian self-study system for university learning, research exploration, and project-based growth.

这是一个面向大学生的 Obsidian 自学系统模板。它把课程学习、论文阅读、项目能力建设放进同一个可维护的 Vault 结构里，并让 AI agent 按固定规则协助你学习，而不是替你学习。

## 这个项目解决什么问题

很多 AI 学习工作流的问题不是“AI 不够强”，而是缺少边界：

- 资料被批量总结，但没有练习证据。
- 笔记越来越多，但不知道下一步该学什么。
- 项目 demo 能跑，但基础能力没有沉淀。
- AI 直接给答案，学习者没有形成可复用能力。

SelfStudyOS 的核心目标是：让 AI agent 成为学习系统的执行伙伴，同时保留学习者自己的尝试、判断、错因和复盘。

## 核心结构

```text
SelfStudyOS/
  CourseOS/        # 课程、作业、错题、概念、题型
  ResearchWiki/    # 论文、研究概念、连接、开放问题
  ProjectLab/      # 项目目标、能力树、项目复盘
  System/          # 运行规则、学习者画像、raw data 流程
  Templates/       # session、problem loop、reading mission 等模板
  Review/          # 总进度、复习债务、错题索引
```

完整可复制模板在 [`vault-template/`](vault-template/)。

## 快速开始

1. 复制 [`vault-template/`](vault-template/) 到你的 Obsidian Vault。
2. 打开 [`vault-template/70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md`](vault-template/70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md)。
3. 根据你的实际情况改写 `learner_profile.md` 和 `progress.md`。
4. 从 [`prompts/01_general_start.md`](prompts/01_general_start.md) 复制启动 prompt 给你的 AI agent。
5. 只选择一个最小学习任务开始，例如“一节课的一个概念”或“2-5 道题”。

更详细的步骤见 [`docs/getting-started.md`](docs/getting-started.md)。

Windows 用户可以从 [`docs/windows-setup.md`](docs/windows-setup.md) 开始，里面包含 Obsidian、Git、Codex/Claude Code 和路径配置说明。

## 三条主线

- **CourseOS**：课程学习必须有证据，包括独立尝试、做题、错因、复述和下一步训练。
- **ResearchWiki**：论文阅读必须先有 Reading Mission，大多数论文只读到 L0/L1，不做无目的深挖。
- **ProjectLab**：项目必须暴露能力债务，记录 AI 代劳部分，并映射回基础课程或具体技能。

## 硬规则

- 不把 raw 资料直接当成学习成果。
- 不一次性 ingest 整本书、整门课、整批论文。
- 不在学习者没有尝试前直接做作业题。
- 不为了 Obsidian 图谱好看创建空链接。
- 不用项目 demo 掩盖基础课训练缺口。

## 仓库内容

```text
docs/           # 设计说明、快速开始、工作流、隐私边界
prompts/        # 可复制给 AI agent 的 prompt
templates/      # 可复用 Markdown 模板
vault-template/ # 可复制到 Obsidian 的 Vault 骨架
skills/         # Codex/agent 可用的公开版 workflow skill
examples/       # 脱敏学习闭环示例
```

## 不包含什么

这个仓库不会包含：

- 个人课程 PDF、PPT、作业原件
- 私人生活日志、任务清单、访谈记录
- 本机绝对路径和外部资料索引
- API key、token、账号、邮箱列表
- 未脱敏的学习进度和个人画像

公开前检查清单见 [`docs/publish-checklist.md`](docs/publish-checklist.md)。

完整开源范围说明见 [`docs/open-source-scope.md`](docs/open-source-scope.md)。

## 示例

[`examples/calculus-loop/`](examples/calculus-loop/) 提供了一个脱敏的“高数学习闭环”示例，展示从学习 session 到 problem loop、错因归纳、概念卡更新的最小流程。

## Acknowledgements 

Inspired by Erber&#39;s [如何用AI学会所有东西：基于Obsidian+Claude Code的个人知识库构建](https://zhuanlan.zhihu.com/p/2033334385555010512) by [Erber102](https://github.com/Erber102).  

## Citations
Erber. (2026). 如何用AI学会所有东西：基于Obsidian+Claude Code的个人知识库构建. Zhihu. https://zhuanlan.zhihu.com/p/2033334385555010512  

## License

MIT License. See [`LICENSE`](LICENSE).
