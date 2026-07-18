# selfstudyos-workflow skill

这是 SelfStudyOS 的公开版 agent workflow skill。

## 使用方式

把本目录复制到你的 agent skills 目录中，或按你的 agent 平台要求安装。

使用时告诉 agent：

```text
我的 Obsidian Vault 路径是 <YOUR_VAULT_PATH>。
请使用 selfstudyos-workflow 运行今天的学习 session。
```

## 注意

这个 skill 不包含任何私人路径、课程资料或个人画像。具体 Vault 路径和学习状态由用户自己的 Vault 提供。

## 职能范围（v0.3 stage0 精简后）

精简后 selfstudyos-workflow 只负责：

- 日常学习调度（Daily Learning）：读状态、选主任务、半强制复习触发、交接给课程执行 skill
- ResearchWiki / ProjectLab：v1.0 占位模块，当前不提供流程

不再包含：

- 资料归档：由 agent-material-intake skill 处理
- 课程执行（开始学习/作业/复习/考试冲刺）：由 selfstudyos-course-workflow skill 处理

