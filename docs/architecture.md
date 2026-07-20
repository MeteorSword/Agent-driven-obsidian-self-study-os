# 架构说明

SelfStudyOS 是一个 agent-first 的 Obsidian 学习系统，但它不要求复杂插件，也不依赖专有数据库。核心资产仍然是普通文件夹和 Markdown 文件。

## 顶层 Vault 模型

```text
00_Inbox/        # 临时捕捉
01_LearningDesk/ # 学生侧唯一入口（每天只打开这里）
10_Courses/      # 课程资料实体仓库（真题、PPT、教材、作业，按课程名分目录）
20_Projects/     # 项目和作品集
30_Research/     # 论文、方向和研究问题
40_Knowledge/    # 跨领域稳定知识
50_LifeOps/      # 生活、任务、Daily Note（5 行收口落盘处）
60_Resources/    # 外部资料索引
70_AgentSystems/ # SelfStudyOS、prompts、agent 规则（agent 后台读）
80_Attachments/  # 附件，本仓库默认不追踪
90_Archive/      # 归档
99_Meta/         # Vault 规则、迁移记录、canonical 模板
```

开源模板只提供骨架和规则，不提供你的私人资料。

## 入口分离

这是 0.2 版本的核心结构变化。详细动机见 [`entry-separation.md`](entry-separation.md)。

```text
01_LearningDesk/                     # 学生侧
  01_学习首页.md → 02 / 03 / 04 / 05 / 06
  02_今日状态.md                      # 现在主线 / 今天唯一主任务
  03_行动队列.md                      # 真正要做的任务 + stale 规则
  04_课程入口.md
  05_复习入口.md
  06_给Agent的启动句.md               # 复制粘贴启动 prompt

70_AgentSystems/                     # Agent 侧
  AgentBootstrap/SkillRegistry.md
  SelfStudyOS/
    AGENTS.md / home.md
    System/operating_rules.md        # Hint 分层 / 三模式 / 复习债务路由 / stale / 每日结束
    System/learner_profile.md
    System/raw_data_pipeline.md
```

## SelfStudyOS 三系统

### CourseOS

用于课程学习、作业、错题、考试复习。

核心输出：

- learning session
- problem loop（按 Hint 1 → 2 → 3 → Solution 分层）
- concept page（必须有学习证据才进 wiki，候选卡显式标 `·占位`）
- mistake card
- course progress

掌握等级：

```text
预热通过：能理解公式或做最小例题
桥接通过：能做贴近课后题的过渡题
作业题通过：能完成真实课后习题
变式通过：能处理不完全同型题
```

桥接题**不计入掌握证据**。

复习债务默认只在复习模式展开；作业模式和开始学习模式不主动读取 `Review/revision_notes.md`，除非某个债务直接阻塞当前任务。

### ResearchWiki

用于论文阅读、研究方向探索、概念连接和开放问题。

核心输出：

- reading mission
- paper page
- concept page
- connection page
- research question

主线课程未跑通前不启动 L2 深读。

### ProjectLab

用于项目定位、能力树、项目复盘和作品集沉淀。

核心输出：

- project note
- ability tree
- minimal task
- AI-assisted parts
- skill debt

## raw/wiki 分离

Raw 是原始材料，wiki 是经过学习证据验证后的稳定知识。

| 层级 | 例子 | 规则 |
|---|---|---|
| raw | PDF、PPT、截图、题目、论文 | 不改写，不当作成果 |
| session | 一次学习记录 | 引用 raw 的小范围 |
| wiki | 概念、题型、错题、连接 | 必须有学习证据，候选卡标 `·占位` |

## 收口仪式

每次 session 结束，agent 把 5 行写进当天 Daily Note 的「复盘」段下面，替代手动维护 02 / 03 / 05 / 课程 progress。

详见 [`close-ritual.md`](close-ritual.md) 和 [`vault-template/99_Meta/Templates/learning_close_5lines.md`](../vault-template/99_Meta/Templates/learning_close_5lines.md)。

## Agent 角色

Agent 负责：

- 分类资料
- 压缩范围
- 提问诊断
- 分层提示（Hint 1 / 2 / 3 / Solution）
- 识别模式（开始学习模式 / 作业模式 / 复习模式）
- 应用复习债务路由和 stale 规则（Daily Start 只提示到期复习；review 类 archive 只在复习模式或明确队列维护时执行；homework 类逾期 ≥ 7 天先确认）
- 写 5 行收口进 Daily Note
- 仅在结构性事件发生时更新 02 / 03 / 05 / progress

Agent 不负责：

- 替学习者直接完成作业
- 把所有资料总结成长文
- 无证据地写确定性结论
- 用项目 demo 掩盖基础课缺口
- 让学习者手改日常状态文件
