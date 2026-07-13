---
name: agent-material-intake
description: 当用户丢文件、截图、PDF、PPT、真题、教材给 AI 时激活。这是文件归档的唯一入口。触发词：归档这个文件、把这个资料放进去、新增资料、材料入库、归档、放进 vault。
---

# 文件归档

这个 skill 是 AgentMemory 的文件归档唯一入口。所有文件归档操作都通过这里完成。

## 为什么要这个 skill

用户丢文件给 AI 后，AI 经常拿了就用，用完不登记。下次冷启动 AI 不知道这门课有哪些资料在处理中。或者 AI 把实体文件放错了位置（塞进 CourseOS/raw/ 里，那里本该只有工单）。

这个 skill 确保每次接到文件都走完归档流程：放到正确的位置、建工单、记录到 Daily Note。

## 归档流程

### 1. 判断文件类型

回答一个问题：这是课程资料还是非课程资料？

| 类型 | 例子 |
|------|------|
| 课程资料 | 真题、老师 PPT、教材、作业截图、课程相关参考 |
| 非课程资料 | 论文、书籍、网页剪藏、项目素材、通用参考资料 |

如果不确定是哪门课的，问用户。不猜。

### 2. 路由文件

| 文件类型 | 放哪 | 子目录结构 |
|---------|------|-----------|
| 课程资料 | `10_Courses/<课程名>/<类型>/` | 真题/、PPT/、教材/、作业/ |
| 非课程资料 | `70_AgentSystems/SelfStudyOS/Raw/<类型>/` | papers/、books/、clips/、projects/、assets/ |

规则：
- 课程资料只进 `10_Courses/`，不进 Raw/。
- 非课程资料只进 `Raw/`，不进 10_Courses/。
- 不重命名用户的原始文件。
- 如果 `10_Courses/<课程名>/<类型>/` 目录不存在，创建它。

### 3. 建工单

#### 课程资料

在 `CourseOS/<课程名>/raw/material_queue.md` 的工单表里加一行：

| ID | Source | Path | Scope | Why now | Target output | Status |
|---|---|---|---|---|---|---|
| Q<n> | <文件名> | `10_Courses/<课程名>/<类型>/<文件名>` | <建议处理范围> | <为什么现在要处理> | <学习 session / 做题 / 概念提炼> | candidate |

字段说明：
- **ID**：递增编号（Q1, Q2, Q3...）
- **Source**：原始文件名
- **Path**：实体文件在 10_Courses 里的路径
- **Scope**：建议处理范围（如"2-5 题"或"一个概念 + 一个例题"）
- **Why now**：为什么现在要处理（如"当前主线阻塞"、"考试冲刺"、"前置概念"）
- **Target output**：处理完应该产出什么（learning session / problem loop / concept page）
- **Status**：candidate / in-progress / done / archived

#### 非课程资料

在 `60_Resources/ExternalIndexes/external_material_index.md` 的资料表里加一行：

| Source | Type | Linked module | Scope | Copy mode | Status |
|---|---|---|---|---|---|
| <文件名> | paper/book/clip/project/reference | ResearchWiki/ProjectLab | <范围> | vault-copy | candidate |

### 4. 报告给用户

归档完成后，报告三件事：

```
✅ 已归档
- 文件：<文件名>
- 位置：<完整路径>
- 工单：<工单位置，如 CourseOS/数学分析B2/raw/material_queue.md>
- 下次学习时可从工单取用
```

### 5. 记录到 Daily Note

在当天 Daily Note 里加一行：

```markdown
- 归档资料：<文件名> → <位置>
```

## 硬约束

- **实体文件不放进 `CourseOS/<课程名>/raw/`。** 那里只有 `material_queue.md` 工单。
- **实体文件不放进 `Raw/courses/`。** 课程资料去 `10_Courses/`。
- **每次接到文件必须走这个流程。** 不能拿了就用完不登记。
- **不确定是哪门课时问用户。** 不猜，不默认。
- **不重命名用户的原始文件。**
- **不批量归档。** 每次只处理一批中的最小可处理单元，逐个建工单。

## 边界

这个 skill 只管归档。不管：
- 学习处理（那是 selfstudyos-workflow 的事）
- 写记忆（那是 agent-memory-write 的事）
- 出题（以后单独的 skill）
- 文件的"学习处理"（extract / interrogate / practice / distill 是 raw_data_pipeline 的事）
