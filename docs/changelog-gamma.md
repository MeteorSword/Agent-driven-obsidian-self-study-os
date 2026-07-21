# v0.3 Gamma 分支改动总结

> 本文件记录 v0.3 Gamma 分支相对 kk 原版 v0.3 模板的全部改动。
> 六轮迭代，连续 auditor 验收全部 pass + accept。

---

## 按方面分类

### 隐私安全（Privacy）

git 历史里的真实个人信息全部清除。author email 从真实 QQ 邮箱替换为占位符，author name 替换为 `SelfStudyOS Contributor`，历史 commit 里的真实本机路径抹掉。用 git filter-repo 两轮重写，6 个 commit 全部干净。remote 为空时做，rewrite 后直接 push 无历史包袱。

AgentMemory 下 12 个 feedback 文件合并精简为 7 个。含真实个人信息的 user_profile.md 删除，画像职能移到 learner_profile.md。feedback 里的学校名、科目+考试日期、真实路径全部泛化或替换为占位符。方法论内容完整保留。10_Courses/README.md 的真实课程名替换为 ExampleCourse。TEST_ISSUE 1.md 加入 .gitignore 并从 git 追踪移除。

### 入口与文档结构（Entry & Structure）

三处启动入口合并为一。START_HERE_FOR_AGENT.md 的内容并入 06_给Agent的启动句.md，START_HERE 删除。06 分为两部分：Part 1 用户贴的启动句（硬约束精简为 3 条底线 + 规则引用），Part 2 Agent 执行指南（必读顺序、Daily Start、课程执行引用 skill、资料归档引用 skill、复习债务路由引用 operating_rules、Wiki/Lab 占位符、结束标准引用 operating_rules）。14 个引用 START_HERE 的文件全部改指向 06。docs/entry-separation.md 重写。

prompts 目录清理：删掉 8 个被 skill 覆盖的 prompt 文件，保留 07 周复盘和 00 索引，00 改写为简洁索引。

### 规则体系（Rules）

operating_rules 精简为规则定义唯一 source of truth。课程三模式详细执行步骤移到 course-workflow skill，作业边界 Hint 7 步移到 skill，项目许可规则改为占位。保留复习债务路由表、掌握等级、系统原则、stale 规则、每日结束规则。新增"题号格式"段（会话内 Q 编号 + 持久化来源词-题号）。新增"路径变量表"段（24 个路径变量）。

### Skill 体系（Skills）

6 个本地 skill 形成闭环：

selfstudyos-workflow 做日常学习调度（Daily Learning 8 步含半强制复习触发），selfstudyos-course-workflow 做课程执行（4 子模式：开始学习/作业/复习/考试冲刺，含前置概念诊断和扫描课后习题）。agent-material-intake 做文件归档，agent-memory-write 做记忆写入，agent-exam-mapping 做真题按知识点索引，agent-weekly-review 做周复盘（含连续虚假进展预警）。SkillRegistry 补注册全部 6 个本地 skill。

skill 间协作通过用户确认衔接，不自动串联。material-intake 归档真题后提示是否建索引，用户同意后调用 exam-mapping。workflow 选定任务后交接给 course-workflow 执行。每个 skill 有明确的边界声明（不管什么）。

### 周复盘（Weekly Review）

周复盘从散落在三个文件的问题清单，升级为 agent-weekly-review skill。skill 引用 System/weekly_review.md 的 6 个问题定义（唯一定义，取三套并集精简），含 5 步流程和连续两周虚假进展预警。prompts/07 删除，study_plan 周复盘段改为引用 skill。

### 真题映射（Exam Mapping）

新建 agent-exam-mapping skill 和 exam_topic_index 模板。真题不改原文件，建立"真题题号→知识点"的映射索引。字段：知识点、题号、考法、难度、年份/来源、状态。开始学习模式扫描 exam_topic_index 了解真实考法，学习内容围绕真题反推。

### 格式规范化（Format Normalization）

6 个 skill 的 description 统一为中文，去掉"触发词："标签融入自然句。selfstudyos-workflow 的 description 从英文改中文，收窄到调度场景，消除和 course-workflow 的触发范围重叠。

6 个 skill 的所有文件引用从裸路径改为路径变量（`${VARIABLE_NAME}` 格式）。skill 间引用从"见 operating_rules.md 的 XXX 段"改为"见 ${OPERATING_RULES} 的 XXX 段"。06_启动句的 `<YOUR_VAULT_PATH>` 替换为 `${YOUR_VAULT_PATH}`。

新建 docs/skill-reference-inventory.md：梳理每个 skill 引用的外部文件清单，供平台适配时打包参考。

---

## 时间线 log

### 2026-07-18 stage0 隐私安全

- git filter-repo 两轮重写：author email/name 替换，真实路径抹掉，6 commit 干净
- AgentMemory 12→7 文件合并脱敏，user_profile 删除，画像移到 learner_profile
- selfstudyos-workflow 精简：删 Material Intake/CourseOS，Daily Learning 中文化 8 步含半强制复习，Wiki/Lab 占位符
- SkillRegistry 描述更新

### 2026-07-20 stage1 结构清理

- prompts 删 8 个，保留 07+00_index
- START_HERE 并入 06，START_HERE 删除，14 个引用改向
- operating_rules 精简：课程三模式/作业边界/项目许可改为引用 skill
- 10_Courses 课程名脱敏，TEST_ISSUE 1.md gitignore

### 2026-07-20 skill 缺口修补 + 真题映射

- course-workflow 作业模式补"先问前置概念"
- course-workflow 开始学习模式补"先扫描课后习题"
- 新建 agent-exam-mapping skill + exam_topic_index 模板
- agent-material-intake 补真题归档提示

### 2026-07-20 registry 同步 + 周复盘收敛

- SkillRegistry 补注册 4 个本地 skill
- agent-material-intake 边界段修正
- 周复盘三处收敛到 System/weekly_review.md 唯一定义

### 2026-07-20 周复盘 skill + 题号格式

- 新建 agent-weekly-review skill
- 删除 prompts/07_weekly_review.md
- study_plan 周复盘段改为引用 skill
- operating_rules 新增题号格式段（会话内 Q + 持久化来源格式）

### 2026-07-21 C 类平台无关格式规范化

- 6 个 skill description 统一中文，去掉触发词标签，消除触发重叠
- operating_rules 新增路径变量表（24 个变量）
- 6 个 skill 文件引用改为路径变量
- 新建 docs/skill-reference-inventory.md 外部引用清单
