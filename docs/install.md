# 安装说明

本文件回答一个问题：**把这个仓库变成你每天能用的学习系统，需要做什么。**

预计 15 分钟安装 + 30 分钟冒烟测试。

---

## 0. 先分清两样东西

| 东西 | 放哪 | 谁来读 |
|---|---|---|
| **Vault 骨架**（`vault-template/`） | 你的 Obsidian Vault 根目录 | 你和 agent 都读 |
| **6 个 skill**（`skills/`） | **agent 平台的 skills 目录**（不在 Vault 内） | 只有 agent 读 |

容易搞错的地方：skill 不是 Vault 的一部分。Vault 里只需要放模板和你的笔记；skill 装在你的 AI 工具那边。

---

## 1. 装 Vault

1. 在 Obsidian 里新建一个 Vault（或选一个已存在的空 Vault）。
2. 把仓库里的 `vault-template/` 目录**内容**复制到 Vault 根目录。
3. 用 Obsidian 打开，确认能看到 `01_LearningDesk/`、`70_AgentSystems/`、`99_Meta/`。
4. 把 `70_AgentSystems/SelfStudyOS/CourseOS/ExampleCourse` 复制一份并改名成你正在学的课。

> Obsidian 核心插件建议：开启「模板」（Templates）与「日记」（Daily notes）。模板目录指向 `99_Meta/Templates`，日记目录指向 `50_LifeOps/Logs/Daily`。
>
> 不建议一开始就把模板合并进一个已有几千篇笔记的大 Vault。先跑通一次闭环。

---

## 2. 装 skill（四条路线，选你用的那一条）

### 路线 A：Claude Code

```bash
# 用户级（所有项目可用）
mkdir -p ~/.claude/skills
cp -r <repo>/skills/* ~/.claude/skills/

# 或项目级（只在某个目录可用）
mkdir -p <你的项目>/.claude/skills
cp -r <repo>/skills/* <你的项目>/.claude/skills/
```

重启 Claude Code，输入 `/skills`（或让它列出可用 skill）确认 6 个都在。

### 路线 B：Codex

Codex 读 `AGENTS.md` 与技能目录。两种做法：

- **项目级**：把 `skills/` 复制到你工作目录下的技能目录，并在 `AGENTS.md` 里加一行：
  `Before course tasks, read skills/selfstudyos-course-workflow/SKILL.md.`
- **手动**：不装 skill，需要时直接把某个 `SKILL.md` 全文贴进对话。

### 路线 C：DSH（DeepSeek Harness）

```bash
# 用户级
cp -r <repo>/skills/* ~/.dsh/skills/
# 项目级
cp -r <repo>/skills/* <项目根>/.dsh/skills/
```

目录名必须与 `SKILL.md` frontmatter 里的 `name` 一致。

### 路线 D：手动（任何 agent：ChatGPT / Gemini / 本地模型）

不装 skill，直接用 Vault 里的启动入口：

1. 打开 `01_LearningDesk/06_给Agent的启动句.md`。
2. 复制「启动句」代码块，把 `${YOUR_VAULT_PATH}` 换成你的真实路径。
3. 贴给 agent。

代价：每次新对话都要贴一次；且 agent 不会自动加载 6 个 skill 的执行步骤。

---

## 3. 改三个地方（一次性配置）

| 文件 | 改什么 |
|---|---|
| `01_LearningDesk/01_学习首页.md`、`02_今日状态.md`、`03_行动队列.md` | 删示例行，填你正在学的课和今天的任务 |
| `70_AgentSystems/SelfStudyOS/System/learner_profile.md` | 写你自己的画像（年级、方向、痛点、偏好） |
| `70_AgentSystems/SelfStudyOS/Review/progress.md` | 写当前真实进度 |

然后 `01_LearningDesk/04_课程入口.md` 把示例课改成你的课。

---

## 4. 验证安装成功（三个信号）

| # | 信号 | 怎么验 |
|---|---|---|
| 1 | skill 被加载 | 问 agent「你现在能用哪些 selfstudyos 相关的 skill」，应答出 6 个名字 |
| 2 | Vault 路径可达 | 让 agent 读 `01_LearningDesk/02_今日状态.md` 并复述当前主线 |
| 3 | 触发词生效 | 只输入「冷启动」，agent 应读取入口文件并报告：当前主线 / 今天 P0 / 有无到期复习 / 建议任务 / 本模式 / 你要先输出什么 |

三个信号里任何一个不成立，先看第 6 节故障排查，不要急着改规则文件。

---

## 5. 30 分钟冒烟测试（第一次必须做）

目标不是学完东西，是验证闭环跑得通。

1. **选一个极小任务**：一节课里的一个概念，或 2 道题。
2. **先自己写**：把你的理解或尝试写出来（哪怕错）。
3. **让 agent 给 Hint 1**，你继续写。
4. **说「收口」**：agent 应把 5 行写进 `50_LifeOps/Logs/Daily/<今天>.md`。
5. **检查落盘**：打开那篇 Daily Note，看 5 行是否写清楚题号/章节、你自己完成了什么、AI 给了哪层 Hint、还卡什么、明天最小动作。

如果 5 行写得像「今天学了挺多 / 基本掌握」，说明 agent 没按规则做——回查 `06_给Agent的启动句.md` 的硬约束段是否被截断。

---

## 6. 故障排查

| 症状 | 原因 | 处理 |
|---|---|---|
| skill 列不出来 | 目录名与 frontmatter `name` 不一致；或首行不是 `---`；或文件带 BOM | 目录名改一致，确认 `SKILL.md` 首字符是 `-` |
| agent 读不到 Vault 文件 | `${YOUR_VAULT_PATH}` 没替换；或路径含空格没加引号 | 用完整路径，PowerShell 里加双引号 |
| 说「冷启动」没反应 | 该平台不支持 skill 自动加载，或 workflow skill 没装上 | 回退到路线 D：贴启动句 |
| 中文输出乱码 | 终端编码不是 UTF-8 | PowerShell 里执行 `chcp 65001`，或用 Windows Terminal |
| PowerShell 不让跑脚本 | 执行策略限制 | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| 收口没写进 Daily Note | `50_LifeOps/Logs/Daily/` 不存在 | 手动建目录，或让 agent 建 |

> 注意：仓库里的 `scripts/*.ps1` 以 **UTF-8 with BOM** 保存。用编辑器改它时请保持 BOM，否则 Windows PowerShell 5.1 会把中文读成乱码并报语法错误。

---

## 7. 升级

1. 先跑只读扫描：`powershell -File scripts/migrate-scan.ps1 -Root <你的Vault>`（见仓库 `scripts/`）。
2. 看清单里的「冲突项」，逐个人工决定保留哪份。
3. 分批合并，不整体覆盖。
4. 升级完在 `99_Meta/` 留一份 `migration_<日期>.md`。

---

## 8. 卸载

Vault 是普通 Markdown 目录，删掉即可。skill 从平台的 skills 目录移除对应文件夹，然后重启 agent。
