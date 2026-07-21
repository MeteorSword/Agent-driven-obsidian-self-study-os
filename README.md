# Obsidian SelfStudyOS

An AI-agent-driven Obsidian self-study system for university learning, research exploration, and project-based growth.

这是一个面向大学生的 Obsidian 自学系统模板。它把课程学习、论文阅读、项目能力建设放进同一个可维护的 Vault 结构里，并让 AI agent 按固定规则协助你学习，而不是替你学习。

> **v0.3 Gamma 分支定位**：本仓库是项目基座，提供开发标准和封装好的模块。skill 和 prompt 是 AI 可读的原型规格，供生态开发者基于此搭建。详见 [`docs/interfaces-gamma.md`](docs/interfaces-gamma.md)。

## 这个项目解决什么问题

很多 AI 学习工作流的问题不是"AI 不够强"，而是缺少边界：

- 资料被批量总结，但没有练习证据。
- 笔记越来越多，但不知道下一步该学什么。
- 项目 demo 能跑，但基础能力没有沉淀。
- AI 直接给答案，学习者没有形成可复用能力。
- 系统结构越搭越大，学生每天打开后被一堆"agent 配置"吓退，不知从哪开始。

SelfStudyOS 的核心目标是：让 AI agent 成为学习系统的执行伙伴，同时**保留学习者自己的尝试、判断、错因和复盘**，并把日常入口压缩到学生看一眼就知道做什么。

## 核心设计

五个相互独立又互相支撑的机制：

1. **单一入口（Single Entry）** — `01_LearningDesk/06_给Agent的启动句.md` 是唯一的 agent 入口，合并了原 START_HERE_FOR_AGENT 的全部内容。学生侧入口和 agent 执行指南在同一文件，分上下两部分。
2. **Hint 分层 + 三模式区分** — 作业模式严格按 Hint 1 → 2 → 3 → Solution；开始学习模式可以用桥接题但**桥接不计掌握**；复习模式优先冷复测。详见 [`docs/agent-rules.md`](docs/agent-rules.md)。
3. **5 行收口仪式（Close Ritual）** — 每次 session 结束 agent 只写 5 行进当天 Daily Note，替代手动维护 02/03/05/progress 多个状态文件。详见 [`docs/close-ritual.md`](docs/close-ritual.md)。
4. **stale 规则 + 占位卡** — 行动队列里逾期任务按类型治理；候选概念卡显式标 `·占位` 防止 AI 为了"补全"乱填。
5. **复习债务路由** — Daily Start 只提示有无到期复习；复习债务默认只在复习模式展开，不打断作业和随堂学习。

## 核心结构

```text
vault-template/
  01_LearningDesk/                 # 学生侧唯一入口（每天只打开这里）
    01_学习首页.md
    02_今日状态.md
    03_行动队列.md
    04_课程入口.md
    05_复习入口.md
    06_给Agent的启动句.md
  50_LifeOps/Logs/Daily/           # 每天一份 Daily Note，5 行收口落盘处
  70_AgentSystems/
    AgentBootstrap/
      SkillRegistry.md             # agent 技能注册表
    SelfStudyOS/
      AGENTS.md
      home.md
      System/
        operating_rules.md         # 规则定义唯一 source of truth / 路径变量表 / 题号格式
        learner_profile.md
        raw_data_pipeline.md
      CourseOS/                    # 课程、作业、错题、概念、题型
      ResearchWiki/                # 论文、研究概念、连接、开放问题
      ProjectLab/                  # 项目目标、能力树、项目复盘
      Review/                      # 总进度、复习债务、错题索引
  99_Meta/Templates/
    learning_close_5lines.md       # 5 行收口模板（canonical）
    daily_note.md
```

完整可复制模板在 [`vault-template/`](vault-template/)。

## 快速开始

1. 复制 [`vault-template/`](vault-template/) 到你的 Obsidian Vault。
2. 改 `01_LearningDesk/01_学习首页.md` 的「当前主线」表 + `02_今日状态.md` + `03_行动队列.md`，填你正在学的课。
3. 改 `70_AgentSystems/SelfStudyOS/System/learner_profile.md` 写你自己的画像。
4. 改 `70_AgentSystems/SelfStudyOS/Review/progress.md` 写当前真实进度。
5. 把 [`vault-template/01_LearningDesk/06_给Agent的启动句.md`](vault-template/01_LearningDesk/06_给Agent的启动句.md) 里的启动句复制给 AI agent（替换 `${YOUR_VAULT_PATH}`）。
6. 先选择模式（开始学习 / 作业 / 复习），再选择一个最小学习任务开始（一节课的一个概念、2-5 道题，或一个复习对象），结束时让 agent 按 5 行收口写进当天 Daily Note。

更详细的步骤见 [`docs/getting-started.md`](docs/getting-started.md)。

