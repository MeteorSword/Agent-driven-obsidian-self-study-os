# SelfStudyOS Home

这是一个面向自学的 AI agent + Obsidian 系统。

## 入口分离

**用户每日入口**（学生只需要打开这一侧）：

- [[01_LearningDesk/01_学习首页|学习首页]]
- [[01_LearningDesk/02_今日状态|今日状态]]
- [[01_LearningDesk/03_行动队列|行动队列]]

**Agent 后台入口**（agent 新会话必须先读这一侧）：

- [[70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT|START HERE FOR AGENT]]
- [[70_AgentSystems/SelfStudyOS/AGENTS|SelfStudyOS AGENTS]]

规则：

- 用户不要把 agent bootstrap 当作每日学习入口。
- Agent 新会话必须先读 agent bootstrap。
- 日常学习从 `01_LearningDesk -> 今日状态 -> 行动队列` 开始。

设计理由详见 [`docs/entry-separation.md`](../../../docs/entry-separation.md)。

## 当前选择

- 主方案：课程 + 科研 + 项目三系统。
- 启动策略：完整目录可以存在，但日常只启用一个主任务。
- 教学规则：标准语气，但作业不直接代做（Hint 1/2/3 分层）。
- 当前试运行课程：[[CourseOS/ExampleCourse/ExampleCourse-MOC|示例课]]（请改成你自己的主线课）。

## 每天从这里开始

1. 打开 [[01_LearningDesk/01_学习首页|学习首页]]。
2. 查看 [[01_LearningDesk/02_今日状态|今日状态]] 和 [[01_LearningDesk/03_行动队列|行动队列]]。
3. 选择今天唯一主任务。
4. 如果是课程学习，进入对应 CourseOS MOC。
5. 结束前按 [[99_Meta/Templates/learning_close_5lines|学习结束 5 行]] 把会话收口写进当天 Daily Note。不要让用户自己改 02_今日状态 / 03_行动队列 / 05_复习入口 / 课程 progress 中的任何一个；只有发生结构性事件（新错题 / 新复习债务 / 新题号通过 / 主线推进 / 任务 archive）才另开文件。

## 系统模块

- [[01_LearningDesk/01_学习首页|学习首页]]
- [[70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT|Agent Bootstrap]]
- [[System/learner_profile|学习者画像]]
- [[System/operating_rules|运行规则]]
- [[System/raw_data_pipeline|raw data 拆解流程]]
- [[System/wiki_maintenance_rules|wiki 维护规则]]
- [[System/weekly_review|周复盘]]
- `CourseOS/`
- `ResearchWiki/`
- `ProjectLab/`
- [[Review/progress|总进度]]
- [[Review/revision_notes|复习债务]]

## 当前 14 天目标

用一门主线课程验证这套系统是否能做到：

- 独立完成练习，而不是靠 AI 敷衍。
- 知道自己卡在哪类问题。
- 对知识点有基本吸收。
- 每天知道下一步做什么。
- 形成最小复盘习惯。

## 当前限制

在主线课程闭环跑通前，不大规模 ingest 论文和项目资料。

允许做轻量记录：

- 项目 idea 可以放进 `ProjectLab/ideas/`。
- 论文可以放进 `Raw/papers/`。
- 但不进入深度学习流程，除非当天主线任务已完成。
