# Contributing

欢迎贡献更清晰的学习流程、模板、prompt 和脱敏示例。

## 可以贡献什么

- 更好的 CourseOS / ResearchWiki / ProjectLab 模板
- 更清晰的 AI agent prompt
- 脱敏后的学习闭环示例
- 文档改进、错别字修正、英文翻译
- 隐私和安全检查规则

## 不要提交什么

- 真实课程 PDF、PPT、作业答案或版权材料
- 私人日记、聊天记录、访谈原文
- 学号、手机号、邮箱、住址、账号、token、API key
- 本机绝对路径，例如 `/home/user/...`
- 未经授权的他人材料

## 贡献原则

1. 模板必须能被普通 Obsidian 用户复制使用。
2. prompt 必须保护学习者的主动尝试，不鼓励直接代写作业。
3. 示例必须脱敏，并且只展示方法，不暴露真实个人信息。
4. 文档要解释为什么这样设计，而不是只堆目录。

## Pull Request 前检查

```bash
rg -n "(/home/|C:\\\\|token|secret|api_key|apikey|password|学号|手机号|身份证|微信|邮箱)" .
git status --short
```

如果命令命中真实隐私或本机路径，请先清理再提交。