Windows 用户可以从 [`docs/windows-setup.md`](docs/windows-setup.md) 开始，里面包含 Obsidian、Git、Codex/Claude Code 和路径配置说明。

## 三条主线

- **CourseOS**：课程学习必须有证据，包括独立尝试、做题、错因、复述和下一步训练。进入课程先区分开始学习模式 / 作业模式 / 复习模式。掌握分 4 级：预热通过 / 桥接通过 / 作业题通过 / 变式通过。真题可通过 agent-exam-mapping skill 按知识点索引，学习内容围绕真题考法反推。
- **ResearchWiki**：v1.0 占位。当前版本不提供研究工作流支持。
- **ProjectLab**：v1.0 占位。当前版本不提供项目工作流支持。

## Skill 体系

v0.3 Gamma 分支有 6 个本地 skill，形成日常学习的完整闭环：

| Skill | 职责 | 触发方式 |
|-------|------|---------|
| selfstudyos-workflow | 日常学习调度：选任务、确认状态、半强制复习触发 | "开始新的一天""今天干什么" |
| selfstudyos-course-workflow | 课程执行：开始学习/作业/复习/考试冲刺四子模式 | "学新内容""做题""复习""考试冲刺" |
| agent-material-intake | 文件归档：路由课程资料到 10_Courses，非课程资料到 Raw | "归档""放进 vault" |
| agent-memory-write | 写记忆：feedback 查重、格式模板、MEMORY 索引同步 | "写记忆""记下来" |
| agent-exam-mapping | 真题按知识点索引：读真题内容标注知识点/考法/难度 | "索引真题""真题映射" |
| agent-weekly-review | 周复盘：读本周证据，对照 6 个问题诚实复盘，连续虚假进展预警 | "周复盘""weekly review" |

skill 间通过用户确认衔接，不自动串联。路径引用全部使用 `${VARIABLE_NAME}` 格式的路径变量，适配其他平台只需注入变量值。详见 [`docs/interfaces-gamma.md`](docs/interfaces-gamma.md)。

## 硬规则

- 不把 raw 资料直接当成学习成果。
- 不一次性 ingest 整本书、整门课、整批论文。
- 不在学习者没有尝试前直接做作业题。
- 桥接题不计入掌握证据。
- 复习债务默认只在复习模式展开；作业模式和开始学习模式只在直接阻塞当前任务时插入 3-10 分钟前置工具补丁。
- 不为了 Obsidian 图谱好看创建空链接；候选卡必须显式标 `·占位`。
- 不用项目 demo 掩盖基础课训练缺口。
- 学生不手改 02 / 03 / 05 / 课程 progress；agent 用 5 行收口写进 Daily Note。

## 仓库内容

```text
docs/           # 设计说明、接口文档、改动记录、外部引用清单
prompts/        # 周复盘 prompt + 索引（日常学习入口已迁至 06_给Agent的启动句）
templates/      # 可复用 Markdown 模板
vault-template/ # 可复制到 Obsidian 的 Vault 骨架
skills/         # 6 个本地 skill（workflow/course-workflow/material-intake/memory-write/exam-mapping/weekly-review）
examples/       # 脱敏学习闭环示例
```

## 改动记录与接口

- 改动总结（按方面 + 时间线）：[`docs/changelog-gamma.md`](docs/changelog-gamma.md)
- 接口文档（触发/协作/数据/封装）：[`docs/interfaces-gamma.md`](docs/interfaces-gamma.md)
- Skill 外部引用清单：[`docs/skill-reference-inventory.md`](docs/skill-reference-inventory.md)

## 不包含什么

这个仓库不会包含：

- 个人课程 PDF、PPT、作业原件
- 私人生活日志、任务清单、访谈记录
- 本机绝对路径和外部资料索引
- API key、token、账号、邮箱列表
- 未脱敏的学习进度和个人画像
- 真实 Daily Note 内容（`.gitignore` 已排除 `50_LifeOps/Logs/Daily/2*.md`）

公开前检查清单见 [`docs/publish-checklist.md`](docs/publish-checklist.md)。

完整开源范围说明见 [`docs/open-source-scope.md`](docs/open-source-scope.md)。

## 示例

[`examples/calculus-loop/`](examples/calculus-loop/) 提供了一个脱敏的"高数学习闭环"示例，展示从学习 session 到 problem loop、错因归纳、概念卡更新的最小流程。

## Acknowledgements

Inspired by Erber's [如何用AI学会所有东西：基于Obsidian+Claude Code的个人知识库构建](https://zhuanlan.zhihu.com/p/2033334385555010512) by [Erber102](https://github.com/Erber102).

## Citations

Erber. (2026). 如何用AI学会所有东西：基于Obsidian+Claude Code的个人知识库构建. Zhihu. https://zhuanlan.zhihu.com/p/2033334385555010512

## License

MIT License. See [`LICENSE`](LICENSE).
