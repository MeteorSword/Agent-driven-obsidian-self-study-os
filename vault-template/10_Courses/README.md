# Courses

课程资料实体仓库。所有课程的原始文件都放这里。

## 定位

| 放什么 | 放这里 |
|--------|--------|
| 真题 PDF | `10_Courses/<课程名>/真题/` |
| 老师 PPT | `10_Courses/<课程名>/PPT/` |
| 教材 PDF | `10_Courses/<课程名>/教材/` |
| 作业截图 | `10_Courses/<课程名>/作业/` |
| 其他课程资料 | `10_Courses/<课程名>/` 下按类型建子目录 |

## 建议结构

```text
10_Courses/
  数学分析B2/
    真题/
    PPT/
    教材/
    作业/
  电路基本理论/
    真题/
    PPT/
  热学/
    真题/
    PPT/
    教材/
```

## 规则

- 课程实体文件只放这里，不放进 70_AgentSystems。
- 70_AgentSystems/SelfStudyOS/CourseOS/<课程名>/raw/material_queue.md 记录工单，指向这里的路径。
- 文件名保持原始命名，AI 归档时不重命名。
- 学完的科目：整个课程目录移到 90_Archive/。

## 和其他文件夹的关系

| 文件夹 | 存什么 | 不存什么 |
|--------|--------|---------|
| **10_Courses** | 课程实体文件（PDF、PPT、截图） | 学习产出（session、错题、概念） |
| **70_AgentSystems/SelfStudyOS/CourseOS/** | 学习产出（session、错题、概念、进度） | 实体文件 |
| **60_Resources/ExternalIndexes/** | 外部资料路径索引（URL、不在 vault 内的文件路径） | 实体文件、学习产出 |
