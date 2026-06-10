# Roadmap

## 0.1（已完成）

- 建立中文主文档。
- 提供 Vault 模板。
- 提供通用 prompt 和 Markdown 模板。
- 提供脱敏 CourseOS 示例。
- 提供公开版 agent workflow skill。

## 0.2（已完成）

- **入口分离**：新增 `01_LearningDesk/` 六张学生侧入口页面。
- **5 行收口仪式**：新增 `99_Meta/Templates/learning_close_5lines.md` 和 `daily_note.md`，替代手动维护多文件。
- **Hint 1/2/3 分层 + 学习/作业模式 + 掌握等级**：写进 `operating_rules.md`。
- **stale 规则**：行动队列里 review 逾期 ≥ 3 天 / homework 逾期 ≥ 7 天自动处理。
- **占位卡机制**：候选概念卡显式标 `·占位`，防止 AI 乱填。
- 新增设计说明：`docs/entry-separation.md` / `docs/close-ritual.md`。

## 0.3

- 增加英文 README。
- 增加更多课程示例（线性代数、计算机基础）。
- 提供一份"跑通一次完整闭环"的最小演示视频或图文。
- 增加 weekly review 示例（基于一周 Daily Note 5 行的自动汇总）。

## 0.4

- 增加 lint 脚本：
  - 检查绝对路径泄漏。
  - 检查 wiki 页面是否有学习证据。
  - 检查行动队列是否有未应用 stale 规则的僵尸 P0。
  - 检查 Daily Note 是否每天有 5 行收口落盘。
- 增加可选 Dataview 查询模板（统计 Hint 层级分布、反复"仍然不懂"项）。

## 0.5

- 增加 Obsidian 插件最小配置建议。
- 增加项目作品集复盘示例。
- 探索 ResearchWiki 与 Reading Mission 队列的最小流水线脚本。

## 0.3（已完成）

- **CourseOS 三模式**：开始学习模式 / 作业模式 / 复习模式写入模板、prompt 和 agent 规则。
- **复习债务路由**：Daily Start 只提示到期复习；复习债务默认只在复习模式展开。
- **前置工具补丁**：作业或开始学习中只有直接阻塞当前任务时，才允许 3-10 分钟补丁，且不计入掌握证据。
- **课程复习 prompt**：新增 `prompts/09_course_review.md`，日常复习与 exam sprint 分离。
