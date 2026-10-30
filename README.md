# Obsidian SelfStudyOS

An AI-agent-driven Obsidian self-study system for university learning, research exploration, and project-based growth.

面向大学生的 Obsidian 自学系统模板。课程学习、论文阅读、项目能力建设放在同一个 Vault 结构里。AI agent 按固定规则协助学习。

v1.0.0 是第一个正式版本。提供安装说明、版本索引与升级路径。公共模板与个人 Vault 分开。

## 与上游的关系

本项目 fork 自 [kkLullaby/Agent-driven-obsidian-self-study-os](https://github.com/kkLullaby/Agent-driven-obsidian-self-study-os)。

上游 v0.1 到 v0.3 提供了这些机制：入口分离、Hint 1/2/3 分层、5 行收口、stale 规则、复习债务路由。本 fork 的改动建立在这些设计之上。

| 能力 | 上游 v0.3 | 本 fork v1.0 |
|---|---|---|
| Agent 入口 | `START_HERE_FOR_AGENT.md` | `01_LearningDesk/06_给Agent的启动句.md` |
| 本地 skill | 1 个 | 6 个 |
| prompt 组织 | 9 个文件 | 收敛进 skill，仓库保留索引 |
| 路径引用 | 硬编码相对路径 | 路径变量表 |
| 资料分层 | Raw 与 CourseOS/raw 并存 | `10_Courses/` 原件、工单、Raw 三层 |
| 版本管理 | CHANGELOG 手写 | 版本索引与升级器 |

与上游 v0.3 的差异：55 个文件，+1,844 / −819 行。

`main` 保留上游 v0.1 到 v0.3 的提交历史。`gamma` 从 v0.3 文件快照起步，是 fork 的开发线。两条线历史不相交。对比请用 `git diff origin/main origin/gamma`。

## 这个项目解决什么问题

AI 学习工作流常见的失效方式：

- 资料被批量总结，没有练习证据。
- 笔记越来越多，下一步不知道学什么。
- 项目 demo 能跑，基础能力没有沉淀。
- AI 直接给答案，学习者没有形成可复用能力。
- 系统越搭越大，每天打开先看到一堆 agent 配置。

SelfStudyOS 的做法：agent 执行固定流程，学习者保留自己的尝试、判断、错因和复盘。日常入口压到一屏。

## 核心设计

1. **单一入口**：`01_LearningDesk/06_给Agent的启动句.md` 是唯一的 agent 入口。学生侧入口与 agent 执行指南在同一文件里，分上下两部分。
2. **Hint 分层与四模式**：作业模式按 Hint 1 到 Solution 逐层给。开始学习模式可以用桥接题，桥接不计掌握。复习模式优先冷复测。考试冲刺按分值与可提升空间排序。详见 [`docs/agent-rules.md`](docs/agent-rules.md)。
3. **5 行收口**：每次 session 结束，agent 只写 5 行进当天 Daily Note。详见 [`docs/close-ritual.md`](docs/close-ritual.md)。
4. **stale 规则与占位卡**：行动队列里的逾期任务按类型治理。候选概念卡标 `·占位`。
5. **复习债务路由**：Daily Start 只提示有无到期复习。复习债务默认只在复习模式展开。

## 核心结构

```text
vault-template/
  01_LearningDesk/                 # 学生侧唯一入口，每天只打开这里
    01_学习首页.md
    02_今日状态.md
    03_行动队列.md
    04_课程入口.md
    05_复习入口.md
    06_给Agent的启动句.md
  05_Templates/                    # 全部模板，Obsidian 模板目录指向这里
  50_LifeOps/Logs/Daily/           # 每天一份 Daily Note，5 行收口落盘处
  70_AgentSystems/
    AgentBootstrap/
      SkillRegistry.md             # agent 技能注册表
    SelfStudyOS/
      AGENTS.md
      home.md
      System/
        operating_rules.md         # 规则唯一定义处，路径变量表，题号格式
        learner_profile.md
        raw_data_pipeline.md
      CourseOS/                    # 课程、作业、错题、概念、题型
      ResearchWiki/                # 论文、研究概念、连接、开放问题
      ProjectLab/                  # 项目目标、能力树、项目复盘
      Review/                      # 总进度、复习债务、错题索引
  99_Meta/
    SelfStudyOS_Version.md         # 版本标识与升级约定
    README.md                      # 该目录放什么
```

完整可复制模板在 [`vault-template/`](vault-template/)。

## 快速开始

1. 复制 [`vault-template/`](vault-template/) 到你的 Obsidian Vault。
2. 改 `01_LearningDesk/01_学习首页.md` 的当前主线表，改 `02_今日状态.md` 和 `03_行动队列.md`，填入正在学的课。
3. 改 `70_AgentSystems/SelfStudyOS/System/learner_profile.md`，写自己的画像。
4. 改 `70_AgentSystems/SelfStudyOS/Review/progress.md`，写当前进度。
5. 把 [`vault-template/01_LearningDesk/06_给Agent的启动句.md`](vault-template/01_LearningDesk/06_给Agent的启动句.md) 里的启动句复制给 AI agent，替换 `${YOUR_VAULT_PATH}`。
6. 先选模式（开始学习 / 作业 / 复习 / 考试冲刺），再选一个最小任务（一节课的一个概念、2 到 5 道题、一个复习对象）。结束时让 agent 按 5 行收口写进当天 Daily Note。

更细的步骤见 [`docs/getting-started.md`](docs/getting-started.md)。Windows 用户从 [`docs/windows-setup.md`](docs/windows-setup.md) 开始。

## 三条主线

- **CourseOS**：课程学习要有证据。包括独立尝试、做题、错因、复述、下一步训练。进入课程先区分四种模式：开始学习、作业、复习、考试冲刺。掌握分 4 级：预热通过、桥接通过、作业题通过、变式通过。真题由 `agent-exam-mapping` skill 按知识点索引。
- **ResearchWiki**：v1.1 计划。
- **ProjectLab**：v1.1 计划。

## Skill 体系

v1.0 有 6 个本地 skill。

| Skill | 职责 | 触发说法 |
|---|---|---|
| selfstudyos-workflow | 日常调度：选任务、确认状态、半强制复习触发 | 开始新的一天 / 今天干什么 |
| selfstudyos-course-workflow | 课程执行：开始学习、作业、复习、考试冲刺 | 学新内容 / 做题 / 复习 / 考试冲刺 |
| agent-material-intake | 文件归档：课程资料进 `10_Courses`，其它进 `Raw` | 归档 / 放进 vault |
| agent-memory-write | 写记忆：feedback 查重、模板、MEMORY 索引同步 | 写记忆 / 记下来 |
| agent-exam-mapping | 真题按知识点索引 | 索引真题 / 真题映射 |
| agent-weekly-review | 周复盘：读本周证据，对照 6 个问题，连续虚假进展预警 | 周复盘 / weekly review |

skill 之间靠用户确认衔接，不自动串联。路径引用统一用 `${VARIABLE_NAME}` 变量。详见 [`docs/platform-integration.md`](docs/platform-integration.md)。

## 版本与升级

每个版本一份索引，在 `migrations/index-<版本>.json`。`.md` 是同一份数据的树形版，人读。

库里的机器真值是 `.selfstudyos/index.json`。它记录每个框架文件的路径、归属、sha256 与上次修改版本。没有这个目录的库属于 v1.0 之前。

升级用 `scripts/upgrade.ps1`。默认干跑，列出新增、覆盖、重写、待删四类。加 `-Apply` 才写文件，写之前备份到 `.selfstudyos/backup/`，`-Rollback` 可还原。

旧库用 `scripts/migrate-v0.3-to-v1.0.ps1` 做一次性迁移，只读扫描，输出 `ai-handoff/` 五个文件。迁移完成后跑 `scripts/bootstrap-index.ps1` 建索引，跑 `scripts/verify-vault.ps1` 自检。

## 硬规则

- 不把 raw 资料直接当成学习成果。
- 不一次性 ingest 整本书、整门课、整批论文。
- 学习者没有尝试之前，不直接做作业题。
- 桥接题不计入掌握证据。
- 复习债务默认只在复习模式展开。作业模式和开始学习模式只在直接阻塞当前任务时插入 3 到 10 分钟前置工具补丁。
- 不为了 Obsidian 图谱好看创建空链接。候选卡必须标 `·占位`。
- 不用项目 demo 掩盖基础课训练缺口。
- 学生不手改 02 / 03 / 05 与课程 progress。agent 用 5 行收口写进 Daily Note。

## 仓库内容

```text
docs/           # 设计说明、平台集成、版本记录、外部引用清单
prompts/        # prompt 资产索引，日常入口已迁至 06_给Agent的启动句
migrations/     # 每个版本一份索引，json 给机器，md 给人
vault-template/ # 可复制到 Obsidian 的 Vault 骨架，05_Templates 内含全部模板
skills/         # 6 个本地 skill
scripts/        # gen-index / migrate-v0.3-to-v1.0 / bootstrap-index / upgrade / verify-vault / preflight
examples/       # 脱敏学习闭环示例
```

## 改动记录与接口

- 版本记录：[`CHANGELOG.md`](CHANGELOG.md)
- 平台集成接口：[`docs/platform-integration.md`](docs/platform-integration.md)
- Skill 外部引用清单：[`docs/skill-reference-inventory.md`](docs/skill-reference-inventory.md)

## 不包含什么

这个仓库不包含：

- 个人课程 PDF、PPT、作业原件
- 私人生活日志、任务清单、访谈记录
- 本机绝对路径和外部资料索引
- API key、token、账号、邮箱列表
- 未脱敏的学习进度和个人画像
- 真实 Daily Note 内容，`.gitignore` 已排除 `50_LifeOps/Logs/Daily/2*.md`

公开前检查见 [`docs/publish-checklist.md`](docs/publish-checklist.md)。开源范围说明见 [`docs/open-source-scope.md`](docs/open-source-scope.md)。

## 示例

[`examples/calculus-loop/`](examples/calculus-loop/) 是脱敏的高数学习闭环示例。展示从学习 session 到 problem loop、错因归纳、概念卡更新的最小流程。

## Acknowledgements

Inspired by Erber's [如何用AI学会所有东西：基于Obsidian+Claude Code的个人知识库构建](https://zhuanlan.zhihu.com/p/2033334385555010512) by [Erber102](https://github.com/Erber102).

Forked from [kkLullaby/Agent-driven-obsidian-self-study-os](https://github.com/kkLullaby/Agent-driven-obsidian-self-study-os).

## Citations

Erber. (2026). 如何用AI学会所有东西：基于Obsidian+Claude Code的个人知识库构建. Zhihu. https://zhuanlan.zhihu.com/p/2033334385555010512

## License

MIT License. See [`LICENSE`](LICENSE).
