# Changelog

## 0.3.0 - 2026-06-10

### 新增

- 新增 `prompts/09_course_review.md`：日常课程复习模式，用于冷复测、错题回看、间隔复习和概念查漏。
- CourseOS 模板升级为三模式入口：开始学习模式 / 作业模式 / 复习模式。
- 新增复习债务路由规则：复习债务默认只在复习模式展开；作业和开始学习只在直接阻塞当前任务时插入 3-10 分钟前置工具补丁。

### 改动

- Daily Start 不再把到期复习自动安排成热身，只提示有无到期复习并建议是否进入复习模式。
- `START_HERE_FOR_AGENT.md`、`operating_rules.md`、LearningDesk、公开 prompts、docs 和公开版 skill 同步三模式边界。
- 行动队列的 review stale 处理改为只在复习模式或明确队列维护时执行，避免打断作业模式。

## 0.2.0 - 2026-06-07

四块新增，全部来自真实使用反馈后的多轮内部评估。

### 新增

- **`01_LearningDesk/` 六张学生侧入口页面**（01_学习首页 / 02_今日状态 / 03_行动队列 / 04_课程入口 / 05_复习入口 / 06_给Agent的启动句）。学生从此只需打开 `01_LearningDesk/`，不再面对 `70_AgentSystems/`。
- **5 行收口模板** `99_Meta/Templates/learning_close_5lines.md` + `daily_note.md`，定义"每次 session 写 5 行进当天 Daily Note"的 canonical 收口仪式，替代手动维护 02/03/05/课程 progress 多文件。
- **`50_LifeOps/Logs/Daily/`** 目录骨架，5 行收口的落盘位置。
- **`docs/entry-separation.md`** 入口分离设计说明。
- **`docs/close-ritual.md`** 5 行收口设计说明。

### 改动

- **`START_HERE_FOR_AGENT.md`**：必读顺序加入 `01_LearningDesk/`；Daily Start 工作流加入 stale 规则；Course Learning 工作流要求识别学习/作业两类模式；结束标准改为引用 5 行收口模板。
- **`operating_rules.md`**：新增「学习/作业模式」「掌握等级（预热/桥接/作业题/变式）」「行动队列 stale 规则」「每日结束规则」四节；Hint 分层从"先给提示再给答案"细化到 Hint 1/2/3/Solution。
- **`SelfStudyOS/home.md`**：顶部加入「入口分离」段，说明用户侧 / agent 侧各打开哪里；「每天从这里开始」改为引用 `01_LearningDesk/`。
- **`CourseOS/ExampleCourse/ExampleCourse-MOC.md`**：重排为"学生段在上、agent 段在下"；agent 工作流明确标注「Agent 内部使用，不是学生入口」「填模板不等于学习」。
- **`CourseOS/ExampleCourse/concepts/concept_index.md`**：加入 `usable` vs `·占位` 状态约定，防止 AI 为了"补全"乱填空卡。

### 设计动机

这一版的所有改动针对早期用户跑通后浮现的三类问题：

1. 学生侧入口被 agent 配置淹没 → 入口分离。
2. 每次结束要手改 4-5 个文件 → 5 行收口。
3. 行动队列僵尸 P0 越积越多 → stale 规则。

## 0.1.0 - 2026-05-24

- 建立 `obsidian-self-study-os` 开源项目骨架。
- 加入 Vault 模板、prompt、Markdown 模板、公开版 agent workflow skill。
- 加入脱敏高数学习闭环示例。
- 加入隐私边界、快速开始、架构说明和发布检查清单。
- 加入 Windows 从零开始使用指南，并引用 Codex / Claude Code 官方安装文档。
