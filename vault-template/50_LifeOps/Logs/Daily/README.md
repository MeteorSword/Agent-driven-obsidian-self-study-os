# Daily Logs

每天一份 Daily Note，文件名格式 `YYYY-MM-DD.md`。

每次学习/作业/复习 session 结束时，agent 会按 [[../../../99_Meta/Templates/learning_close_5lines|学习结束 5 行]] 模板把当次 session 追加到当天 Daily Note 的「复盘」段下面。

如果当天 Daily Note 还不存在，agent 会先用 [[../../../99_Meta/Templates/daily_note|daily-note 模板]] 创建一份，再追加 5 行。

## 为什么 Daily Note 是收口位置

- 把"今天学到什么"集中到一份按时间命名的文件，回看时按日期就能找到。
- 避免 02_今日状态 / 03_行动队列 / 课程 progress 被频繁覆盖，导致 source of truth 漂移。
- 5 行有固定结构，便于后期统计：每天有没有真实进展 / Hint 用到第几层 / 不懂的点是不是反复出现。

详见 [`docs/close-ritual.md`](../../../../docs/close-ritual.md)。

## 本目录默认不追踪到 git

Daily Note 包含个人学习记录，发布开源版时建议在 `.gitignore` 排除 `50_LifeOps/Logs/Daily/2*.md`，只保留本 README 和模板。
