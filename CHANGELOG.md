# Changelog

本文件是唯一的版本记录。上游 v0.1.0–v0.3.0 由 kkLullaby发布，之后由 MeteorSword 以 fork 形式继续演进。

## 1.0.0

第一个正式版本。

### 新增

- 版本索引：`migrations/index-<版本>.json` 记录每个框架文件的路径、归属、sha256 与上次修改版本，`.md` 是同数据的树形版。
- 归属分类：文件分 owned、seeded、opaque。owned 可更新，seeded 只报差异，opaque 目录整块归用户。
- 一次性迁移器：`scripts/migrate-v0.3-to-v1.0.ps1` 只读扫描旧 Vault，输出 `ai-handoff/` 五个文件。
- 通用升级器：`scripts/upgrade.ps1` 比对两份索引，列出新增、覆盖、重写、待删四类；默认干跑，`-Apply` 前备份，`-Rollback` 可还原。
- 迁移后工具：`scripts/bootstrap-index.ps1` 给已迁移的库建立索引；`scripts/verify-vault.ps1` 检查必需文件、旧路径残留与索引一致性。
- 安装契约：`docs/install.md`，四条安装路径，三个验证信号，30 分钟冒烟测试。
- 发布前检查：`scripts/preflight.ps1`，检查绝对路径、邮箱、手机号、学号、大文件、断引用。
- 平台入口文件：`AGENTS.md`、`CLAUDE.md`。
- 课程档案：`CourseOS/<课程名>/course_profile.md`，记录资料源、页码口径、记号、勘误、不考范围、产物位置。
- 资料工单模板：`05_Templates/material_queue.md`。
- 考试冲刺模式入口块。

### 改动

- Agent 入口改为三段式：冷启动协议、手动粘贴块、四个模式块。
- 规则以 `operating_rules.md` 为唯一定义处，其余文件引用它。
- 掌握等级统一为 4 级，`05_复习入口.md` 的 5 级判定改为映射表。
- 模板收拢到 `05_Templates/`。
- 资料工单拆为资料台账与处理队列两张表：整体一行，个体一行，队列行用 `From` 指向台账编号。
- 课程原件归位到 `10_Courses/<课程名>/<类型>/`。
- README 增加上游关系段。
- 版本号统一为 1.0.0。

### 移除

- `Update_mission.md`。
- `docs/changelog-gamma.md`。
- `START_HERE_FOR_AGENT.md`，内容并入 `01_LearningDesk/06_给Agent的启动句.md`。
- 指向已删除 prompt 文件的链接。

## 0.95（fork 内部预发布，未对外发布）

> 即原来的 v0.3 Gamma 分支定稿，本地 tag `v0.95`。这一版是六轮迭代的结果，但从未对外发布。

- **单一入口**：`START_HERE_FOR_AGENT.md` 并入 `01_LearningDesk/06_给Agent的启动句.md`，删除重复入口。
- **skill 体系**：1 个 skill 扩展为 6 个（workflow / course-workflow / material-intake / memory-write / exam-mapping / weekly-review），9 个 prompt 文件收敛进 skill。
- **路径变量化**：新增路径变量表，skill 与文档不再写死路径。
- **题号格式**：会话内 `Q1/Q2` 与持久化来源格式（`Exam-2024-Q3`、`Textbook-3.2-5`）的转换规则。
- **真题映射**：新增 `exam_topic_index`，按知识点索引真题考法。
- **周复盘**：三个文件里的问题清单收敛为 `System/weekly_review.md` 唯一定义，并由 skill 执行。
- **资料三层分工**：`10_Courses/`（实体文件）/ `material_queue.md`（工单）/ `Raw/`（非课程资料）。
- **隐私清理**：清除历史中的真实邮箱与本机路径，删除个人画像文件，课程名脱敏为 `ExampleCourse`。

## 0.3.0 — 2026-06-10（上游 kkLullaby）

### 新增

- 新增 `prompts/09_course_review.md`：日常课程复习模式，用于冷复测、错题回看、间隔复习和概念查漏。
- CourseOS 模板升级为三模式入口：开始学习模式 / 作业模式 / 复习模式。
- 新增复习债务路由规则：复习债务默认只在复习模式展开；作业和开始学习只在直接阻塞当前任务时插入 3-10 分钟前置工具补丁。

### 改动

- Daily Start 不再把到期复习自动安排成热身，只提示有无到期复习并建议是否进入复习模式。
- `START_HERE_FOR_AGENT.md`、`operating_rules.md`、LearningDesk、公开 prompts、docs 和公开版 skill 同步三模式边界。
- 行动队列的 review stale 处理改为只在复习模式或明确队列维护时执行，避免打断作业模式。

## 0.2.0 — 2026-06-07（上游 kkLullaby）

四块新增，全部来自真实使用反馈后的多轮内部评估。

### 新增

- **`01_LearningDesk/` 六张学生侧入口页面**（01_学习首页 / 02_今日状态 / 03_行动队列 / 04_课程入口 / 05_复习入口 / 06_给Agent的启动句）。学生从此只需打开 `01_LearningDesk/`，不再面对 `70_AgentSystems/`。
- **5 行收口模板** `05_Templates/learning_close_5lines.md` + `daily_note.md`，定义"每次 session 写 5 行进当天 Daily Note"的 canonical 收口仪式，替代手动维护 02/03/05/课程 progress 多文件。
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

## 0.1.0 — 2026-05-24（上游 kkLullaby）

- 建立 `obsidian-self-study-os` 开源项目骨架。
- 加入 Vault 模板、prompt、Markdown 模板、公开版 agent workflow skill。
- 加入脱敏高数学习闭环示例。
- 加入隐私边界、快速开始、架构说明和发布检查清单。
- 加入 Windows 从零开始使用指南，并引用 Codex / Claude Code 官方安装文档。
