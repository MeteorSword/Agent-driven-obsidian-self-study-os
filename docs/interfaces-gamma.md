# v0.3 Gamma 分支接口文档

> 本文件总结 v0.3 的四层接口，着重封装接口（给 kk 平台适配用）。

---

## 一、Skill 触发接口（用户怎么激活每个 skill）

用户通过自然语言激活 skill。AI 读 description 做语义匹配决定加载哪个。

| Skill | 触发场景 |
|-------|---------|
| selfstudyos-workflow | 用户说"开始新的一天""今天干什么""查看进度""需要学习调度" |
| selfstudyos-course-workflow | 用户说"学新内容""做题""作业""复习""冷复测""错题订正""考试冲刺" |
| agent-material-intake | 用户丢文件/截图/PDF/PPT，或说"归档""把这个资料放进去""新增资料""材料入库" |
| agent-memory-write | 用户说"写记忆""记下来""记住这个""新增 feedback""经验归档" |
| agent-exam-mapping | 用户说"索引真题""真题拆知识点""标注真题考法""真题映射" |
| agent-weekly-review | 用户说"周复盘""每周复盘""weekly review""本周回顾" |

设计原则：workflow 管调度，course-workflow 管执行，两个 description 的触发范围不重叠。其余 4 个 skill 各自独占一个场景，无重叠。

---

## 二、Skill 间协作接口（谁交接给谁）

skill 间通过"用户确认"衔接，不自动串联。

| 上游 Skill | 下游 Skill | 交接方式 |
|-----------|-----------|---------|
| selfstudyos-workflow | selfstudyos-course-workflow | workflow Daily Learning step7 选定课程后交接给 course-workflow 对应子模式执行 |
| selfstudyos-workflow | selfstudyos-course-workflow | workflow Daily Learning step8 半强制复习触发，用户选"现在"则交接给 course-workflow 复习模式 |
| agent-material-intake | agent-exam-mapping | material-intake 归档真题后提示"是否建立知识点索引"，用户同意后调用 exam-mapping |
| selfstudyos-course-workflow | agent-memory-write | course-workflow 收口时如需写记忆，调用 memory-write |

不自动串联的理由：让用户保持控制权，避免 skill 链式触发导致用户不知道发生了什么。

---

## 三、Skill 和 Vault 文件的数据接口（每个 skill 读写哪些文件）

完整清单见 `docs/skill-reference-inventory.md`。按读写分类：

### 读取（只读不写）

| Skill | 读取的文件 |
|-------|----------|
| workflow | ${REVIEW_PROGRESS}、${TODAY_STATUS}、${ACTION_QUEUE}、${MATERIAL_QUEUE}、${STARTUP_PROMPT}、${AGENTS}、${HOME}、${LEARNER_PROFILE}、${OPERATING_RULES} |
| course-workflow | ${TODAY_STATUS}、${COURSE_MOC}、${MATERIAL_QUEUE}、${EXAM_TOPIC_INDEX}、${REVIEW_ENTRY}、${REVISION_NOTES}、${STUDY_PLAN}、${OPERATING_RULES}、${LEARNING_CLOSE_5LINES} |
| agent-exam-mapping | ${EXAM_TOPIC_INDEX}（读现有索引）、${CONCEPT_INDEX} |
| agent-weekly-review | ${DAILY_NOTE_DIR}（读本周收口）、${REVIEW_PROGRESS}、${WEEKLY_REVIEW}、${TODAY_STATUS} |

### 写入（创建或更新）

| Skill | 写入的文件 |
|-------|----------|
| course-workflow | ${TODAY_STATUS}（主线变更）、${ACTION_QUEUE}（status 更新）、${REVISION_NOTES}（新复习债务）、课程 progress（新题号/错因）、错题卡、${DAILY_NOTE_DIR}（5 行收口） |
| agent-material-intake | ${MATERIAL_QUEUE}（工单新增）、${EXTERNAL_MATERIAL_INDEX}（非课程资料索引）、${DAILY_NOTE_DIR}（归档记录） |
| agent-memory-write | ${MEMORY_INDEX}（索引更新）、${AGENT_MEMORY_DIR}（新建/追加 feedback）、${DAILY_NOTE_DIR}（记忆记录） |
| agent-exam-mapping | ${EXAM_TOPIC_INDEX}（索引更新）、${CONCEPT_INDEX}（新建占位概念卡）、${DAILY_NOTE_DIR}（映射记录） |
| agent-weekly-review | ${DAILY_NOTE_DIR}（复盘报告）、${REVIEW_PROGRESS}（阶段/预警更新）、${TODAY_STATUS}（主线变更） |
| workflow | 无直接写入（交接给 course-workflow 执行） |

---

## 四、封装接口（给 kk 平台适配用）★ 重点

### 4.1 路径变量表：唯一的路径注入点

