---
name: agent-material-intake
description: 收到任何文件时激活，不论用户是否说归档：拖入窗口、附件、粘贴图片、给出文件路径、截图、PDF、PPT、真题、教材，都算。也覆盖用户说归档、放进 vault、材料入库。这是文件归档的唯一入口。
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

在 `${MATERIAL_QUEUE}` 的工单表里加一行：

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

在 `${EXTERNAL_MATERIAL_INDEX}` 的资料表里加一行：

| Source | Type | Linked module | Scope | Copy mode | Status |
|---|---|---|---|---|---|
| <文件名> | paper/book/clip/project/reference | ResearchWiki/ProjectLab | <范围> | vault-copy | candidate |

### 4. 报告给用户

归档完成后，报告三件事：

```
✅ 已归档
- 文件：<文件名>
- 位置：<完整路径>
- 工单：<工单位置>
- 下次学习时可从工单取用
```

### 真题归档的特殊提示

如果归档的是真题文件（位于 `10_Courses/<课程名>/真题/` 下），报告时追加一行：

```
- 已归档真题，是否要建立知识点索引？如需要，将调用 agent-exam-mapping skill。
```

用户同意后调用 agent-exam-mapping skill。不自动串联。

### 5. 记录到 Daily Note

在当天 Daily Note 里加一行：

```markdown
- 归档资料：<文件名> → <位置>
```

## 硬约束

- **课程原件（PDF / PPT / 截图）只放 `10_Courses/<课程名>/<类型>/`。** `CourseOS/<课程名>/` 放学习产物、索引、进度与 `material_queue.md` 工单，不放原件。
- **实体文件不放进 `Raw/courses/`。** 课程资料去 `10_Courses/`。
- **每次接到文件必须走这个流程。** 不能拿了就用完不登记。
- **不确定是哪门课时问用户。** 不猜，不默认。
- **不重命名用户的原始文件。**
- **不批量归档。** 每次只处理一批中的最小可处理单元，逐个建工单。

## 边界

这个 skill 只管归档。不管：
- 学习处理（那是 selfstudyos-course-workflow 的事）
- 写记忆（那是 agent-memory-write 的事）
- 出题（以后单独的 skill）
- 文件的"学习处理"（extract / interrogate / practice / distill 是 raw_data_pipeline 的事）

## 触发条件（收到文件即触发）

满足任一条就必须激活本 skill，不依赖用户说什么：

- 用户拖入文件、附件、截图或图片
- 用户粘贴一段文件路径
- 用户提到某份资料要放进库

## 三条硬规则

1. **未落库不得作为学习依据。** 文件必须先复制进 `10_Courses/<课程名>/<类型>/`，再开始用它做题或讲解。只有确认文件是什么时可以临时读附件。
2. **拿不到真实路径时必须明说。** 如果只能读到临时附件，无法复制到库，直接告诉用户：把你复制到 `10_Courses/<课程名>/<类型>/`，或者给我绝对路径。不要假装已经归档。
3. **一次归档三件事必须同时完成**：复制进库、按命名规范改名、在 `material_queue` 台账加一行。少一件都算没完成。

## 命名规范

```
科目-属性-年份-序号
科目-期中-2023-A.pdf
科目-课件-2023-01.pdf
科目-教材-第二版.pdf
```

科目必须与 `CourseOS/<课程名>/` 目录名一致。答案单独成文件，加 `-答案` 后缀。原名记进 `course_profile.md` 的映射表。