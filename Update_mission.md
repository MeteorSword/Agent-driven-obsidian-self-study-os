# Update Mission — v0.3 Fork 改动记录

> 记录所有在 v0.3 模板上做的改动，按时间顺序排列。
> 基线：v0.3 原版模板（kk 的 Agent-driven-obsidian-self-study-os v0.3）

---

## 2026-07-11 21:47 — 基线建立

- 从 SS_OS\SelfStudyOS（实际使用版）中分离出 184 个学习数据文件到 00_DataBackup/
- 数据分类：daily_notes(29) + sessions(29) + progress(8) + mistakes(8) + revision(3) + external_assets(107)
- 此操作在 SS_OS 上执行，不在 v0.3 上

---

## 2026-07-11 22:15 — 新增 agent-memory-write skill

- 路径：`skills/agent-memory-write/SKILL.md`
- 定位：写记忆的唯一入口，不是约束别人的旁观者
- 约束内嵌在流程里：每次写记忆都走这个 skill，不走工具自带的 autoMemory
- 包含：查重流程、feedback 文件格式模板、MEMORY.md 索引更新规则、Daily Note 记录规则
- 硬约束：只写 vault 内 AgentMemory、每条必须有 Why 和 How to apply、事件触发不预写、索引必须同步
- 读取规则：冷启动只读 MEMORY.md 索引，具体 feedback 按需读取；超过 15 条考虑分层

---

## 2026-07-11 22:40 — 10_Courses / Raw / CourseOS 三层分工重构

### 改动原因
- TEST_ISSUE #13：外层 Raw/ 和 CourseOS 内 raw/ 功能混淆
- 用户需求：课程资料需要一个统一的实体存放点
- 设计修正：两套 Raw 不是"重复"，而是功能不同（仓库 vs 工单），但之前没写清楚

### 改动清单

| 文件 | 改动 |
|------|------|
| `vault-template/10_Courses/README.md` | 重写：定位为课程资料实体仓库，按课程名+类型分目录，含和其他文件夹的关系表 |
| `vault-template/10_Courses/ExampleCourse/` | 新建：真题/PPT/教材/作业 四个子目录 + README |
| `vault-template/70_AgentSystems/SelfStudyOS/Raw/README.md` | 改写：非课程资料暂存区，明确"课程资料不放这里" |
| `vault-template/70_AgentSystems/SelfStudyOS/CourseOS/ExampleCourse/raw/material_queue.md` | 工单模板加 Path 字段指向 10_Courses，明确实体文件不放这里 |
| `docs/architecture.md` | 顶层模型注释从"课程资料和课程输出"改为"课程资料实体仓库（真题、PPT、教材、作业，按课程名分目录）" |
| `vault-template/70_AgentSystems/SelfStudyOS/System/raw_data_pipeline.md` | 外部资料策略改为资料放置规则；Capture 步骤改为明确路径规则 |
| `skills/selfstudyos-workflow/SKILL.md` | Material Intake 流程加路由步骤：课程资料→10_Courses，不放进 CourseOS/raw |
| `vault-template/01_LearningDesk/04_课程入口.md` | 课程资料说明改为指向 10_Courses |
| `vault-template/README.md` | 顶层目录说明同步更新 |

### 改动后的文件路由规则

```
课程资料 → 10_Courses/<课程名>/<类型>/
    ↓
CourseOS/<课程名>/raw/material_queue.md 建工单，指向上面的路径

非课程资料 → 70_AgentSystems/SelfStudyOS/Raw/<类型>/
    ↓
60_Resources/ExternalIndexes/external_material_index.md 建索引（可选）

纯外部大文件 → 不进 vault
    ↓
60_Resources/ExternalIndexes/external_material_index.md 建路径
```

### 审查结果
- 全文件扫描通过：无遗留的 Raw/courses 路径引用
- 无 2026Spring 旧路径格式残留
- 无"课程资料和课程输出"旧定位描述残留

---

## 2026-07-11 23:00 — 新增 agent-material-intake skill

- 路径：`skills/agent-material-intake/SKILL.md`
- 定位：文件归档的唯一入口
- 触发词：归档、把这个资料放进去、新增资料、材料入库
- 流程：判断类型 → 路由（课程→10_Courses，非课程→Raw）→ 建工单 → 报告 → Daily Note 记录
- 硬约束：实体文件不进 CourseOS/raw、不进 Raw/courses、每次必须走流程、不猜课程归属、不重命名
- 边界：只管归档，不管学习处理/写记忆/出题

---

## 待办（已讨论但未执行）

- [x] 06_启动句 加 agent-memory-write 和 agent-material-intake 的指针
- [ ] 三处启动入口合并（COLD_START / START_HERE_FOR_AGENT / 06_启动句）
- [ ] 状态文件重叠清理（02/03/04/05 功能交叉）
- [ ] operating_rules 里加 agent-memory-write 的硬指针
- [ ] 09_course_review.md 从 v0.3 补充进 SS_OS（或确认不需要）
