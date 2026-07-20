# Windows Setup Guide

这份指南面向第一次在 Windows 电脑上试用 Obsidian SelfStudyOS 的用户。

目标不是把 Windows 变成完整开发环境，而是让你能完成三件事：

1. 打开 Obsidian 模板。
2. 用 Git 或 ZIP 下载本项目。
3. 用 Codex 或 Claude Code 启动一次 AI-assisted 学习 session。

## 0. 推荐路线

如果你只想试用这个项目，推荐路线是：

```text
Obsidian + GitHub ZIP + Codex app 或 Claude Code Desktop/CLI
```

如果你想长期维护自己的版本，推荐路线是：

```text
Obsidian + Git for Windows + GitHub Desktop 或 Git CLI + Codex/Claude Code
```

## 1. 安装 Obsidian

从官方页面下载并安装：

- Obsidian download: https://obsidian.md/download

建议新建一个单独 Vault，例如：

```text
C:\Users\<YourName>\Documents\Obsidian\SelfStudyOS
```

不要一开始就把模板混进你已有的大型 Vault。先跑通一次最小学习闭环，再决定是否合并。

## 2. 下载本项目

### 方式 A：GitHub ZIP

适合不熟悉命令行的用户。

1. 打开 GitHub 仓库页面。
2. 点击 `Code`。
3. 选择 `Download ZIP`。
4. 解压到一个普通目录，例如：

```text
C:\Users\<YourName>\Documents\Projects\obsidian-self-study-os
```

### 方式 B：GitHub Desktop

适合想同步更新但不想用命令行的用户。

1. 安装 GitHub Desktop。
2. Clone 仓库到本机。
3. 后续用 GitHub Desktop pull 更新。

### 方式 C：Git CLI

适合熟悉命令行的用户。

先安装 Git for Windows：

- Git for Windows: https://git-scm.com/download/win

然后在 PowerShell 中运行：

```powershell
cd $HOME\Documents\Projects
git clone https://github.com/<owner>/obsidian-self-study-os.git
cd obsidian-self-study-os
git config --global core.quotepath false
```

`core.quotepath false` 可以让 Git 更友好地显示中文文件名。

## 3. 复制 Vault 模板

把项目里的：

```text
vault-template
```

复制到你的 Obsidian Vault 中。你可以选择两种方式：

### 方式 A：作为整个 Vault

把 `vault-template` 复制并重命名为：

```text
SelfStudyOS
```

然后用 Obsidian 打开这个文件夹。

### 方式 B：合并进已有 Vault

把 `vault-template` 里面的目录复制到已有 Vault 根目录。

已有 Vault 用户要注意：

- 如果已经有同名目录，先备份。
- 不要覆盖自己的私人笔记。
- 推荐先只复制 `70_AgentSystems/`，确认工作流适合你后再合并其他目录。

## 4. Windows 路径怎么写进 prompt

Prompt 里会出现：

```text
<YOUR_VAULT_PATH>
```

Windows 示例：

```text
C:\Users\Alice\Documents\Obsidian\SelfStudyOS
```

如果路径里有空格，告诉 agent 时保留完整路径：

```text
C:\Users\Alice\Documents\Obsidian Vault\SelfStudyOS
```

在 PowerShell 命令里，带空格路径要加引号：

```powershell
cd "C:\Users\Alice\Documents\Obsidian Vault\SelfStudyOS"
```

## 5. 安装 AI agent 工具

你可以用 Codex，也可以用 Claude Code。二选一即可。

### 选择 A：Codex app

OpenAI 官方 Codex Windows 文档：

- Codex Windows guide: https://developers.openai.com/codex/app/windows
- Codex CLI docs: https://developers.openai.com/codex/cli

官方 Windows 文档说明 Codex app 可以在 Windows 上使用 PowerShell，也可以配置 WSL2；文档还列出了常用开发工具，例如 Git、Node.js、Python、.NET SDK 和 GitHub CLI。

常用安装命令：

```powershell
winget install Codex -s msstore
winget install --id Git.Git
winget install --id OpenJS.NodeJS.LTS
winget install --id Python.Python.3.14
winget install --id GitHub.cli
```

安装后打开 Codex app，把项目目录或你的 Vault 目录作为工作目录。

### 选择 B：Claude Code

Anthropic 官方 Claude Code setup 文档：

- Claude Code setup: https://code.claude.com/docs/en/setup

官方文档给出了 Windows PowerShell 安装方式：

```powershell
irm https://claude.ai/install.ps1 | iex
```

也可以用 WinGet：

```powershell
winget install Anthropic.ClaudeCode
```

安装后验证：

```powershell
claude --version
claude doctor
```

然后在 Vault 或项目目录中启动：

```powershell
cd "C:\Users\<YourName>\Documents\Obsidian\SelfStudyOS"
claude
```

## 6. 可选依赖

这些不是 SelfStudyOS 必需，但对 AI agent 和项目维护有帮助。

| 工具 | 用途 | 安装方式 |
|---|---|---|
| Git | clone、提交、同步仓库 | `winget install --id Git.Git` |
| Node.js LTS | 很多 agent 和前端工具会用到 | `winget install --id OpenJS.NodeJS.LTS` |
| Python | 数据处理、脚本、PDF 工具 | `winget install --id Python.Python.3.14` |
| GitHub CLI | 命令行登录 GitHub | `winget install --id GitHub.cli` |

Node.js 官方下载页：

- https://nodejs.org/en/download

## 7. 第一次启动 SelfStudyOS

打开：

```text
01_LearningDesk\06_给Agent的启动句.md
```

然后打开：

```text
prompts\01_general_start.md
```

把 prompt 复制给 Codex 或 Claude Code，并替换：

```text
<YOUR_VAULT_PATH>
```

第一次可以这样说：

```text
我的 Vault 路径是 C:\Users\<YourName>\Documents\Obsidian\SelfStudyOS。
请阅读 01_LearningDesk\06_给Agent的启动句.md，并帮我启动今天唯一的学习任务。
先不要整理所有资料，先问我当前理解和卡点。
```

## 8. OneDrive 和同步风险

如果你的 Vault 放在 OneDrive、微信文件夹、桌面同步目录里，注意：

- AI agent 可能会一次性修改多个 Markdown 文件。
- 同步软件可能产生冲突副本。
- 大附件不应该进公开仓库。

更稳的做法：

```text
C:\Users\<YourName>\Documents\Obsidian\SelfStudyOS
```

先本地使用，确认稳定后再决定是否开启同步。

## 9. 常见问题

### PowerShell 不能运行脚本

如果看到类似：

```text
npm.ps1 cannot be loaded because running scripts is disabled on this system
```

可以参考 Microsoft execution policy 文档，再决定是否调整策略：

- https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies

常见命令：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

### Git 中文文件名显示乱码

运行：

```powershell
git config --global core.quotepath false
```

### Agent 找不到文件

检查三件事：

1. `<YOUR_VAULT_PATH>` 是否替换成真实路径。
2. 路径里有空格时是否加了引号。
3. Obsidian 打开的目录是否就是你复制模板的目录。

## 10. 最小验证

第一次试用只验证一件事：

1. Agent 能读到 `01_LearningDesk\06_给Agent的启动句.md`。
2. Agent 能打开 `Review/progress.md`。
3. Agent 能进入 `CourseOS/ExampleCourse/ExampleCourse-MOC.md`。
4. Agent 会先问你当前理解，而不是直接总结所有资料。

如果这四点成立，Windows 环境已经足够开始使用 SelfStudyOS。

