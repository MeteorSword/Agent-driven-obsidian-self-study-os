# Update Mission — v0.3 Fork 改动记录

> 记录所有在 v0.3 模板上做的改动，按时间顺序排列。
> 基线：v0.3 原版模板（kk 的 Agent-driven-obsidian-self-study-os v0.3）
> 对话时间跨度：2026-07-11 21:47 ~ 2026-07-13 18:31

---

## 2026-07-11 ~ 07-12 — 基线建立

- 从 SS_OS\SelfStudyOS（实际使用版）中分离出 184 个学习数据文件到 00_DataBackup/
- 数据分类：daily_notes(29) + sessions(29) + progress(8) + mistakes(8) + revision(3) + external_assets(107)
- 此操作在 SS_OS 上执行，不在 v0.3 上

---

## 2026-07-12 — 新增 agent-memory-write skill

- 路径：`skills/agent-memory-write/SKILL.md`
- 定位：写记忆的唯一入口，不是约束别人的旁观者
- 约束内嵌在流程里：每次写记忆都走这个 skill，不走工具自带的 autoMemory
- 包含：查重流程、feedback 文件格式模板、MEMORY.md 索引更新规则、Daily Note 记录规则
- 硬约束：只写 vault 内 AgentMemory、每条必须有 Why 和 How to apply、事件触发不预写、索引必须同步
- 读取规则：冷启动只读 MEMORY.md 索引，具体 feedback 按需读取；超过 15 条考虑分层

---

## 2026-07-12 — 10_Courses / Raw / CourseOS 三层分工重构

### 改动原因
- TEST_ISSUE #13：外层 Raw/ 和 CourseOS 内 raw/ 功能混淆
- 用户需求：课程资料需要一个统一的实体存放点
- 设计修正：两套 Raw 不是"重复"，而是功能不同（仓库 vs 工单），但之前没写清楚

### 改动清单

| 文件 | 改动 |
|------|------|
| `vault-template/10_Courses/README.md` | 重写：定位为课程资料实体仓库，按课程名+类型分目录，含和其他文件夹的关系表 |
| `vault-template/10_Courses/ExampleCourse/` | 新建：真题/PPT/教材/作业 四个子目录 + README |
| `vault-template/70_AgentSystems/SelfStudyOS/Raw/README.md` | 改写：非课程资料暂存区，明确"课程资料不放这里" |
| `vault-template/70_AgentSystems/SelfStudyOS/CourseOS/ExampleCourse/raw/material_queue.md` | 工单模板加 Path 字段指向 10_Courses，明确实体文件不放这里 |
| `docs/architecture.md` | 顶层模型注释从"课程资料和课程输出"改为"课程资料实体仓库（真题、PPT、教材、作业，按课程名分目录）" |
| `vault-template/70_AgentSystems/SelfStudyOS/System/raw_data_pipeline.md` | 外部资料策略改为资料放置规则；Capture 步骤改为明确路径规则 |
| `skills/selfstudyos-workflow/SKILL.md` | Material Intake 流程加路由步骤：课程资料→10_Courses，不放进 CourseOS/raw |
| `vault-template/01_LearningDesk/04_课程入口.md` | 课程资料说明改为指向 10_Courses |
| `vault-template/README.md` | 顶层目录说明同步更新 |

### 改动后的文件路由规则

```
课程资料 → 10_Courses/<课程名>/<类型>/
    ↓
CourseOS/<课程名>/raw/material_queue.md 建工单，指向上面的路径

非课程资料 → 70_AgentSystems/SelfStudyOS/Raw/<类型>/
    ↓
60_Resources/ExternalIndexes/external_material_index.md 建索引（可选）

纯外部大文件 → 不进 vault
    ↓
60_Resources/ExternalIndexes/external_material_index.md 建路径
```

### 审查结果
- 全文件扫描通过：无遗留的 Raw/courses 路径引用
- 无 2026Spring 旧路径格式残留
- 无"课程资料和课程输出"旧定位描述残留

---

## 2026-07-12 ~ 07-13 — 新增 agent-material-intake skill

- 路径：`skills/agent-material-intake/SKILL.md`
- 定位：文件归档的唯一入口
- 触发词：归档、把这个资料放进去、新增资料、材料入库
- 流程：判断类型 → 路由（课程→10_Courses，非课程→Raw）→ 建工单 → 报告 → Daily Note 记录
- 硬约束：实体文件不进 CourseOS/raw、不进 Raw/courses、每次必须走流程、不猜课程归属、不重命名
- 边界：只管归档，不管学习处理/写记忆/出题

---

## 2026-07-13 — 06_启动句加 skill 指针

- 在 `01_LearningDesk/06_给Agent的启动句.md` 的硬约束段加了两行指针
- agent-memory-write：写记忆时先读对应 skill，不使用工具自带 autoMemory
- agent-material-intake：归档文件时先读对应 skill，课程资料放 10_Courses

---

## 2026-07-13 — 新增 selfstudyos-course-workflow skill

- 路径：`skills/selfstudyos-course-workflow/SKILL.md`
- 定位：课程执行的入口，覆盖四个子模式
- 合并来源：prompts/02_course_session + 03_problem_loop + 09_course_review + 08_exam_sprint
- 四个子模式：开始学习 / 作业 / 复习 / 考试冲刺
- 不重复 operating_rules 里的规则定义，只定义执行步骤
- 考试冲刺模式已内置 study_plan 读取逻辑

---

## 2026-07-13 — 新增 study_plan 模板

