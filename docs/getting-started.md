# 快速开始

这份指南适合第一次使用 SelfStudyOS 的用户。

如果你使用 Windows，先读 [`windows-setup.md`](windows-setup.md)。那份指南覆盖 Obsidian、Git、Codex/Claude Code、PowerShell 和 Windows 路径写法。

## 1. 复制模板

把 [`vault-template/`](../vault-template/) 复制到你的 Obsidian Vault，或把里面的目录合并进现有 Vault。

推荐从一个小范围开始，不要立刻迁移全部旧笔记。

## 2. 改写个人配置

按顺序改这几个文件：

### 学生侧（每天会打开）

```text
01_LearningDesk/01_学习首页.md    # 改「当前主线」表
01_LearningDesk/02_今日状态.md    # 改主线 / 今天唯一主任务 / 进展标准
01_LearningDesk/03_行动队列.md    # 删示例行，加自己的真实任务
01_LearningDesk/04_课程入口.md    # 改课程表
01_LearningDesk/06_给Agent的启动句.md   # 把 <YOUR_VAULT_PATH> 替换成绝对路径
```

### Agent 侧（一次性配置）

```text
70_AgentSystems/SelfStudyOS/System/learner_profile.md
70_AgentSystems/SelfStudyOS/Review/progress.md
70_AgentSystems/SelfStudyOS/CourseOS/ExampleCourse/ExampleCourse-MOC.md
```

把示例课程复制并重命名为你当前最重要的一门课。

## 3. 启动 AI agent

打开 [`vault-template/01_LearningDesk/06_给Agent的启动句.md`](../vault-template/01_LearningDesk/06_给Agent的启动句.md)，把里面的启动句复制给你的 AI agent。

第一次启动时，agent 会：

- 先读 `START_HERE_FOR_AGENT.md` 了解硬约束和工作流。
- 再读 `01_LearningDesk/02_今日状态.md` 和 `03_行动队列.md` 看今天该做什么。
- 报告：当前主线 / 今天 P0 / 是否有到期复习（不展开债务）/ 建议的唯一主任务 / 本次模式 / 需要你先尝试或输出什么。

## 4. 做一次最小学习闭环

合格的第一轮任务应该很小：

- 一节课里的一个概念
- 一份课件的 10-20 页
- 2-5 道题
- 一篇论文的 L0/L1 Reading Mission
- 一个项目模块的最小可运行任务

不要从“整理所有资料”开始。进入课程时先选模式：开始学习 / 作业 / 复习。

## 5. 结束时让 agent 用 5 行收口

session 结束时直接告诉 agent："收口"。它会：

1. 找 `50_LifeOps/Logs/Daily/YYYY-MM-DD.md`，没有就按 [`vault-template/99_Meta/Templates/daily_note.md`](../vault-template/99_Meta/Templates/daily_note.md) 创建。
2. 在「复盘」段下面追加 [`5 行收口模板`](../vault-template/99_Meta/Templates/learning_close_5lines.md)：
   - 今天处理了什么
   - 我自己完成的
   - AI 帮了什么（具体到 Hint 层级）
   - 仍然不懂的
   - 明天最小动作
3. 如果今天发生了结构性事件（新错题 / 新复习债务 / 新题号通过 / 主线推进 / 任务 archive），它会另外更新对应文件。

**你不需要自己改** `02_今日状态.md` / `03_行动队列.md` / `05_复习入口.md` / 课程 `progress.md`。

详见 [`close-ritual.md`](close-ritual.md)。

## 6. 验证闭环

第一次跑完后，打开 `50_LifeOps/Logs/Daily/YYYY-MM-DD.md`：

- 如果看到 5 行结构清晰、有具体题号 / Hint 层级 / 卡点 → 闭环跑通。
- 如果没看到 5 行，或 5 行写成"今天学了挺多 / 基本掌握" → 说明 agent 没按规则做，回去检查 `06_给Agent的启动句.md` 里硬约束有没有被截断。

## 7. 逐步扩展

当一门课跑通后，再增加下一门课、论文阅读或项目能力树。SelfStudyOS 的重点是稳定闭环，不是一次性建完整知识图谱。
