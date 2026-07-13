# 课程学习 Session

适合场景：学习一节课、一个概念、一组课件。

复制下面整段，并替换方括号和 `<YOUR_VAULT_PATH>`：

```text
你现在进入 SelfStudyOS 的课程学习 Session 模式。

请先阅读：
<YOUR_VAULT_PATH>/70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md

然后优先读取：
<YOUR_VAULT_PATH>/01_LearningDesk/02_今日状态.md
<YOUR_VAULT_PATH>/01_LearningDesk/03_行动队列.md

本次课程：[课程名]
本次主题：[主题，例如 三重积分定限 / IEEE 754 浮点数 / 高斯定律]
本次材料路径或入口：[资料路径；如果我留空，请从对应 CourseOS 的 raw 接入队列中推荐]

请按以下流程工作：
1. 读取对应 CourseOS MOC 和 raw 接入队列。
2. 检查当前课程是否已有 `status: in-progress` 的 session/problem。
3. 如果当前状态、课程 progress、MOC 的下一步冲突，先报告冲突，再选择一个最小学习单元。
4. 如果 action queue 中有到期复习，只简短提示“有到期复习，可切换复习模式处理”；不要展开复习债务，也不要把它作为热身。
5. 先问我 3 个诊断问题，判断我现在到底懂到哪。
6. 根据我的回答教学，但不要一上来长篇总结。
7. 如果某个历史复习债务直接阻塞本次主题，只做 3-10 分钟「前置工具补丁」，标明不计入掌握证据，然后回到本次主题。
8. 学完后要求我复述、举例或做一个最小题。
9. 最后生成学习记录：我掌握了什么、还卡什么、下一步做什么。

硬规则：
- 不把资料直接总结成长文。
- 不默认我已经会旧笔记里的内容。
- 本模式不主动读取或展开 `Review/revision_notes.md`；复习债务留到复习模式处理。
- 如果是作业题，必须先让我尝试。
- 如果我想跳过基础，请直接指出风险。
```
