# 架构说明

SelfStudyOS 是一个 agent-first 的 Obsidian 学习系统，但它不要求复杂插件，也不依赖专有数据库。核心资产仍然是普通文件夹和 Markdown 文件。

## 顶层 Vault 模型

```text
00_Inbox/        # 临时捕捉
10_Courses/      # 课程资料和课程输出
20_Projects/     # 项目和作品集
30_Research/     # 论文、方向和研究问题
40_Knowledge/    # 跨领域稳定知识
50_LifeOps/      # 可选生活与任务系统
60_Resources/    # 外部资料索引
70_AgentSystems/ # SelfStudyOS、prompts、agent 规则
80_Attachments/  # 附件，本仓库默认不追踪
90_Archive/      # 归档
99_Meta/         # Vault 规则和迁移记录
```

开源模板只提供骨架和规则，不提供你的私人资料。

## SelfStudyOS 三系统

### CourseOS

用于课程学习、作业、错题、考试复习。

核心输出：

- learning session
- problem loop
- concept page
- mistake card
- course progress

### ResearchWiki

用于论文阅读、研究方向探索、概念连接和开放问题。

核心输出：

- reading mission
- paper page
- concept page
- connection page
- research question

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
| wiki | 概念、题型、错题、连接 | 必须有学习证据 |

## Agent 角色

Agent 负责：

- 分类资料
- 压缩范围
- 提问诊断
- 分层提示
- 组织记录
- 更新索引和进度

Agent 不负责：

- 替学习者直接完成作业
- 把所有资料总结成长文
- 无证据地写确定性结论
- 用项目 demo 掩盖基础课缺口

