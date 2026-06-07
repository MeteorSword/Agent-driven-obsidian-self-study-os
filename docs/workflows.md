# 工作流

## Daily Start

用于每天开始学习。

1. 读 `01_LearningDesk/02_今日状态.md` 和 `03_行动队列.md`。
2. 检查当前课程中 `status: in-progress` 的 session/problem。
3. **应用 stale 规则**：review 类逾期 ≥ 3 天 archive，homework 逾期 ≥ 7 天先和用户确认；不要把过期任务当今天 P0。
4. 若当前状态、课程 progress、MOC、总进度的下一步冲突，先报告冲突。
5. 选择唯一主任务。
6. 若有 15 分钟内可完成的过期复习，先做热身。
7. 限定最小范围。
8. 让学习者先说明当前理解、尝试或卡点。
9. 开始 CourseOS、ResearchWiki 或 ProjectLab 工作流。
10. 结束时按 5 行收口写进 Daily Note。

## Course Session（识别模式）

用于学习一节课、一个概念或一组课件。

1. 读取课程 MOC 和 raw 队列。
2. **识别模式**：学习模式 vs 作业模式。
3. 选择一个小范围。
4. 问 2-5 个诊断问题。
5. 解释核心概念，但不长篇总结。
6. 要求复述、举例或做最小题；如果是学习模式可以用桥接题，但要明确标记"桥接不计掌握"。
7. 记录掌握点、卡点和下一步（通过 5 行收口）。

## Problem Loop（Hint 分层）

用于作业、例题、错题订正。

1. 学习者先写出理解、思路、第一步或卡点。
2. Agent 判断卡点类型（主卡点 vs 末端错误）。
3. **Hint 1**：题型识别和第一步方向。
4. 学习者继续尝试。
5. **Hint 2**：关键公式或关键变形。
6. 仍卡住给 **Hint 3**：展开下一步，但不给完整答案。
7. 学习者尝试后仍卡住，才给完整解法。
8. 解后归因，决定是否进入错题卡。
9. 桥接题不计入作业完成度，也不作为掌握证据。

## Reading Mission

用于论文阅读。

1. 先定义为什么读这篇论文。
2. 选择目标等级 L0-L4（主线课程未跑通前不启动 L2 深读）。
3. 写清必须理解和可以忽略的部分。
4. 先做 global orientation，再钻一个局部点。
5. 把结论接回 ResearchWiki 的概念、连接或问题。

## Project Ability Mapping

用于项目和作品集。

1. 说明真实问题和用户。
2. 判断当前 demo 状态。
3. 拆分自己掌握的部分和 AI 代劳部分。
4. 暴露能力债务。
5. 选择一个最小可验证任务。
6. 把项目任务映射回课程基础或技能训练。
7. 如果当天主线课程完全没推进，先提醒做一个最小主线任务。

## 收口（每次 session 结束都要做）

用 [`vault-template/99_Meta/Templates/learning_close_5lines.md`](../vault-template/99_Meta/Templates/learning_close_5lines.md) 写 5 行进当天 Daily Note。详见 [`close-ritual.md`](close-ritual.md)。

不要让学习者手改 02 / 03 / 05 / 课程 progress。

## Weekly Review

用于每周复盘。

1. 看本周 Daily Note 5 行中真实独立产出有几天。
2. 看 Hint 1/2/3 分布 → 哪个主题最不稳。
3. 找出反复出现的"仍然不懂"→ 进 `Review/revision_notes.md`。
4. 找出没有闭环的 session。
5. 判断是否在用项目逃避基础训练。
6. 选择下周最小主线。
