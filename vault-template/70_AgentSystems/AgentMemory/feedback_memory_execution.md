---
name: feedback_memory_execution
description: 用户认为本系统对 memory 的执行不够好，尤其是新对话的冷启动
type: feedback
---

**Rule:** 每次新对话启动时，必须完整读取 AgentMemory/ 下的所有反馈文件，不仅仅是 MEMORY.md 索引。

**Why:** 用户发现之前有些对话中我（agent）的行为与已记录的反馈不一致，说明我在新对话中没有准确加载记忆。

**How to apply:**
- 新会话启动时，按 06_给Agent的启动句.md 的顺序读文件
- AgentMemory/ 目录下所有 .md 文件逐一读取（不仅仅是 MEMORY.md）
- 读取后，对照每一条反馈检查自己的行为
- 如果发现旧记忆中有矛盾的规则，优先采纳更新的那个
- 新增反馈规则时，写入 `<YOUR_VAULT_PATH>\70_AgentSystems\AgentMemory\` 而非 C 盘；Cowork 内置 auto-memory 会自动写 C 盘但不可依赖，AgentMemory 目录才是 SelfStudyOS 的 source of truth
