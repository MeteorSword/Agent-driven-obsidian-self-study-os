# 入口分离（Entry Separation）

SelfStudyOS 的一个核心设计是把**用户每日学习入口**和 **AI agent 后台启动入口**严格分开。

## 为什么

早期版本两侧入口混在一起：用户每天打开的是 `70_AgentSystems/SelfStudyOS/home.md`，里面同时夹着 prompt 工程细节、agent 必读顺序、运行规则和学习者画像。结果：

- 用户每天面对一堆 agent 才需要看的术语，认知负担高。
- 用户容易误改 agent 配置文件，破坏 agent 后续行为。
- "今天该做什么"被埋在 7-8 个其它信息块里。
- 学生只想做题，但被"先理解系统结构"挡住。

## 解决方案

两条互不重叠的入口：

```text
01_LearningDesk/                        # 用户侧（学生每天只打开这里）
  01_学习首页.md                         # 主入口
  02_今日状态.md                         # 现在主线 / 今天唯一主任务
  03_行动队列.md                         # 真正要做的任务 + stale 规则
  04_课程入口.md                         # 进入哪门课
  05_复习入口.md                         # 复习 / 冷复测 / 错题
  06_给Agent的启动句.md                  # 新开 agent 对话时复制粘贴

70_AgentSystems/                        # Agent 侧（agent 后台读，用户不日常打开）
  AgentBootstrap/
    START_HERE_FOR_AGENT.md             # agent 新会话第一份必读
  SelfStudyOS/
    AGENTS.md
    home.md
    System/
      operating_rules.md                # Hint 分层 / 学习模式 / 作业模式 / stale 规则
      learner_profile.md
      raw_data_pipeline.md
```

## 规则

- 用户**不要**把 `START_HERE_FOR_AGENT.md` 当作每日学习入口。
- Agent **必须**先读 `START_HERE_FOR_AGENT.md`，再读 `01_LearningDesk/`。
- 日常学习从 `01_LearningDesk/01_学习首页 → 02_今日状态 → 03_行动队列` 开始。
- 当用户对 agent 教学方式有反馈，改 `operating_rules.md`，不改 `01_LearningDesk/`。
- 当用户调整每日学习状态，改 `01_LearningDesk/02_今日状态.md` 或 `03_行动队列.md`，不改 `70_AgentSystems/`。

## 学生侧入口的写作规则

为了让学生看完就能开始做事，`01_LearningDesk/` 里：

- **不用** prompt 工程词汇（"agent / loop / session / mission / pipeline / schema"）。
- **用**行为动词（"做作业 / 学新内容 / 做复习 / 改运行规则"）。
- 每个表格都有「我要做什么 → 打开哪里」两列，而不是先讲架构。
- 把 agent 必读顺序、prompt、运行规则全部链接出去，**不**就地展开。

## 验证

如果某个学生不懂 LLM、不懂 prompt engineering，只是想用这个 vault 学高数，他打开 `01_学习首页.md` 应该 30 秒内就能找到今天要做的题。如果他需要先看完一段"系统介绍"才能开始，说明入口分离失败。

## 相关

- [`docs/close-ritual.md`](close-ritual.md) — 5 行收口模板，配合入口分离让学生不用手改任何文件。
- [`docs/agent-rules.md`](agent-rules.md) — agent 侧的硬约束。
