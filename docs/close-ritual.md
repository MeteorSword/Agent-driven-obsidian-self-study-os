# 收口仪式（Close Ritual）

每次学习/作业/复习 session 结束时，agent 用一份**5 行模板**写进当天 Daily Note 的「复盘」段，替代手动更新多个状态文件。

## 为什么不直接手改 progress 之类的文件

早期版本要求学生在每次 session 结束时：

- 改 `02_今日状态.md` 的「当前主线」
- 在 `03_行动队列.md` 把任务标 done
- 在课程 `progress.md` 加一行已完成题号
- 在 `05_复习入口.md` 更新"当前先复习"
- 在 `Review/revision_notes.md` 加一段

5 个文件，每次都要手改。结果：

- 学生大概率懒得改 → 状态漂移 → 第二天 agent 读到的状态是旧的。
- 或者 agent 替学生改 → 同样的内容在 5 个文件里重复写 → 哪一个是 source of truth 不明。
- session 之间的认知断层增加：今天的细节会被"主线主任务"这种粗粒度字段冲掉。

## 解决方案：5 行 + Daily Note

每次结束，agent 把这 5 行追加到 `50_LifeOps/Logs/Daily/YYYY-MM-DD.md` 的「复盘」段下面：

```text
### 学习结束 5 行 · YYYY-MM-DD · 时间段或主题

1. 今天处理了什么：<具体题号 / 章节 / 概念，不写"高数"这种泛词>
2. 我自己完成的：<不看提示独立写出的部分，如果没有就写"无"，不要美化>
3. AI 帮了什么：<给了哪一层 Hint / 解释了哪个概念 / 检查了哪步>
4. 仍然不懂的：<具体卡点，写到能在下一次成为一道复测题的颗粒度>
5. 明天最小动作：<一个具体动作，30-60 分钟内可完成；不写"继续学高数">
```

通过方式可选附加在第 1 行末尾：`通过方式：无提示 / Hint 1 / Hint 2 / Hint 3 / Solution 后订正`。

完整模板在 [`vault-template/99_Meta/Templates/learning_close_5lines.md`](../vault-template/99_Meta/Templates/learning_close_5lines.md)。

## 落盘流程

1. agent 确定今天日期 `YYYY-MM-DD`。
2. 检查 `50_LifeOps/Logs/Daily/YYYY-MM-DD.md` 是否存在。
3. **不存在则先创建**：按 [`vault-template/99_Meta/Templates/daily_note.md`](../vault-template/99_Meta/Templates/daily_note.md) 模板创建。**不要因为"今天没建 Daily Note"就跳过收口**。
4. 在「复盘」段下面追加 5 行。如果已有内容，新增 `### 学习结束 5 行 · 时间段标签` 分段。
5. 学生本人不动 02 / 03 / 05 / progress。

## 何时仍然要另开文件

5 行**不替代**结构性事件。下列情况 agent 必须另外改对应文件：

| 事件 | 操作 |
|---|---|
| 出现新错题 | 加错题卡 + 课程 progress 错因表加一行 |
| 出现新复习债务 | `Review/revision_notes.md` 加一段 |
| 完成新题号 | 课程 progress「已完成题目」加一行 |
| 主线推进到新章/新模式 | 改 `02_今日状态.md` 的「当前主线」表 |
| 任务完成或被 archive | `03_行动队列.md` 更新 status |

判断标准：**会被未来回查的事**才另开文件，**今天发生的过程**进 Daily Note。

## 写作规则

- **不**写"今天学了挺多"、"基本掌握"、"差不多会了"——必须有具体证据。
- **不**把 AI 帮的内容写到「自己完成的」一栏。
- **不**把"看了视频/读了讲义"算作完成，除非有独立产出。
- **不**因为今天没建 Daily Note 就跳过 5 行；先创建再追加。

## 验证

回头看一周 Daily Note，应该能从 5 行直接还原：

- 这周哪天有真实独立产出，哪天只是 AI 喂答案。
- Hint 1/2/3 被打到第几层最多 → 哪个主题最不稳。
- 「仍然不懂的」是否反复出现同一个点 → 该进 revision_notes。

如果 5 行写得能让一周后的自己看懂自己当时卡在哪，收口仪式就成功了。

## 相关

- [`docs/entry-separation.md`](entry-separation.md) — 双入口设计，让学生不用打开 agent 内部文件。
- [`docs/agent-rules.md`](agent-rules.md) — agent 侧的硬约束。
