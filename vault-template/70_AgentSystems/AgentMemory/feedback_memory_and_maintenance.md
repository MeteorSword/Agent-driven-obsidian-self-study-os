---
name: feedback_memory_and_maintenance
description: 记忆读取规则与启动句维护规则——冷启动读取、feedback 写入位置、启动句只追加
type: feedback
---

合并自 feedback_memory_execution、feedback_启动句维护规则。

## 一、记忆读取规则（已与 agent-memory-write skill 对齐）

**Rule:** 新对话冷启动时，只读 `MEMORY.md` 索引；具体 feedback 按需读取，不强制一次性完整读取所有文件。

**Why:** 早期规则要求"完整读取所有 feedback 文件"，但随着 feedback 增多，全量读取消耗 context 且无必要。agent-memory-write skill 已确立"冷启动只读 MEMORY.md 索引，具体 feedback 按需读取"的标准，本规则与之对齐。

**How to apply:**
- 新会话启动时，按 06_给Agent的启动句.md 的顺序读入口文件
- 冷启动只读 `AgentMemory/MEMORY.md` 索引，了解有哪些 feedback 及其主题
- 具体 feedback 在相关场景触发时按需读取，不预读全部
- 如果发现旧记忆中有矛盾的规则，优先采纳更新的那个
- 写记忆（新增 feedback）时，先读 `${SKILLS_DIR}/agent-memory-write/SKILL.md` 并按其流程执行，不使用工具自带的 autoMemory 写到 vault 外
- 新 feedback 写入 `${AGENT_MEMORY_DIR}`（vault 内），这里才是 SelfStudyOS 的 source of truth

> 旧规则"新对话必须完整读取所有 feedback 文件，不能只读 MEMORY.md"已作废，以 agent-memory-write skill 为准。

## 二、启动句维护规则

**Rule:** `06_给Agent的启动句.md` 默认不删改。确需修改时（版本升级、纠错、结构重组）走迁移流程并留档，不在文件里做无声替换。

**Why:** 早期为了防止"一句话改错导致行为漂移"，定过"只许追加"的绝对规则。但它有两个后果：（1）文件只增不减，越来越长；（2）v1.0 要重构 06 为三段式时，这条规则直接卡死升级。现在改为"默认可改，但改动必须留痕"。

**How to apply:**
- 日常不要动 06。要加规则 → 改 `${OPERATING_RULES}`。
- 版本升级需要重构 06 时 → 在 `99_Meta/migration_<日期>.md` 记下改了什么、为什么、怎么回滚，然后正常改。
- **绝对不要往 06 追加当期内容**（这学期的课、考试日期、当前计划）。当期计划写 `${STUDY_PLAN}`，当期主线写 `${TODAY_STATUS}`。这是造成"一层叠一层"的直接原因。
- 如果发现 06 里已经有当期内容 → 把它搬到 study_plan / 02_今日状态，然后从 06 删除。
