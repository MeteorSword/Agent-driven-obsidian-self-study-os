# Material Queue

CourseOS 的资料接入工单。记录这门课有哪些资料要处理、处理到什么程度。

实体文件不放在这里。实体文件放在 `10_Courses/<课程名>/` 下。

这里只存工单：每行指向 10_Courses 里的一个文件或一个范围。

## 队列

| ID | Source | Path | Scope | Why now | Target output | Status |
|---|---|---|---|---|---|---|
| Q1 | Example textbook chapter | `10_Courses/ExampleCourse/教材/` | one definition + one example | current blocker | learning session | candidate |
| Q2 | Example homework set | `10_Courses/ExampleCourse/作业/` | 2-5 problems | practice | problem loop | candidate |

## Source Card

```text
Source：
Path：10_Courses/<课程名>/<类型>/<文件名>
Scope：
Why now：
Target output：
Stop condition：
Status：candidate / in-progress / done / archived
```

## 规则

- 实体文件放 `10_Courses/<课程名>/` 下，不放这里。
- 每次接到新资料时，在这里建一行工单。
- AI 归档文件时必须同步更新工单状态。
- 学完的科目：工单标记 archived，实体文件移到 90_Archive/。
