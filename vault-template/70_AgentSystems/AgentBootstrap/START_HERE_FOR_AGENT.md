# START HERE FOR AGENT

如果你是新开启对话的 AI agent，并且用户在处理这个 Obsidian SelfStudyOS，先读本页。

## 必读顺序

1. `70_AgentSystems/SelfStudyOS/AGENTS.md`
2. `70_AgentSystems/SelfStudyOS/home.md`
3. `70_AgentSystems/SelfStudyOS/System/learner_profile.md`
4. `70_AgentSystems/SelfStudyOS/System/operating_rules.md`
5. `70_AgentSystems/SelfStudyOS/System/raw_data_pipeline.md`
6. `70_AgentSystems/SelfStudyOS/Review/progress.md`
7. `60_Resources/ExternalIndexes/external_material_index.md`

如果用户要学习某门课，再读对应 CourseOS：

```text
70_AgentSystems/SelfStudyOS/CourseOS/<CourseName>/<CourseName>-MOC.md
70_AgentSystems/SelfStudyOS/CourseOS/<CourseName>/raw/material_queue.md
```

## 默认判断

如果用户没有指定任务，默认建议：

1. 查看 `Review/progress.md`。
2. 选择当前主线课程。
3. 从 raw 队列中选择一个最小范围。
4. 要求用户先解释当前理解或先尝试题目。
5. 不直接给作业完整答案。

## 固定工作流

### Daily Start

1. 查看总进度。
2. 选择唯一主任务。
3. 限定最小范围。
4. 开 learning session / problem loop / reading mission / project ability mapping。

### Material Intake

1. 不批量复制外部目录。
2. 先查外部资料索引。
3. 判断类型：课程、作业、论文、项目、长期参考。
4. 选择处理模式：external-link、session-raw、vault-copy、wiki-distilled。
5. 每次只处理一个小范围。

### Course Learning

1. 读对应 CourseOS MOC。
2. 读 raw 接入队列。
3. 让用户先说明理解、尝试或卡点。
4. 给分层提示，不先代做。
5. 结束时更新 progress，并在必要时生成概念卡、题型卡、错题卡。

### Research Reading

1. 先写 Reading Mission。
2. 选择 L0-L4 目标级别。
3. 大多数论文只读到 L0/L1。
4. 只有有明确用途的论文才进入深读。

### Project Work

1. 记录真实问题、用户、demo 状态、AI 代劳部分、能力债务。
2. 如果当天基础任务完全没推进，提醒先完成一个最小基础任务。
3. 项目输出要映射到能力树，不只追求 demo。

## 不允许

- 不把大资料批量总结成长文。
- 不把未练习验证的内容放进稳定知识库。
- 不直接解作业。
- 不鼓励用项目逃避基础训练。
- 不为了 Obsidian 图谱好看创建空链接。

## 结束标准

每次结束必须给出：

- 今天处理了什么材料
- 用户自己完成了什么
- AI 帮了什么
- 仍然不懂什么
- 下一步最小动作是什么
- 更新了哪些文件

