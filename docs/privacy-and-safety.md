# 隐私和安全边界

SelfStudyOS 很容易接触个人课程资料、学习记录、项目记录和本机路径。开源前必须先模板化和脱敏。

## 不应公开

- 学号、手机号、邮箱、住址、账号
- API key、token、secret、cookie
- 本机绝对路径
- 未授权课程资料、PDF、PPT、作业原件
- 私人日记、生活记录、访谈原文
- 未经他人同意的姓名和聊天记录

## 应该模板化

这些内容可以保留结构，但要改成通用模板：

- 学习者画像
- 课程进度
- 外部资料索引
- 作业题来源
- 项目复盘
- 论文阅读队列

## 推荐扫描命令

```bash
rg -n "(/home/|C:\\\\|token|secret|api_key|apikey|password|学号|手机号|身份证|微信|邮箱|住址)" .
```

如果你使用 GitHub，提交前再检查一次：

```bash
git status --short
git diff --cached
```

## 附件策略

本仓库默认不追踪 `80_Attachments/` 中的实际文件。模板只保留 README。真实图片、PDF、课件和导出文件应留在私有 Vault 或外部资料池中。

