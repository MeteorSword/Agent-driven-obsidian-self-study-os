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
- 写记忆（新增 feedback）时，先读 skills/agent-memory-write/SKILL.md 并按其流程执行，不使用工具自带的 autoMemory 写到 vault 外
- 新 feedback 写入 `<YOUR_VAULT_PATH>/70_AgentSystems/AgentMemory/`（vault 内），这里才是 SelfStudyOS 的 source of truth

> 旧规则"新对话必须完整读取所有 feedback 文件，不能只读 MEMORY.md"已作废，以 agent-memory-write skill 为准。

## 二、启动句维护规则

**Rule:** `06_给Agent的启动句.md` 只允许在末尾追加新行，不允许删改已有的任何行。

**Why:** 之前的修改（替换"3条硬约束"为多文件路径）改变了文件原意。

**How to apply:**
- 如需增加新的必读文件 → 在文件末尾的硬约束段落追加一行
- 如需修改已有约束 → 追加一行说明旧规则已更新，但保留旧行
- 绝对不删除或替换已有文本行