v0.3 所有 skill 和文档引用 vault 内文件时，使用 `${VARIABLE_NAME}` 格式的路径变量，不写死路径。路径变量在 `${OPERATING_RULES}` 的"路径变量表"段定义一次，全项目引用。

**封装适配只需做一件事**：把路径变量表的 24 个变量注入实际值。

| 变量 | v0.3 里的值（Obsidian vault 路径） | kk 平台适配时 |
|------|--------------------------------------|--------------|
| ${YOUR_VAULT_PATH} | vault 根路径 | 替换为目标平台的根路径或项目目录 |
| ${TODAY_STATUS} | 01_LearningDesk/02_今日状态.md | 替换为目标平台的状态文件路径或数据接口 |
| ${ACTION_QUEUE} | 01_LearningDesk/03_行动队列.md | 同上 |
| ${OPERATING_RULES} | 70_AgentSystems/.../operating_rules.md | 替换为目标平台的规则文件路径或内存加载 |
| ${DAILY_NOTE_DIR} | 50_LifeOps/Logs/Daily/ | 替换为目标平台的日志目录或日志 API |
| ${AGENT_MEMORY_DIR} | 70_AgentSystems/AgentMemory/ | 替换为目标平台的记忆存储路径或数据库 |
| ... | （共 24 个，见 operating_rules.md 路径变量表段） | |

**适配方式有两种**：

- **文件系统适配**（Obsidian 模式）：变量值就是实际文件路径，AI 用文件读写操作。
- **API 适配**（平台模式）：变量值是 API endpoint 或数据结构 key，AI 通过 API 读写。skill 正文不用改，只改变量表的值。

### 4.2 Skill 目录结构：标准的 SKILL.md + 可选子目录

每个 skill 的目录结构：

```
skills/<skill-name>/
  SKILL.md              ← 必须存在，skill 主体内容
  references/           ← 可选，放 skill 引用的规则文档副本
  assets/               ← 可选，放 skill 引用的模板文件副本
```

当前 v0.3 的 6 个 skill 目录下只有 SKILL.md，没有 references/ 和 assets/。这是 B 类适配项（等 kk 定平台后决定是否打包）。

**封装适配时**：kk 可参考 `docs/skill-reference-inventory.md` 知道每个 skill 引用了哪些外部文件，决定是复制进 skill 目录（自包含）还是用路径变量指向（依赖外部）。

### 4.3 规则与执行分离：CLAUDE.md 对应

v0.3 的设计把"规则定义"和"执行步骤"分离：

| v0.3 的文件 | 角色 | 对应 Claude Code | 对应通用平台 |
|-----------|------|-----------------|-------------|
| operating_rules.md | 规则定义（always loaded） | CLAUDE.md | 项目级配置文件 |
| 06_给Agent的启动句.md | 启动入口 + 执行指南 | 启动 prompt | 启动入口 |
| 6 个 skill 的 SKILL.md | 执行步骤（when triggered） | Skills | 任务级工作流 |

**封装适配时**：kk 需要决定 operating_rules.md 怎么加载。Obsidian 模式下 AI 冷启动时读它；平台模式下可能需要预加载到 system prompt 或配置文件。

### 4.4 Skill 间协作：用户确认衔接，不自动串联

所有 skill 间协作通过用户确认触发，没有自动链式调用。

**封装适配时**：kk 的平台如果有编排能力（workflow engine / skill chain），可以可选地把"用户确认"替换为"自动编排"，但 v0.3 的 skill 正文设计的是"提示用户→用户同意→调用下游 skill"。不改 skill 正文的话，平台需要支持"AI 在 skill 执行中提示用户做确认"的交互能力。

### 4.5 description 触发机制：语义匹配

6 个 skill 的 description 用中文自然语言写，AI 做语义匹配决定加载哪个。无触发词标签，触发场景融入自然句。

**封装适配时**：kk 的平台如果有自己的 skill 触发机制（关键词匹配、意图分类、路由规则），需要把 description 的语义匹配能力对齐。v0.3 的 description 写的是"什么场景下用"，平台需要能理解这个语义。

### 4.6 待适配项（B 类，等 kk 定平台）

以下项依赖目标平台能力，等 kk 定迁移方案后做：

| 项 | 当前状态 | 适配方向 |
|----|---------|---------|
| 路径变量值注入 | Obsidian vault 文件路径 | 替换为目标平台的路径/API |
| Obsidian wikilink `[[xxx]]` | operating_rules.md 内用 | 替换为普通路径或平台链接 |
| MathJax 公式渲染 | 06_启动句硬约束要求 | 确认目标平台是否支持 |
| Daily Note 机制 | 5 行收口写入 Daily Note 文件 | 替换为目标平台的日志机制 |
| AGENTS.md | Codex 格式项目指令 | 替换为目标平台的指令文件格式 |
| bundled resources | skill 目录只有 SKILL.md | 按平台能力决定是否打包 references/assets |
