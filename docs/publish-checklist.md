# 发布检查清单

公开 GitHub 仓库前，逐项检查。

## 内容范围

- [ ] 仓库只包含模板、prompt、文档、脱敏示例。
- [ ] 没有真实课程 PDF、PPT、作业原件。
- [ ] 没有私人生活记录、访谈记录、聊天记录。
- [ ] 没有本机绝对路径。
- [ ] 没有 API key、token、secret。

## 文件检查

```bash
rg -n "(/home/|C:\\\\|token|secret|api_key|apikey|password|学号|手机号|身份证|微信|邮箱|住址)" .
find . -type f -size +5M
git status --short
```

## GitHub 上传

本项目默认不由 agent 推送 GitHub。手动上传时推荐：

```bash
git remote add origin git@github.com:<your-github-username>/obsidian-self-study-os.git
git push -u origin main
```

如果你用 GitHub 网页上传，请确认 `.gitignore` 和 `LICENSE` 一起上传。

