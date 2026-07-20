# SelfStudyOS Vault Template

把这个目录复制到你的 Obsidian Vault，或把里面的目录合并进已有 Vault。

## 入口（双侧）

**学生侧每天打开这里**（v0.2 新增）：

```text
01_LearningDesk/01_学习首页.md
```

**Agent 侧新会话先读这里**：

```text
01_LearningDesk/06_给Agent的启动句.md
```

两侧入口的设计动机见 [`../docs/entry-separation.md`](../docs/entry-separation.md)。

## 顶层目录

- `00_Inbox/`：临时捕捉。
- `01_LearningDesk/`：**学生侧唯一入口**（每天只打开这里）。
- `10_Courses/`：课程资料实体仓库（真题、PPT、教材、作业，按课程名分目录）。
- `20_Projects/`：项目、作品集、实践记录。
- `30_Research/`：论文、方向、研究问题。
- `40_Knowledge/`：跨领域稳定知识。
- `50_LifeOps/`：生活、任务、Daily Note（5 行收口落盘处）。
- `60_Resources/`：外部资料索引。
- `70_AgentSystems/`：SelfStudyOS、agent 规则、模板（agent 后台读，用户不日常打开）。
- `80_Attachments/`：附件，本模板不追踪实际文件。
- `90_Archive/`：归档。
- `99_Meta/`：Vault 规则、canonical 模板。

## 第一次使用

1. 改写 `01_LearningDesk/` 五个文件，填你正在学的课和今天的任务（删示例行）。
2. 改写 `70_AgentSystems/SelfStudyOS/System/learner_profile.md`。
3. 改写 `70_AgentSystems/SelfStudyOS/Review/progress.md`。
4. 把 `CourseOS/ExampleCourse` 复制或重命名为你的主线课程。
5. 用 `01_LearningDesk/06_给Agent的启动句.md`（或 `prompts/01_general_start.md`）启动 agent。
6. 跑一次最小学习闭环，结束时让 agent 写 5 行进当天 Daily Note 验证。

详见 [`../docs/getting-started.md`](../docs/getting-started.md)。

## 引用和致谢

参考了知乎 @Erber 大佬的文章：<https://zhuanlan.zhihu.com/p/2033334385555010512>

以及 Karpathy 大佬的 gist：<https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f>