- 路径：`vault-template/99_Meta/Templates/study_plan_template.md`
- 原因：用户实际使用中 study_plan 格式不统一（上午下午分不清、状态标记不一致），导致 AI 读取歧义
- 不是 skill，是模板。解决格式问题而非执行流程问题
- 统一：时段用 AM/PM/EVE + 24小时制、状态用 todo/in-progress/done/skip、重排记录单独一段、风险提示单独一段
- 使用场景：期末突击（不是学期日常学习），需要按日甚至按时段安排

---

## 待办（已讨论但未执行）

- [x] 06_启动句 加 agent-memory-write 和 agent-material-intake 的指针
- [x] agent-material-intake skill
- [x] selfstudyos-course-workflow skill
- [x] study_plan 模板（不是 skill，是模板）
- [x] prompts/ 目录清理（删 01-06/08-09 共 8 个，保留 07 周复盘，00 改写为简洁索引）
- [x] 三处启动入口合并（START_HERE_FOR_AGENT 已并入 06_给Agent的启动句.md，START_HERE 已删除）
- [x] 状态文件重叠清理（经验证 02/03/04/05 功能不重叠，无需改动）
- [x] operating_rules 精简（课程三模式/作业边界执行步骤移入 course-workflow skill，只留规则定义）

---

## 2026-07-18 — stage0 隐私清理 + workflow 精简

### 改动原因
- 消除 git 历史/vault 文件里的真实个人信息（邮箱、姓名、学校、科目+考试日期、真实路径）
- selfstudyos-workflow 与新 skill（agent-material-intake、selfstudyos-course-workflow）职能重叠，精简

### 改动清单

| 对象 | 改动 |
|------|------|
| AgentMemory/user_profile.md | 删除（画像职能移到 learner_profile.md；该文件含某高校名 + 科目+考试日期 + 真实路径）|
| AgentMemory 11 个 feedback | 合并为 6 个：learning_method / memory_and_maintenance / paths_and_format / completion_and_exam / circuit_methodology / migration_log（保留）|
| AgentMemory/MEMORY.md | 重写索引，user_profile 行改为指向 learner_profile.md，反映合并后结构 |
| feedback 文件内容 | 真实路径 `<YOUR_VAULT_PATH>` → `<YOUR_VAULT_PATH>`；科目名/考试日期/个人成绩 → 泛化表述；方法论语境保留 |
| feedback_memory_execution | 读取规则改为与 agent-memory-write skill 对齐（冷启动只读索引）|
| skills/selfstudyos-workflow/SKILL.md | 删 Material Intake 段、CourseOS 段；Daily Learning 中文化为 8 步（step 4 半强制复习提示、step 8 半强制复习触发）；ResearchWiki/ProjectLab 改 v1.0 占位符；description 更新分流说明 |
| SkillRegistry.md | selfstudyos-workflow 职能描述更新为精简后范围 |
| selfstudyos-workflow/README.md | 补「职能范围」段说明精简后职责 |
| 06_启动句 | 经检查不直接描述 selfstudyos-workflow 职能，且受「只追加不删改」规则约束，未改动 |

### 已完成（用户在本地 PowerShell 终端跑 git filter-repo）

- [x] **git 历史改写（任务1）**：sandbox 禁止写 .git 目录，改为用户在本地终端执行 git filter-repo。两轮重写后：6 个 commit 的 author 全部替换为 SelfStudyOS Contributor <noreply@example.com>，历史文件内容中的真实路径与旧邮箱已清除（git log -p 搜真实路径与旧邮箱关键词均无输出）。备份在 D:\SelfStudy\v0.3-backup-20260718。

---

## 2026-07-20 — stage1 结构清理

### 改动原因
- 三处启动入口（START_HERE_FOR_AGENT / 06_启动句）合并为单一入口 06
- operating_rules 精简为规则定义唯一 source of truth，执行步骤移入 skill
- prompts 目录清理冗余文件
- 遗留脱敏和 gitignore 补全

### 改动清单

| 文件 | 改动 |
|------|------|
| prompts/00_prompt_index.md | 改写为简洁索引，指向 06（日常学习）和 07（周复盘） |
| prompts/07_weekly_review.md | START_HERE 引用改为 06 |
| prompts/01-06,08-09 | 删除（已被 skill 覆盖），待用户终端执行 Remove-Item |
| 01_LearningDesk/06_给Agent的启动句.md | 合并 START_HERE 内容：Part1 启动句（硬约束精简为 3 条底线 + 规则引用）+ Part2 Agent 执行指南（必读顺序/默认判断/Daily Start/课程执行/资料归档/复习路由/Wiki-Lab占位/不允许/结束标准） |
| 70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md | 内容已并入 06，文件待用户终端删除 |
| operating_rules.md | 课程三模式改为引用 skill（保留掌握等级+桥接题/补丁标记）；作业边界改为引用 skill（保留归因区分）；项目许可规则改占位 |
| 10_Courses/README.md | 建议结构真实课程名替换为 ExampleCourse/AnotherCourse/YetAnotherCourse |
| .gitignore | 新增 TEST_ISSUE 1.md 条目 |
| README / vault-template/README / 01_LearningDesk/README / study_plan_template / AGENTS / home / SKILL / architecture / agent-rules / entry-separation / getting-started / windows-setup | 所有 START_HERE_FOR_AGENT 引用改为指向 01_LearningDesk/06_给Agent的启动句.md |
| docs/entry-separation.md | 重写入口分离描述（原说两入口分离，现合并为单一入口 06） |

### 待用户终端执行（sandbox 限制）

- 删除 prompts/01-06、08-09 共 8 个文件
- 删除 START_HERE_FOR_AGENT.md
- git rm --cached "TEST_ISSUE 1.md"
- git add -A + git commit
