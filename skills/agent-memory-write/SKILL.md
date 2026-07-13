---
name: agent-memory-write
description: 当要记录经验、写 feedback、更新 MEMORY 索引时使用。这是写记忆的唯一入口。触发词：写记忆、记下来、记住这个、新增 feedback、更新 memory、经验归档。
---

# 写记忆

这个 skill 是 AgentMemory 的唯一写入入口。所有记忆操作都通过这里完成。

## 为什么要写记忆

AgentMemory 存的是"被真实使用中的问题打疼了之后提炼出来的经验"。不是预写的规则，不是假设性的约束。每一条 feedback 都必须来自一个真实的翻车事件。

## 写入流程

### 1. 确认要记录什么

回答三个问题：
- 什么场景出了什么问题？（触发事件）
- 为什么会出这个问题？（根因）
- 下次遇到类似情况该怎么做？（正确行为）

三个问题答不全，不写。等下次被同样的问题再打一次，补全了再写。

### 2. 查重

读 `AgentMemory/MEMORY.md` 索引，检查是否已有相似 feedback。

- 有相似的：追加到已有文件，不新建。在原有文件末尾加一个 `### 附加规则` 段落。
- 没有相似的：新建 `AgentMemory/feedback_<主题>.md`。

### 3. 写 feedback 文件

格式模板：

```markdown
# 规则：<一句话总结>

<2-3 句话说清楚这条规则要求什么>

**Why:** <这个规则是从哪个真实事件中学来的，具体到日期和场景>

**How to apply:**
- <具体操作步骤 1>
- <具体操作步骤 2>
- <具体操作步骤 3>
```

如果有附加规则（追加到已有文件）：

```markdown
### 附加规则：<一句话总结>（由 YYYY-MM-DD <事件> 暴露）

<规则内容>

**How to apply:**
- <步骤>
```

### 4. 更新索引

在 `AgentMemory/MEMORY.md` 里加一行：

```markdown
- [feedback_<主题>](feedback_<主题>.md) — <一句话描述>
```

如果是追加到已有文件，索引不变。

### 5. 记录到 Daily Note

在当天 Daily Note 里加一行：

```markdown
- 新增 feedback: <主题>
```

或

```markdown
- 追加 feedback: <已有主题> ← <新事件>
```

## 硬约束

- **只写在 vault 内的 AgentMemory 文件夹。** 不使用工具自带的 autoMemory 写到 vault 外。
- **每条 feedback 必须有 Why 和 How to apply。** 没有场景的空规则不写。
- **feedback 是事件触发的。** 不预写可能用得上的规则，不一次性批量写多条。
- **MEMORY.md 索引必须同步。** 不允许存在没有被索引的孤儿 feedback。
- **命名格式：** `feedback_<主题>.md`，主题用简短关键词。

## 读取规则（供冷启动参考）

冷启动时 AI 读 MEMORY.md 索引即可了解有哪些 feedback。具体 feedback 文件按需读取：
- 如果当前任务和某个 feedback 主题相关，读对应文件
- 如果不确定是否相关，先看索引里的一句话描述再决定
- 不需要每次冷启动都全量读取所有 feedback 文件

当 feedback 超过 15 条时，考虑分层：
- **core（5 条以内）：** 每次冷启动都读（如 no_spoiler、completion_standard）
- **situational：** 按场景召回
